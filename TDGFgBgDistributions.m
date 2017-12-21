
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
    for n = 1:params.num_of_frames
        tot_density{n} = zeros(length(params.fm.dens_x),1);
        frame        = frames(:,:,n);
        mask         = masks(:,:,n);
        fg_tot_density{n} = zeros(length(params.fm.dens_x),1);
        bg_tot_density{n} = zeros(length(params.fm.dens_x),1);
        for m = 1:size(data.seeds{n},1) 
            intensity_values{n,m}           = frame(mask == m);% crop the current frame according to the voronoi mask
            intensity_values{n,m}           = intensity_values{n,m}(intensity_values{n,m}>1); % vanishes all the absolute bg pixels
            absolut_background{n,m}         = intensity_values{n,m}(intensity_values{n,m}<=1); % store the absolute bg pixels for further distribution calculation
            dist_object{n,m}                = fitgmdist(intensity_values{n,m},params.fm.foreground_n_gaussians+params.fm.background_n_gaussians);
            %dist_density{n,m}               = pdf(dist_object{n,m}, params.fm.dens_x);
            [bg_mu{n,m} index]              = min(dist_object{n,m}.mu); %isolate the min mu gaussian and assign to bg 
            bg_sigma{n,m}                   = dist_object{n,m}.Sigma(index);
            bg_weight{n,m}                  = dist_object{n,m}.ComponentProportion(index);
            fg_mu{n,m}                      = dist_object{n,m}.mu;
            fg_sigma{n,m}                   = dist_object{n,m}.Sigma;
            fg_weights{n,m}                 = dist_object{n,m}.ComponentProportion;
            fg_mu{n,m}(index)               = [];    % delete the bg parameters from the fg dist 
            fg_sigma{n,m}(index)            = []; 
            fg_weights{n,m}(index)          = [];
            fg_weights{n,m} = fg_weights{n,m}/(sum(fg_weights{n,m})); % normalizing the fg weights
            %bg_values{n,m}                 = intensity_values{n,m}(intensity_values{n,m}<(bg_mu{n,m}+bg_sigma{n,m}));
            bg_dist_object{n,m}             = makedist('Normal','mu',bg_mu{n,m},'sigma',bg_sigma{n,m});
            bg_density{n,m}                 = pdf(bg_dist_object{n,m},params.fm.dens_x);
            fg_density{n,m}                 = zeros(length(params.fm.dens_x),1);
            for i=1:params.fm.foreground_n_gaussians    %iterate over each fg gaussian 
                fg_dist_object{n,m,i}   = makedist('Normal','mu',fg_mu{n,m}(i),'sigma',fg_sigma{n,m}(i));
                fg_density{n,m}         = fg_density{n,m}+fg_weights{n,m}(i)*pdf(fg_dist_object{n,m,i},params.fm.dens_x);
            end
               fg_density{n,m}          = fg_density{n,m}/(sum(fg_density{n,m})); %normalizing
               
               
            %dist_frame{n}(mask==m)     = pdf(dist_object{n,m},frame(mask == m)); % gives very good spatial prob map
           
            fg_tot_density{n}         = fg_tot_density{n}+ fg_density{n,m};
            bg_tot_density{n}         = bg_tot_density{n}+ bg_density{n,m};
            
        end
        %dist{n} = dip_histogram(dist_frame{n},length(params.fm.dens_x))
        %tot_density{n} = tot_density{n}/(sum(tot_density{n}));
        %for i = 1:length(params.fm.dens_x)
          %  prob{n}(i) = sum(tot_density{n}(1:i));
        %end 
          fg_tot_density{n} =  fg_tot_density{n}/(sum( fg_tot_density{n}));
          bg_tot_density{n} =  bg_tot_density{n}/(sum( bg_tot_density{n}));
    end
   
end

fg_density = fg_tot_density{1};
bg_density = bg_tot_density{1};
    
	% TODO asaf - for each frame, take voronoi cell, fit gmm distribution and recieve mu's and covaraiance.
	% then, take the maximum likelihood estimator(max n over f_n(class | sample)) for each pixel in the cell.

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