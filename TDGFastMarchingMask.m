function [fast_marching_mask] = TDGFastMarchingMask(frame, features, params)
% returns the binary mask of the fast marching algorithm.
% INPUTS:	frame: greyscale image
% OUTPUTS: 	binary mask, the size of frame

global debug;

% speed map calculation
k     = params.fm.k;
q     = params.fm.q;
grad  = features.grad;
gray_probability_map = features.gray_probability_map;
frame_grad_inverse   = max(1./(1+(grad./(k*std(grad(:)))).^q), 0.01); %TODO asaf - agree with values of 0.01?
speed_map            = max(gray_probability_map .* frame_grad_inverse, 0.01);

% calculate distances
[diff_dist, geodesic_dist, nearest_mean_dist] = TDGDistanceMaps(); % TODO asaf - 1. understand mu calculation ; 2. understand use of msfm2d ;

if debug.enable
	index = debug.index;
	debug.frame{index}.size_gray_prob_map = size(gray_probability_map);
	debug.frame{index}.gray_probability_map = gray_probability_map;
	debug.frame{index}.speed_map = speed_map;
	debug.frame{index}.diff_dist = diff_dist;
	debug.frame{index}.geodesic_dist = geodesic_dist;
	debug.frame{index}.nearest_mean_dist = nearest_mean_dist;
end

end