function [seg] = TDGFastMarching(frame, features, seeds, params)
% returns the binary mask of the fast marching algorithm.
% INPUTS:	frame - greyscale image
%			features - feature struct for the current frame
%			params - paramters struct for the TDG
% 			seeds - [s*2] matrix containing the user marks (x,y) coordinates
%					where s is the the number of seeds given (number of cells in the frame)
% OUTPUTS: 	...TODO...

global debug;

% speed map calculation
k     = params.fm.k;
q     = params.fm.q;
grad  = features.grad;
gray_probability_map = features.gray_probability_map;
frame_grad_inverse   = max(1./(1+(grad./(k*std(grad(:)))).^q), 0.01); %TODO asaf - agree with values of 0.01?
speed_map            = max(gray_probability_map .* frame_grad_inverse, 0.01);
speed_map 			 = -1 ./ log(speed_map); % done to map [0,1] to [0, inf)

if debug.enable
	index = debug.index;
	debug.frame{index}.size_gray_prob_map   = size(gray_probability_map);
	debug.frame{index}.gray_probability_map = gray_probability_map;
	debug.frame{index}.speed_map            = speed_map;
end

s = size(seeds,1);
speed_map_crop    = cell(s,1);
dist_map_crop     = cell(s,1);
dist_map_expended = cell(s,1);
crop_indices      = cell(s,1);
aposteriori_prob  = zeros(size(frame,1), size(frame,2), s+1);
aposteriori_prob(:,:,1) = (1-gray_probability_map);
shifted_seeds = zeros(size(seeds));
% TODO - consider the use of cell functions
for m = 1:s
	[speed_map_crop{m}, crop_indices{m}, shifted_seeds(m,:)] = CropImage(speed_map, seeds(m,:), params);
	dist_map_crop{m} = TDGDistanceMaps(speed_map_crop{m}, shifted_seeds(m,:), params.convex_cell_shapes);
	dist_map_expended{m} = UnCropImage(size(frame), dist_map_crop{m}, crop_indices{m}, 1/eps);
	aposteriori_prob(:,:,m+1) = 1./(dist_map_expended{m} + 1);
	if debug.enable
		debug.frame{index}.speed_map_crop{m}     = speed_map_crop{m};
		debug.frame{index}.dist_map_crop{m}      = dist_map_crop{m};
		debug.frame{index}.dist_map_expended{m}  = dist_map_expended{m};
		debug.frame{index}.aposteriori_prob(:,:,m+1) = aposteriori_prob(:,:,1);
		debug.frame{index}.aposteriori_prob(:,:,m+1) = aposteriori_prob(:,:,m+1);
	end
end

thr                                 = 1e-8; % threshold for background impose ( can get any value in range [0 1e-10] with no difference in results)  
[~, seg]                            = max(aposteriori_prob,[],3);
seg(all(aposteriori_prob<thr,3))    = 1;    % impose background in case that all cells probability ~0 
%figure;
%imagesc(seg);

end

function [dist_map] = TDGDistanceMaps(speed_map, seeds, convex_cell_shapes)
% returns geodesic and "nearest seed" distance maps for every pixel in the picture
% INPUTS:	speed_map - the speed map used to calculate the geodesic distance
% 			seeds - [s*2] vector containing a pairs of coordinates from which the fast marching will start spreading
%			-- note -- currently we call the function only with s=1, but it works with any positive integer.
%			convex_cell_shapes - if our data is generally of convex shaped cells, we can normalize the distance with euclidean disfance.
% OUTPUTS: 	dist_map - geodesic / geodesic normalized by euclidean distance.

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
% seeds need to be transposed so that the first row is coordinates in y, and the second is coordinates in x.
geodesic_dist      = max(msfm2d(speed_map, seeds', true, true), eps); % the method will use second order derivatives and cross neighbours
if (convex_cell_shapes)
	euclidean_dist = max(double(bwdist(seeds_mask, 'quasi-euclidean')), eps);
	dist_map       = max(geodesic_dist - euclidean_dist, 0);
else
	dist_map = geodesic_dist; %TODO asaf - consider the data copy
end

if debug.enable
	index = debug.index;
	debug.frame{index}.dist_map   = dist_map;
	debug.frame{index}.seeds_mask = seeds_mask;
end
end

function [crop, crop_indices, shifted_seed] = CropImage(frame,seed,params)
% return the crop image of the cell defined by the cell's COM in size [params.crop.crop_size]
% INPUTS:	frame - greyscale image [m*n]
%           params - parameters struct for the TDG
%           seed -  1X2 vector containing the cell's COM coordinates   
% OUTPUTS: 	crop - crop greyscale image size [params.crop.crop_size] 
%           crop_indices - vector size [(params.crop.crop_size(1)+1)*(params.crop.crop_size(2)+1)X1]
%           contains all the original frame linear crop_indices of the crooped frame

assert(all(seed <=size(frame)) & all(seed>=0), 'COM coordinates mismatch');
% define patch corners and crop the original frame  
h  = params.crop_size(1);
w  = params.crop_size(2);
y1 = max(round(seed(1)-h/2),1);
y2 = min(round(seed(1)+h/2),size(frame,1));
x1 = max(round(seed(2)-w/2),1);
x2 = min(round(seed(2)+w/2),size(frame,2));
crop = frame(y1:y2,x1:x2);
if nargout > 1
	[X,Y]   = meshgrid(x1:x2,y1:y2);
	crop_indices = sub2ind(size(frame),Y(:),X(:));
	if nargout > 2
		shifted_seed = [seed(1) - y1, seed(2) - x1];
	end
end
end

function [uncrop_frame] = UnCropImage(uncrop_size, crop, crop_indices, fill_value)
% 
% INPUTS: TODO
% OUTPUTS:TODO 	
if all(size(fill_value) == uncrop_size)
	uncrop_frame = fill_value;
elseif size(fill_value) == 1
	if fill_value == 0
		uncrop_frame = zeros(uncrop_size);
	else
		uncrop_frame = fill_value * ones(uncrop_size);
	end
else
	error('fill_value size is not supported');
end
	uncrop_frame(ind2sub(uncrop_size, crop_indices)) = crop;
end

