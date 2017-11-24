function [params] = TDGLoadParams(source_type, cell_dataset, pointer)
% load parameters of the Training Data Generator
% INPUTS:	source_type: string, source_type of the parameters,
%                   'text' from a text-file.
%                   'script' for the use of this script default values.
%                   'struct' for a different parameters struct.
%			cell_dataset: string, the dataset to run on.
%           pointer: for 'text' it is the address of the file for input paramters
%                    for 'struct' it is the struct of parameters
% OUTPUTS:  params: parameters struct for the TDG

if strcmp(source_type, 'script')
	switch cell_dataset
	case 'fluo-c2dl-msc'
		params.number_of_frames             = 2;
		params.min_cell_size                = 100;
		% PreProcessing parameters
		params.pp.gauss_bg_filter.enable    = true;	
		params.pp.gauss_bg_filter.sigma     = 100;
		params.pp.median_filter.enable      = true;
		params.pp.median_filter.size        = [3 3];
		params.pp.otsu_median_filter.enable = false;
		params.pp.otsu_median_filter.size   = [9 9];
		params.pp.otsu_th_fix 				= 0.05;
		% FastMarching parameters
		params.fm.background_dist_fit 		= 'gmm';
		params.fm.cell_n_gaussians 			= 5;
		params.fm.background_n_gaussians 	= 1;
	otherwise
	end
end
end

