function [uncrop_frame] = UnCropImage(uncrop_size, crop, crop_indices, fill_value)
% 
% INPUTS:
% OUTPUTS: 	

assert(size(crops,1) == size(crop(indices,1)), 'number of crops given is not equal to number of crop_indices given');

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