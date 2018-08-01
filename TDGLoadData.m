
function [data, params] = TDGLoadData(source_type, params)
% load data for the Training Data Generator, and params based on the loaded data
% INPUTS:   source_type: source_type of the data,
%                   'script' for the use of this script default values.
%                   'struct' for a different parameters struct.
%			params: parameters struct for the TDG
%           pointer: for 'text' it is the address of the file for input data
%                    for 'struct' it is the struct of data
% OUTPUTS:  data: data struct for the TDG

assert(strcmp(source_type, 'script') | strcmp(source_type, 'struct') |strcmp(source_type,'script-shuffle'), 'source_type not supported');
if strcmp(source_type, 'script') || strcmp(source_type,'script-shuffle')
	iter = 0;
	n = 1;
	switch params.cell_dataset
	case 'Fluo-N2DH-SIM+'
		while(n <= params.num_of_frames && iter < 200)
			train_data_string = fullfile('Fluo-N2DH-SIM+','02',sprintf('t%03d.tif', iter));
			train_labels_string = fullfile('Fluo-N2DH-SIM+','02_GT','SEG',sprintf('man_seg%03d.tif', iter));
			% load only if we have train labels for current, and more than 2 cells in the frame
			if exist(train_labels_string,'file')
				ground_truth = TDGLoadDoubleImage(train_labels_string);
				if max(ground_truth(:)) > 2
					data.ground_truth{n} = ground_truth;
					data.loaded_frame{n} = TDGLoadDoubleImage(train_data_string);
					n = n + 1;
				end
            end
            disp(iter)
			iter = iter + 1;
        end
    case 'Fluo-N2DH-GOWT1'
		while(n <= params.num_of_frames && iter < 200)
			train_data_string = fullfile('Fluo-N2DH-GOWT1','01',sprintf('t0%02d.tif', iter));
			train_labels_string = fullfile('Fluo-N2DH-GOWT1','01_GT','SEG',sprintf('man_seg0%02d.tif', iter));
			% load only if we have train labels for current, and more than 2 cells in the frame
			if exist(train_labels_string,'file')
				ground_truth = TDGLoadDoubleImage(train_labels_string);
				if length(unique(ground_truth(:))) > 3 
					data.ground_truth{n} = ground_truth;
					data.loaded_frame{n} = TDGLoadDoubleImage(train_data_string);
					n = n + 1;
				end
			end
			iter = iter + 1;
        end
        
        case 'Fluo-C2DL-MSC'
		while(n <= params.num_of_frames && iter < 200)
			train_data_string = fullfile('Fluo-C2DL-MSC','02',sprintf('t0%02d.tif', iter));
			train_labels_string = fullfile('Fluo-C2DL-MSC','02_GT','SEG',sprintf('man_seg0%02d.tif', iter));
			% load only if we have train labels for current, and more than 2 cells in the frame
			if exist(train_labels_string,'file')
				ground_truth = TDGLoadDoubleImage(train_labels_string);
				if max(ground_truth(:)) > 2
					data.ground_truth{n} = ground_truth;
					data.loaded_frame{n} = TDGLoadDoubleImage(train_data_string);
					n = n + 1;
				end
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

