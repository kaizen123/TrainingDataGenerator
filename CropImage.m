function [cropped,indexs] = CropImage(frame,seed,params,varargin)
% return the cropped image of the cell defined by the cell's COM in size [params.crop.crop_size]
% INPUTS:	frame - greyscale image [m*n]
%           params - parameters struct for the TDG
%           COM -  1X2 vector contains the cell's COM coordinates   
% OUTPUTS: 	cropped - cropped greyscale image size [params.crop.crop_size] 
%           indexs - vector size [(params.crop.crop_size(1)+1)*(params.crop.crop_size(2)+1)X1]
%           contain all the original frame linear indexs of the crooped
%           frame

global debug;

assert(all(seed <=size(frame)) & all(seed>=0), 'COM coordinates mismatch');

if debug.enable
	index = debug.index;
	debug.frame{index}.frame_related_variable = frame_related_variable;
	debug.some_parameter = some_parameter;
end
% define patch corners and crop the original frame  
h        = params.crop.crop_size(1);
w        = params.crop.crop_size(2);
y1       = max(round(seed(1)-h/2),1);
y2       = min(round(seed(1)+h/2),size(frame,1));
x1       = max(round(seed(2)-w/2),1);
x2       = min(round(seed(2)+w/2),size(frame,2));
cropped  = frame(y1:y2,x1:x2);
% 
if nargout>1
    [X,Y]   = meshgrid(x1:x2,y1:y2);
    indexs     = sub2ind(size(frame),Y(:),X(:));
end
end