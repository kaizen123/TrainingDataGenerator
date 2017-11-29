function [probability_map] = TDGProbabilityMap(frame_index, method, data, params)
% returns probability map for each pixel in 'frame' to belong to the foreground (cells)
% INPUTS:	frame_index: index of the frame in the data struct
%			method: take foreground/background mask from:
%					'mix' - given manual labels if they exist for this frame
%					'calculated' - calculated mask from raw data
%           params: parameters struct for the TDG
%           data: data struct for the TDG
% OUTPUTS: 	probability_map: [m*n] matrix, normalized to [0,1]

assert(strcmp(method, 'mix') | strcmp(method, 'calculated'), 'method not supported');

frame = data.pp_frame{frame_index};
if strcmp(method, 'mix')

end



end