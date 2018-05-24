
function [gray_probability] = TDGFgBgDistributions(frames, masks, params, data,s)
% returns the distribution objects for the foreground and background according to the method in params. 
% INPUTS:   frames - d greyscale image, stacked as a 3D matrix
%           masks - d logic matrices representing raw segmentation, 1 for foreground, 0 for background, stacked as a 3D matrix
%           params - parameters struct for the TDG
%           data - data struct for the TDG 
% OUTPUTS:  fg_density - pdf of the intensity of the foreground (cells)
%           bg_density - pdf of the intensity of the background

assert(all(size(masks) == size(frames)), 'Size of masks and frames do not match');
alpha = params.fm.probability_map_alpha(s);
% TODO -  replicate the output in gmm and kde

if strcmp(params.fm.probability_map_method(s), 'gmm')
	fg_intensity_values = frames(masks > 0);
	bg_intensity_values = frames(masks == 0);
	fg_dist_object      = fitgmdist(fg_intensity_values, params.voronoi.num_of_fg_gaussians(s));
	fg_density          = pdf(fg_dist_object, params.fm.dens_x);
	bg_dist_object      = fitgmdist(bg_intensity_values, params.voronoi.num_of_bg_gaussians(s));
	bg_density          = pdf(bg_dist_object, params.fm.dens_x);
    gray_probability    = (alpha*fg_density) ./ (alpha*fg_density + (1-alpha)*bg_density);
	return;
end

if strcmp(params.fm.probability_map_method(s), 'voronoi')
    for n = 1:params.num_of_frames
        tot_density{n}       = zeros(length(params.fm.dens_x),1);
        frame                = frames(:,:,n);
        mask                 = masks(:,:,n);
        voronoi_frame        = zeros(size(frame));
        tot_num_of_gaussians = params.voronoi.num_of_bg_gaussians(s)+params.voronoi.num_of_fg_gaussians(s);
        mask_indexes         = (unique(mask(:)))';
        mask_indexes(mask_indexes==0) = [];
         for m = mask_indexes
        %for m = 1:size(data.seeds{n},1) 
            voronoi_frame(mask==m)          = m;
            pre_intensity_values{n,m}       = frame(mask == m); % crop the current frame according to the voronoi mask
            pre_intensity_values{n,m}(pre_intensity_values{n,m}==0) = randi([0 1],size( pre_intensity_values{n,m}(pre_intensity_values{n,m}==0))); % gives random values to the zero pixels for Gmm convergence
            absolute_background{n,m}         = pre_intensity_values{n,m}(pre_intensity_values{n,m}<=1); % store the absolute bg pixels for further distribution calculation
            %intensity_values{n,m}           = pre_intensity_values{n,m}(pre_intensity_values{n,m}>1); % vanishes all the absolute bg pixels          
            %mirror_intensity_values{n,m}    = cat(1,-1*intensity_values{n,m}(end:-1:1),intensity_values{n,m}); % mirroring the cell to get symetric gmdist 
            dist_object{n,m}                = fitgmdist(pre_intensity_values{n,m},tot_num_of_gaussians,'Options',statset('MaxIter',1000));
            dist_values{n,m}                = pdf(dist_object{n,m},params.fm.dens_x);
            [~ , indexs]                    = sort(dist_object{n,m}.mu); % take the minimal mu's to be the bg dist
            bg_index                        = indexs(1:params.voronoi.num_of_bg_gaussians(s));
            fg_index                        = indexs(params.voronoi.num_of_bg_gaussians(s)+1:tot_num_of_gaussians);
            bg_mu{n,m}                      = dist_object{n,m}.mu(bg_index);
            bg_sigma{n,m}                   = dist_object{n,m}.Sigma(bg_index);
            bg_weights{n,m}                 = dist_object{n,m}.ComponentProportion(bg_index);
            fg_mu{n,m}                      = dist_object{n,m}.mu(fg_index);
            fg_sigma{n,m}                   = dist_object{n,m}.Sigma(fg_index);
            fg_weights{n,m}                 = dist_object{n,m}.ComponentProportion(fg_index);
            bg_weights{n,m}                 = bg_weights{n,m}/(sum(bg_weights{n,m})); % normalizing the fg/bg weights
            fg_weights{n,m}                 = fg_weights{n,m}/(sum(fg_weights{n,m}));  
            bg_dist_object{n,m}             = gmdistribution(bg_mu{n,m},bg_sigma{n,m},bg_weights{n,m});
            bg_density{n,m}                 = pdf(bg_dist_object{n,m},params.fm.dens_x);
            fg_dist_object{n,m}             = gmdistribution(fg_mu{n,m},fg_sigma{n,m},fg_weights{n,m});
            fg_density{n,m}                 = pdf(fg_dist_object{n,m},params.fm.dens_x);                             
            gray_probability{n,m}           = (alpha*fg_density{n,m}) ./ (alpha*fg_density{n,m} + (1-alpha)*bg_density{n,m}); 


             %%%% debug section %%%
%             if (n==1&& m==1)  
%             figure
%             subplot(1,4,1)
%             hist(pre_intensity_values{n,m},1000)
%             grid on
%             title('hist with no zeros')
%             subplot(1,4,2)
%             hist(pre_intensity_values{n,m},1000)
%             grid on
%             title('hist with zeros')
%             subplot(1,4,3)
%             plot(dist_values{n,m})
%             title('dist_values')
%             grid on
%             subplot(1,4,4)
%             imshow(frame,[])
%             end 
%             %%%%%%%%%

        end
        %imagesc(voronoi_frame+frame);
    end  
end
	
if strcmp(params.fm.probability_map_method(s), 'kde')
	% TODO amit - find out from Assaf what is the parameter 'u'. consider changing to the "super-fast kde" found on file exchange.

	% -------------------------------------------------
	% code referenced from:
	% https://github.com/arbellea/CellTrackingAndSegmentationPublic/blob/master/calcFeatures.m
	DensCellPoints = frames(masks > 0);
	DensBGPoints   = frames(masks == 0);
	u              = (4/(3*min(numel(DensBGPoints)+numel(DensCellPoints))))^(1./5)*max(std(DensCellPoints),std(DensBGPoints));
	dens_cells     = FastKDE(DensCellPoints, params.fm.dens_x,u);
	dens_BG        = FastKDE(DensBGPoints, params.fm.dens_x,u);
	zz             = find(dens_cells==0);
	zd             = knnsearch([DensCellPoints; DensBGPoints],zz');
	dens_cells(zz(zd<=numel(DensCellPoints))) 	= eps;
	dens_BG(zz(zd>numel(DensCellPoints)))  		= eps;
	% -------------------------------------------------
	
	fg_density          = dens_cells;
	bg_density          = dens_BG;
    gray_probability    = (alpha*fg_density) ./ (alpha*fg_density + (1-alpha)*bg_density);
	% Tracking.priorBG    = sum(masks(:)==0)./length(masks(:));
	% Tracking.priorCell  = 1-Tracking.priorBG;

end
end

function dens =  FastKDE(data,x,varargin)
%%
if isempty(varargin)
sig = 1.06*(numel(data))^(1/5);
else
    sig = varargin{1};
end

h = hist(data,x);
f = -ceil(4*sig):ceil(4*sig);
f = 1./(sig*sqrt(2*pi))*exp(-0.5*(f/sig).^2);
f = f./sum(f);
dens = conv(f,h); 
dens= dens(ceil(4*sig)+1:end-ceil(4*sig));
dens = dens./sum(dens);
end
