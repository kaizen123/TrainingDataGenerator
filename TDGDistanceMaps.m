function [diff_dist, geodesic_dist, nearest_mean_dist] = TDGDistanceMaps(speed_map, mu)
% returns geodesic and "nearest mean" distance maps for every pixel in the picture
% INPUTS:	speed_map - the speed map used to calculate the geodesic distance
% 			mu - [n*2] matrix containing pairs of coordinates of mean valued pixels, where 
% OUTPUTS: 	diff_dist - 0 if nearest_mean_distis bigger than geodesic_dist for every pixel, otherwise the difference. size of speed_map.
%		 	geodesic_dist - the geodesic distance map, size of speed_map
% 			nearesat_mean_distance - the 'nearest mean' distance map, size of speed_map

global debug;
assert((~any(isnan(mu))) & (~any(mu < 1)) & (~any(mu(1) > size(speed_map,1))) & (~any(mu(2) > size(speed_map,2))),...
	'mean locations are out of bounds');
assert(~any(isnan(speed_map)), 'speed map contains NaN');

mean_mask = zeros(size(speed_map));
mean_mask(mu(1),mu(2)) = 1;
nearest_mean_dist = max(double(bwdist(mean_mask, 'quasi-euclidean')), eps);
geodesic_dist     = max(msfm2d(speed_map, mu, true, true), eps);
diff_dist         = max(geodesic_dist - nearest_mean_dist, 0);

if debug.enable
	index = debug.index;
	debug.frame{index}.diff_dist         = diff_dist;
	debug.frame{index}.geodesic_dist     = geodesic_dist;
	debug.frame{index}.nearest_mean_dist = nearest_mean_dist;
end