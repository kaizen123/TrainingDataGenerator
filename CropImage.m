function [crop, crop_indices] = CropImage(frame,seed,params)
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
if nargout>1
	[X,Y]   = meshgrid(x1:x2,y1:y2);
	crop_indices = sub2ind(size(frame),Y(:),X(:));
end
end