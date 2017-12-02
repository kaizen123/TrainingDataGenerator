function [fg_density, bg_density] = TDGFgBgDistributions(frames, masks, params)
% returns the distribution objects for the foreground and background according to the method in params. 
% INPUTS:	frames - d greyscale image, stacked as a 3D matrix
%			masks - d logic matrices representing raw segmentation, 1 for foreground, 0 for background, stacked as a 3D matrix
%           params - parameters struct for the TDG
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
if strcmp(params.fm.probability_map_method, 'kde')
	% TODO asaf - find out from Assaf what is the parameter 'u'. consider changing to the "super-fast kde" found on file exchange.

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