function [params] = TDGLoadParams(source_type, cell_dataset, pointer)
% load parameters of the Training Data Generator, assert allowed values
% INPUTS:	source_type: string, source_type of the parameters,
%                   'text' from a text-file.
%                   'script' for the use of this script default values.
%                   'struct' for a different parameters struct.
%			cell_dataset: string, the dataset to run on.
%           pointer: for 'text' it is the address of the file for input paramters
%                    for 'struct' it is the struct of parameters
% OUTPUTS:  params: parameters struct for the TDG

params.cell_dataset = cell_dataset;

% load default parameters

% load parameters per dataset (may override defaults)
if strcmp(source_type, 'script')
	switch cell_dataset
	case 'fluo-c2dl-msc'
		params.num_of_frames             	= 5;
		params.cell_count_per_frame 		= [9 9 9 9 9];
		params.min_cell_size                = 100;
		% PreProcessing parameters
		params.pp.remove_bg_lighting.enable = true;
		params.pp.remove_bg_lighting.sigma  = 100;
		params.pp.median_filter.enable      = true;
		params.pp.median_filter.size        = [3 3];
		params.pp.otsu_median_filter.enable = false;
		params.pp.otsu_median_filter.size   = [9 9];
		params.pp.otsu_th_fix 				= 0.05;
		
		% FastMarching parameters
		params.fm.probability_map_method 	= 'gmm';
		params.fm.probability_map_alpha 	= 0.5;
		if strcmp(params.fm.probability_map_method, 'gmm')	 
			params.fm.foreground_n_gaussians = 2;
			params.fm.background_n_gaussians = 1;
		end
	otherwise
	end
end

% parameters assertions
assert(length(params.cell_count_per_frame) == params.num_of_frames,...
	'Number of frames is not equal to the given cell count per frame');
assert_param = params.fm.probability_map_method;
assert((strcmp(assert_param, 'gmm') | strcmp(assert_param, 'kde')), 'probability_map_method is not gmm / kde');

end