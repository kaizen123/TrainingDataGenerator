% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator 
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
	data.pp_frame{n} = TDGPreProcessing(data.loaded_frame{n}, params);
	data.seeds{n}    = TDGUserInput(data.loaded_frame{n}, params, n);
	data.features{n} = TDGExtractFeatures('frame', data.pp_frame{n}, params);
	 % TODO asaf - remove data copy, decide on one implementation
	if strcmp(params.fm.probability_map_method,'voronoi')
		data.masks{n} = data.features{n}.voronoi_mask;
	else
		data.masks{n} = data.features{n}.otsu;
	end
end
%% intensity distribution calculation for all frames together
alpha = params.fm.probability_map_alpha;
% calculate the fg (cells) and bg density functions based on using an unsupervised learning algorithm.
% use the results to calculate a probability function for the cells.
frames_3d_matrix = cat(3, data.pp_frame{:});
masks_3d_matrix  = cat(3, data.masks{:});
[fg_density, bg_density] = TDGFgBgDistributions(frames_3d_matrix, masks_3d_matrix, params);
gray_probability         = (alpha*fg_density) ./ (alpha*fg_density + (1-alpha)*bg_density);

%% fast marching per frame
for n = 1 : params.num_of_frames
	debug.index = n;
	I = data.pp_frame{n};
	data.features{n}.gray_probability_map = gray_probability(round(I) + 1);
	% test - asaf: need to recieve the mask when TDGFastMarchingMask is finished
	if size(data.seeds{n},1) ~= params.cell_count_per_frame(n)
		warning('Number of seeds is not equal to number of cells in frame %d', n);
	end
	results.seg{n} = TDGFastMarching(I, data.features{n}, data.seeds{n}, params);
	% test - asaf
end


