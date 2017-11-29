function [pp_frame] = TDGPreProcessing(frame, params)
% preprocesses frames - removes noise, background ligthing
% INPUTS:	frame: greyscale image [m*n]	
%           params: parameters struct for the TDG
% OUTPUTS: 	pp_frame: [k*l] matrix of greyscale intensity values. default is (k=m ; l=n)

if params.pp.remove_bg_lighting.enable
	pp_frame = frame - imgaussfilt(frame, params.pp.remove_bg_lighting.sigma);
	pp_frame = max(0, pp_frame);
end
if params.pp.median_filter.enable
	pp_frame = medfilt2(pp_frame,params.pp.median_filter.size);
end
% TODO asaf - check the necessity of this step. currently disabled in params.
if params.pp.otsu_median_filter.enable
	otsu_mask    = TDGOtsuMask(pp_frame, params);
	temp         = medfilt2(frame, params.pp.otsu_median_filter.size);
	pp_frame 	 = pp_frame.*(1-otsu_mask) + temp.*otsu_mask;
	pp_frame 	 = max(pp_frame,0);
end
end