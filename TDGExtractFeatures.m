function [features] = TDGExtractFeatures(source_type, source)
% extracts features from a frame or copies a different struct of features
% code referenced from:
% https://github.com/arbellea/CellTrackingAndSegmentationPublic/blob/master/calcFeatures.m
% INPUTS:	source_type: 'frame' or 'struct'
% 			source: if source_type is 'frame' then source is a single frame
% 					if source_type is 'struct' then source is a struct containing the calculated features
% OUTPUTS: 	features: a struct of the extracted features

if strcmp(source_type, 'frame')
	sobel_h = fspecial('sobel');
	log_h   = fspecial('log');
	lap_h   = fspecial('laplacian');

	features.std_3            = stdfilt(source, ones(3));
	features.std_11           = stdfilt(source, ones(11));
	features.laplacian        = abs(imfilter(source, lap_h));
	features.LOG              = abs(imfilter(source, log_h));
	features.sobel_horizontal = imfilter(source, sobel_h);
	features.sobel_vertical   = imfilter(source, sobel_h.');
	features.grad             = sqrt(features.sobel_horizontal.^2 + features.sobel_vertical.^2);    
	features.gaussian         = imgaussfilt(source, 0.7);
end
% TODO asaf - should I normalize all features?

% Data_std = std(Data,0,1);
% Data_norm = bsxfun(@rdivide, Data, Data_std);


end