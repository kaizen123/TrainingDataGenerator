function [features] = TDGExtractFeatures(source_type, source, params, seeds,s)
% extracts features from a frame or copies a different struct of features
% code referenced from:
% https://github.com/arbellea/CellTrackingAndSegmentationPublic/blob/master/calcFeatures.m
% INPUTS:	source_type: 'frame' or 'struct'
% 			source: if source_type is 'frame' then source is a single frame
% 					if source_type is 'struct' then source is a struct containing the calculated features
%			params - parameters struct for the TDG
%			seeds - [s*2] matrix containing the user marks (x,y) coordinates
%					where s is the the number of seeds given (number of cells in the frame
% OUTPUTS: 	features: a struct of the extracted features

assert(strcmp(source_type, 'frame') | strcmp(source_type, 'struct'), 'source type not supported');

if strcmp(source_type, 'frame')
	sobel_h                   = fspecial('sobel');
	features.sobel_horizontal = imfilter(source, sobel_h);
	features.sobel_vertical   = imfilter(source, sobel_h.');
	features.grad             = sqrt(features.sobel_horizontal.^2 + features.sobel_vertical.^2);
	norm_source               = source/(2^16-1);
	features.otsu             = im2bw(norm_source, params.th(s)); %TODO asaf - this is a mistake. no real use of otsu!!
	features.voronoi_mask     = voronoi2mask(seeds(:,2), seeds(:,1), size(source));
end
end