% initialize debug and test mode
% questions for Assaf -
% 1. mu calculation for FM?
% 2. why crop? how crop?
% 3. differance between first iterations and the rest
% 
global debug;
debug.clear = false;
debug.enable = true;

if debug.clear
	clear; clc; close all;
end
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset   = 'fluo-c2dl-msc';

%% load data and parameters
params         = TDGLoadParams('script', cell_dataset);
[data, params] = TDGLoadData('script', params); 

%% frames preprocessing and feature extraction
for n = 1 : params.num_of_frames
	debug.index = n;
	data.pp_frame{n}   = TDGPreProcessing(data.loaded_frame{n}, params);
	data.features{n}   = TDGExtractFeatures('frame', data.pp_frame{n}, params);
	data.otsu_masks{n} = data.features{n}.otsu; % TODO asaf - remove data copy, decide on one implementation
end

%% intensity distribution calculation
alpha = params.fm.probability_map_alpha;
% calculate the fg (cells) and bg density functions based on using an unsupervised learning algorithm.
% use the results to calculate a probability function for the cells.
frames_3d_matrix         = cat(3, data.pp_frame{:});
masks_3d_matrix          = cat(3, data.otsu_masks{:});
[fg_density, bg_density] = TDGFgBgDistributions(frames_3d_matrix, masks_3d_matrix, params);
gray_probability         = (alpha*fg_density) ./ (alpha*fg_density + (1-alpha)*bg_density);

for n = 1 : params.num_of_frames
	I  	= data.pp_frame{n};
	features.gray_probability_map = gray_probability(round(data.pp_frame{1}) + 1);
	% [~] = TDGFastMarchingMask(I, data.features{n}, params);
end

%% handle debug