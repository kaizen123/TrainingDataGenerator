function TDGStringAssertion(variable, name, varargin)
% given a primary string and a variable number of matched strings,
% the function asserts that the primary string equals to one of the matched strings
% INPUTS:	variable - string, value of the variable to match
%			name - string, name of the variable to match
% 			varargin - variable number of strings compared to the variable

assert(nargin > 2, 'wrong use of TDGStringAssertion, need to insert at least one string to match');

for n = 1 : length(varargin)
	if strcmp(varargin(n), variable)
		return;
	end
end
error('%s not supported', name); 
end