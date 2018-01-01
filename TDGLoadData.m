function [data, params] = TDGLoadData(source_type, params)
% load data for the Training Data Generator, and params based on the loaded data
% INPUTS:   source_type: source_type of the data,
%                   'script' for the use of this script default values.
%                   'struct' for a different parameters struct.
%			params: parameters struct for the TDG
%           pointer: for 'text' it is the address of the file for input data
%                    for 'struct' it is the struct of data
% OUTPUTS:  data: data struct for the TDG

assert(strcmp(source_type, 'script') | strcmp(source_type, 'struct'), 'source_type not supported');
if strcmp(source_type, 'script')
	iter = 0;
	n = 1;
	switch params.cell_dataset
	case 'fluo-c2dl-msc'
		while(n <= params.num_of_frames && iter < 200)
			%train_labels_string  = sprintf('Data/%s/TrainLabels/ManualSeg_%d.tif', params.cell_dataset, iter);
			%train_data_string    = sprintf('Data/%s/TrainData/t00%d.tif', params.cell_dataset, iter-1);
			train_data_string = fullfile('Fluo-C2DL-MSC','01',sprintf('t0%02d.tif', iter));
			train_labels_string = fullfile('Fluo-C2DL-MSC','01_GT','SEG',sprintf('man_seg0%02d.tif', iter));
			% load only if we have train labels for current
			if exist(train_labels_string,'file')
				data.ground_truth{n} = TDGLoadDoubleImage(train_labels_string);
				data.loaded_frame{n} = TDGLoadDoubleImage(train_data_string);
				n = n + 1;
			end
			iter = iter + 1;
		end
	otherwise
	end

	params.data_class = class(data.loaded_frame{1});
	if strcmp(params.data_class, 'uint8')
		params.fm.dens_x = (0:(2^8-1))';
		params.fm.max_gray = 2^8-1;
	else
		params.fm.dens_x = (0:(2^16-1))';
		params.fm.max_gray = 2^16-1;
	end
end
end

