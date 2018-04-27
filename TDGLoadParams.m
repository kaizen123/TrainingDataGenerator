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

TDGStringAssertion(source_type, 'parameters source', 'text', 'script', 'struct','script-shuffle');
params.cell_dataset                             = cell_dataset;
params.multiple_segmentation_per_frame_enable   = true;

if params.multiple_segmentation_per_frame_enable
    valid = false;
    while ~valid
        try 
        temp = input('Please insert number of required segmentation per frame\n');
        catch 
        error('Required number of segmentation is not a valid number');
        end
        if temp==any(1:1000)
            valid = true;
            params.number_of_segmentation_per_frame = temp;
        else 
            error('Required number of segmentation is not a valid number');
        end
    end
else 
    params.number_of_segmentation_per_frame = 1;
end

valid = false;
    while ~valid
        try 
        temp = input('Please insert number of required frames\n');
        catch 
        error('Required number of frame is not a valid number');
        end
        if temp==any(1:1000)
            valid = true;
            params.num_of_frames = temp;
        else 
            error('Required number of frames is not a valid number');
        end
    end
        

% load default parameters

% load parameters per dataset (may override defaults)
if strcmp(source_type, 'script')
	switch cell_dataset
	case 'fluo-c2dl-msc'
		params.th 			                = 0.012;
		%params.cell_count_per_frame         = [9 9 8 8 2 ];
		params.convex_cell_shapes           = false;
		params.crop_size                    = [250 250];
		% PreProcessing parameters
		params.pp.remove_bg_lighting.enable = true;
		params.pp.remove_bg_lighting.sigma  = 100;
		params.pp.median_filter.enable      = true;
		params.pp.median_filter.size        = [3 3];
		params.pp.gaussian_filter.enable    = true;
        params.pp.gaussian_filter.sigma     = 3; 
		
        % Voronoi parameters
        params.voronoi.num_of_bg_gaussians = 1;
        params.voronoi.num_of_fg_gaussians = 1;
		% FastMarching parameters
		params.fm.distance 					= 'diff';
		params.fm.k = 5; % std multiplier factor in the inverse gradient
		params.fm.q = 2; % std power factor in the inverse gradient
		params.fm.probability_map_method 	= 'voronoi';
		params.fm.probability_map_alpha 	= 0.5;
		if strcmp(params.fm.probability_map_method,'gmm')	 
			params.fm.foreground_n_gaussians = 2;
			params.fm.background_n_gaussians = 1;
		end
	otherwise
	end
end

if strcmp(source_type, 'script-shuffle')
   params = TDGShuffleParams(params);
end

% parameters assertions
% assert(length(params.cell_count_per_frame) == params.num_of_frames,...
% 	'Number of frames is not equal to the given cell count per frame');
TDGStringAssertion(params.fm.probability_map_method,'probability map method','gmm','kde','voronoi');
TDGStringAssertion(params.fm.distance,'fm distance method','diff','geodesic');
end