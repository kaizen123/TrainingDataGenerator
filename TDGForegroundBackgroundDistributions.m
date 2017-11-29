function [fg_dist_object, bg_dist_object] = TDGForegroundBackgroundDistributions(frames, masks, params)
% returns the distribution objects for the foreground and background according to the method in params. 
% INPUTS:	frames: d greyscale images [m*n*d] stacked as a 3D array
%			masks: d logic matrix [m*n*d] representing raw segmentation, 1 for foreground, 0 for background
%           params: parameters struct for the TDG
% OUTPUTS: 	fg_prob_dist: vector representing the pdf of belonging to the foreground,
%			where the vector indices represent the x axis.

if strcmp(params.fm.probability_map_method, 'gmm')
	fg_intensity_values = frames(masks > 0);
	bg_intensity_values = frames(masks == 0);
	fg_dist_object = fitgmdist(fg_intensity_values, params.gm.foreground_n_gaussians);
	bg_dist_object = fitgmdist(bg_intensity_values, params.fm.background_n_gaussians);
	return;
end
if strcmp(params.fm.probability_map_method, 'kde')
	% TODO asaf - complete
end
end