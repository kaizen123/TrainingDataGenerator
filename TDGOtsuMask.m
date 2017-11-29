function [otsu_mask] = TDGOtsuMask(frame, params)
% calculates a binary mask for raw segmentation using Otsu method and a correction
% INPUTS:	frame: greyscale image
%		  	params: parameters struct for the TDG
% OUTPUTS: 	otsu_mask: logical array

otsu_th      = graythresh(frame);
otsu_mask    = (1-(frame > otsu_th - params.pp.otsu_th_fix));
otsu_mask    = medfilt2(otsu_mask, params.pp.otsu_median_filter.size);
otsu_mask    = logical(otsu_mask);
end