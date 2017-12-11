function VoronoiCrop(params,data)
% function description
% INPUTS:	input - matrix [m*n] that is...   
% OUTPUTS: 	output - string / uint / bool...

% debug struct 
global debug;

% input assertions - very important if input is string:
% assert(input == 'something' & input > 0 | ...)

if debug.enable
	index = debug.index;
	debug.frame{index}.frame_related_variable = frame_related_variable;
	debug.some_parameter = some_parameter;
end
for n = 1:params.num_of_frames
    %mask_values = 1:size(data.seeds{n},1);
    for m = 1:size(data.seeds{n},1)
        data.voronoi_crop{n}(m) = data.pp_frame{n}(data.features{n}.voronoi_mask == m);
    end
end


end