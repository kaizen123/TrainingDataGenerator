function [output] = TDGFunctionTemplate(input, varargin)
% function description
% INPUTS:	input: matrix [m*n] that is...   
% OUTPUTS: 	output: string / uint / bool...

% input assertions - very important if input is string:
assert(input == 'something' & input > 0 | ...)

end