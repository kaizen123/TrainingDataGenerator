function [recrop_frame] = ReCropImage(data,n,params)
% recrop the frame from all the slices
% INPUTS:	data - struct holds all data images
%           n - integer with the frame index the user want to recrop
%           params - parameters struct for the TDG
% OUTPUTS: 	recrop_frame - the whole original frame with index n

 
global debug;

assert(n <= params.num_of_frames & n>=1  , 'Index is not in range');

if debug.enable
	index = debug.index;
	debug.frame{index}.frame_related_variable = frame_related_variable;
	debug.some_parameter = some_parameter;
end

recrop_frame = data.pp_frame{n};
 for m = 1:size(data.seeds{n},1)
     recrop_frame(ind2sub(size(data.pp_frame{n}),data.crop{n}.index{m})) = data.crop{n}.cell{m};
 end
 end
