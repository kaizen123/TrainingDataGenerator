function [pp_frame] = TDGPreProcessing(frame, params)
% preprocesses frames - removes noise, background ligthing
% INPUTS:	frame: greyscale image [m*n]	
%           params: parameters struct for the TDG
% OUTPUTS: 	pp_frame: [k*l] matrix of greyscale intensity values. default is (k=m ; l=n)

pp_frame = frame;

if params.pp.remove_bg_lighting.enable
	pp_frame = pp_frame - imgaussfilt(frame, params.pp.remove_bg_lighting.sigma);
	pp_frame = max(0, pp_frame);
end
if params.pp.median_filter.enable
	pp_frame = medfilt2(pp_frame,params.pp.median_filter.size);
end
if params.pp.gaussian_filter.enable
	pp_frame = imgaussfilt(pp_frame, params.pp.gaussian_filter.sigma);
end