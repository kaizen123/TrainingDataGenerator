%% load data and parameters
clear; clc; close all;

disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset = 'fluo-c2dl-msc';
params       = TDGLoadParams('script', cell_dataset);
data         = TDGLoadData('script', params); 

%% frames preprocessing
for n = 1 : params.num_of_frames
	data.pp_frame{n} = TDGPreProcessing(data.loaded_frame{n}, params);
	data.features{n} = TDGExtractFeatures('frame', data.pp_frame{n});
	% data.fg_probability_map{n} = TDGProbabilityMap(data.pp_frame{n}, data, params);
end