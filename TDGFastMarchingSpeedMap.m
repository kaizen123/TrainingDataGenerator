function [speed_map] = TDGFastMarchingSpeedMap(frame, features, params)
% returns a speed map for the FM algorithm
% INPUTS:	frame: greyscale image 	
%			features: a struct containing frame features, such as gradient
%           params: parameters struct for the TDG
% OUTPUTS: 	output: speed_map - an [m*n] matrix containing the speed map

k            = params.fm.k;
q            = params.fm.q;
grad         = features.grad_magnitude;
grad_inverse = max(1./(1+(grad./(k*std(grad(:)))).^q),0.01);

end