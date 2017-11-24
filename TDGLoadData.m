function [data] = TDGLoadData(source_type, cell_dataset, pointer)
% load data for the Training Data Generator
% INPUTS:   source_type: source_type of the data,
%                   'text' from a text-file.
%                   'script' for the use of this script default values.
%                   'struct' for a different parameters struct.
%			cell_dataset: string, the dataset to run on.
%           pointer: for 'text' it is the address of the file for input data
%                    for 'struct' it is the struct of data
% OUTPUTS:  data: data struct for the TDG

if strcmp(source_type, 'script')
	switch cell_dataset
	case 'fluo-c2dl-msc'
		% TODO asaf - change to a for loop with automatic string creation
		data.ground_truth{1} = TDGLoadDoubleImage('TrainLabels/ManualSeg_1.tif');
		data.ground_truth{2} = TDGLoadDoubleImage('TrainLabels/ManualSeg_2.tif');
		data.loaded_frame{1} = TDGLoadDoubleImage('TrainData/t001.tif');
		data.loaded_frame{2} = TDGLoadDoubleImage('TrainData/t002.tif');
	otherwise
	end
end
end

