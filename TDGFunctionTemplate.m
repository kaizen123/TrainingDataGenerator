function [output] = TDGFunctionTemplate(input, varargin)
% function description
% INPUTS:	input - matrix [m*n] that is...   
% OUTPUTS: 	output - string / uint / bool...

% debug struct 
global debug;

% input assertions - very important if input is string:
assert(input == 'something' & input > 0 | ...)

if debug.enable
	index = debug.index;
	debug.frame{index}.frame_related_variable = frame_related_variable;
	debug.some_parameter = some_parameter;
end
end