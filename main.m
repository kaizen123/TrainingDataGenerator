%% load data and parameters
clear; clc; close all;

disp('Welcome to the Training Data Generator for HRM Cell images!')
params 	= TDGLoadParams('script', 'fluo-c2dl-msc');
data 	= TDGLoadData('script', 'fluo-c2dl-msc'); 

%% frames preprocessing
for n = [1 : params.number_of_frames]
	data.pp_frame{n} = TDGPreProcessing(data.loaded_frame{n}, params);
	data.features{n} = TDGExtractFeatures('frame', data.pp_frame{n});
end