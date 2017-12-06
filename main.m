% initialize debug and test mode
% questions for Assaf -
% 1. mu calculation for FM?
% 2. why crop? how crop?
% 3. differance between first iterations and the rest

% Working dir: /Users/asafmanor/Documents/GitHub/TrainingDataGenerator 
test.clear = true;

if test.clear
	clear variables; clc; close all;
end

global debug;
debug.enable = true;
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset   = 'fluo-c2dl-msc';

%% load data and parameters
params         = TDGLoadParams('script', cell_dataset);
[data, params] = TDGLoadData('script', params); 

%% frames preprocessing and feature extraction
for n = 1 : params.num_of_frames
	debug.index = n;
	data.pp_frame{n}                         = TDGPreProcessing(data.loaded_frame{n}, params);
	data.seeds{n}                            = TDGUserInput(data.loaded_frame{n}, params, n);
	data.features{n}                        = TDGExtractFeatures('frame', data.pp_frame{n}, params);
	data.otsu_masks{n}                      = data.features{n}.otsu; % TODO asaf - remove data copy, decide on one implementation
    for m = 1:size(data.seeds{n},1)
        [data.crop{n}.cell{m} data.crop{n}.index{m}] = CropImage(data.pp_frame{n},data.seeds{n}(m,:),params);  
    end 
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
	debug.index = n;
	I = data.pp_frame{n};
	data.features{n}.gray_probability_map = gray_probability(round(I) + 1);
	% test - asaf: need to recieve the mask when TDGFastMarchingMask is finished
	TDGFastMarchingMask(I, data.features{n}, data.seeds{n}, params);
	% test - asaf
end

%% handle debug
diff_dist      = debug.frame{1}.diff_dist;
geodesic_dist  = debug.frame{1}.geodesic_dist; % assaf says better
euclidean_dist = debug.frame{1}.euclidean_dist;


