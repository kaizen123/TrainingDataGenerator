
function [fg_density, bg_density] = TDGFgBgDistributions(frames, masks, params,data)
% returns the distribution objects for the foreground and background according to the method in params. 
% INPUTS:	frames - d greyscale image, stacked as a 3D matrix
%			masks - d logic matrices representing raw segmentation, 1 for foreground, 0 for background, stacked as a 3D matrix
%           params - parameters struct for the TDG
%           data - data struct for the TDG 
% OUTPUTS: 	fg_density - pdf of the intensity of the foreground (cells)
%			bg_density - pdf of the intensity of the background

assert(all(size(masks) == size(frames)), 'Size of masks and frames do not match');

if strcmp(params.fm.probability_map_method, 'gmm')
	fg_intensity_values = frames(masks > 0);
	bg_intensity_values = frames(masks == 0);
	fg_dist_object      = fitgmdist(fg_intensity_values, params.fm.foreground_n_gaussians);
	fg_density          = pdf(fg_dist_object, params.fm.dens_x);
	bg_dist_object      = fitgmdist(bg_intensity_values, params.fm.background_n_gaussians);
	bg_density          = pdf(bg_dist_object, params.fm.dens_x);
	return;
end

if strcmp(params.fm.probability_map_method, 'voronoi')
    alpha = params.fm.probability_map_alpha;
    for n = 1:params.num_of_frames
        tot_density{n}       = zeros(length(params.fm.dens_x),1);
        frame                = frames(:,:,n);
        mask                 = masks(:,:,n);
        tot_num_of_gaussians = params.voronoi.num_of_bg_gaussians+params.voronoi.num_of_fg_gaussians;
        fg_tot_density{n}    = zeros(length(params.fm.dens_x),1);
        bg_tot_density{n}    = zeros(length(params.fm.dens_x),1);
        tot_abs_bg{n}        = [];
        for m = 1:size(data.seeds{n},1) 
            intensity_values{n,m}           = frame(mask == m); % crop the current frame according to the voronoi mask
            absolut_background{n,m}         = intensity_values{n,m}(intensity_values{n,m}<=1); % store the absolute bg pixels for further distribution calculation
            intensity_values{n,m}           = intensity_values{n,m}(intensity_values{n,m}>1); % vanishes all the absolute bg pixels
            mirror_intensity_values{n,m}    = cat(1,-1*intensity_values{n,m}(end:-1:1),intensity_values{n,m}); % mirroring the cell to get symetric gmdist
            % TODO - try the algorithm with the mirror_intensity_values. with
            % basic try it doesnt worked so well. 
            dist_object{n,m}                = fitgmdist(intensity_values{n,m},tot_num_of_gaussians);
            temp = dist_object{n,m}.mu;
            for i=1:params.voronoi.num_of_bg_gaussians %iterate over each gaussi
                
                [~, index(i)]              = min(temp); %isolate the min mu gaussians and assign to bg dist
                temp(index(i)) = [];
            end 
            bg_mu{n,m}                      = dist_object{n,m}.mu(index);
            bg_sigma{n,m}                   = dist_object{n,m}.Sigma(index);
            bg_weights{n,m}                 = dist_object{n,m}.ComponentProportion(index);
            % TODO - try to make this part cleaner
            temp                            = dist_object{n,m}.mu; % deleting the bg parts from the fg dist
            temp(index)                     = [];
            fg_mu{n,m}                      = temp;
            temp                            = dist_object{n,m}.Sigma;
            temp(index)                     = [];
            fg_sigma{n,m}                   = temp;
            temp                            = dist_object{n,m}.ComponentProportion;
            temp(index)                     = [];
            fg_weights{n,m}                 = temp;
            bg_weights{n,m}                 = bg_weights{n,m}/(sum(bg_weights{n,m})); % normalizing the fg/bg weights
            fg_weights{n,m}                 = fg_weights{n,m}/(sum(fg_weights{n,m}));  
            bg_dist_object{n,m}             = gmdistribution(bg_mu{n,m},bg_sigma{n,m},bg_weights{n,m});
            bg_density{n,m}                 = pdf(bg_dist_object{n,m},params.fm.dens_x);
            fg_dist_object{n,m}             = gmdistribution(fg_mu{n,m},fg_sigma{n,m},fg_weights{n,m});
            fg_density{n,m}                 = pdf(fg_dist_object{n,m},params.fm.dens_x);                             
            fg_tot_density{n}               = fg_tot_density{n}+ fg_density{n,m}; % suming the distributions over all cells in the frame 
            bg_tot_density{n}               = bg_tot_density{n}+ bg_density{n,m};               
        end
        fg_tot_density{n}             =  fg_tot_density{n}/(sum( fg_tot_density{n}));  % normalizing
        bg_tot_density{n}             =  bg_tot_density{n}/(sum( bg_tot_density{n}));
        %gray_probability{n}           = (alpha*fg_tot_density{n}) ./ (alpha*fg_tot_density{n} + (1-alpha)*bg_tot_density{n});
    end  
end

% TODO:
% only for temp convinience , need to adjust the fm to work on each frame
% seperatly and then output -  fg_density{n}, bg_density(n}
disp('warning - the results may fit only for the first frame. for further information see TDGFgBgDistributions doc');
fg_density = fg_tot_density{1};
bg_density = bg_tot_density{1};
    
	
if strcmp(params.fm.probability_map_method, 'kde')
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
	
	fg_density = dens_cells;
	bg_density = dens_BG;
	% Tracking.priorBG    = sum(masks(:)==0)./length(masks(:));
	% Tracking.priorCell  = 1-Tracking.priorBG;

end
end

