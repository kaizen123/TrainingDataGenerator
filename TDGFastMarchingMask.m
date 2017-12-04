function [fast_marching_mask] = TDGFastMarchingMask(frame, features, seeds, params)
% returns the binary mask of the fast marching algorithm.
% INPUTS:	frame - greyscale image
%			features - feature struct for the current frame
%			params - paramters struct for the TDG
% 			seeds - [k*3] matrix containing the user marks (x,y) coordinates and the button pressed when taken
%					where k is the the number of seeds given (usually number of cells in the frame)
% OUTPUTS: 	fast_marching_mask - binary mask, the size of frame

global debug;

% speed map calculation
k     = params.fm.k;
q     = params.fm.q;
grad  = features.grad;
gray_probability_map = features.gray_probability_map;
frame_grad_inverse   = max(1./(1+(grad./(k*std(grad(:)))).^q), 0.01); %TODO asaf - agree with values of 0.01?
speed_map            = max(gray_probability_map .* frame_grad_inverse, 0.01); %TODO asaf - speed  = -1/log(speed)

if debug.enable
index = debug.index;
	debug.frame{index}.size_gray_prob_map   = size(gray_probability_map);
	debug.frame{index}.gray_probability_map = gray_probability_map;
	debug.frame{index}.speed_map            = speed_map;
end

% calculate distances
[diff_dist, geodesic_dist, euclidean_dist] = TDGDistanceMaps(speed_map, seeds);

end

function [diff_dist, geodesic_dist, euclidean_dist] = TDGDistanceMaps(speed_map, seeds)
% returns geodesic and "nearest seed" distance maps for every pixel in the picture
% INPUTS:	speed_map - the speed map used to calculate the geodesic distance
% 			seeds - [n*2] matrix containing pairs of coordinates from which the fast marching will start spreading
% OUTPUTS: 	diff_dist - 0 if euclidean_dist is bigger than geodesic_dist for every pixel, otherwise the difference. size of speed_map.
%		 	geodesic_dist - the geodesic distance map, size of speed_map
% 			nearesat_seed_distance - the 'nearest seed' distance map, size of speed_map

global debug;
assert(~any(isnan(seeds(:))) & ~any(seeds(:) < 1) & ~(any(seeds(:,1) > size(speed_map,1))) & ~(any(seeds(:,2) > size(speed_map,2))),...
	'seed locations are out of bounds');
assert(~any(isnan(speed_map(:))), 'speed map contains NaN');

% create a mask with the seeds using full-sparse method. seeds(1) is the y coordinate, corresponding with seeds_mask rows.
seeds_mask = full(sparse(seeds(:,1), seeds(:,2), ones(size(seeds,1),1)));
size_diff  = size(speed_map) - size(seeds_mask);
% pad array on the bottom and on the right
seeds_mask = [seeds_mask , zeros(size(seeds_mask,1), size_diff(2))];
seeds_mask = [seeds_mask ; zeros(size_diff(1), size(seeds_mask,2))];
assert(all(size(seeds_mask) == size(speed_map)),...
	'speed_map size and seeds_mask do not match.\n size(speed_map)=%d \n size(seeds_mask)=%d', size(speed_map), size(seeds_mask));
euclidean_dist = max(double(bwdist(seeds_mask, 'quasi-euclidean')), eps);
% seeds need to be transposed so that the first row is coordinates in y, and the second is coordinates in x.
geodesic_dist     = max(msfm2d(speed_map, seeds', true, true), eps); % the method will use second order derivatives and cross neighbours
diff_dist         = max(geodesic_dist - euclidean_dist, 0);

if debug.enable
	index = debug.index;
	debug.frame{index}.diff_dist      = diff_dist;
	debug.frame{index}.geodesic_dist  = geodesic_dist;
	debug.frame{index}.euclidean_dist = euclidean_dist;
	debug.frame{index}.seeds_mask     = seeds_mask;
end
end