% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator
clear; clc;
global debug;
debug.enable = true;
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset   = 'fluo-c2dl-msc';
user_input	   = false;

%% load data and parameters
params         = TDGLoadParams('script', cell_dataset);
[data, params] = TDGLoadData('script', params);
N = params.num_of_frames;
%% frames preprocessing and feature extraction
for n = 1 : N
	debug.index = n;
	data.pp_frame{n} = TDGPreProcessing(data.loaded_frame{n}, params);
	if user_input
		data.seeds{n} = TDGUserInput(data.loaded_frame{n}, params, n);
	else
		[data.seeds{n}, params] = TDGAutoInput(data.ground_truth{n}, params, n);
	end
	data.features{n} = TDGExtractFeatures('frame', data.pp_frame{n}, params, data.seeds{n});
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
% gray probability is cell in case of voronoi, or matrix in case of gmm/kde
[gray_probability] = TDGFgBgDistributions(frames_3d_matrix, masks_3d_matrix, params,data);
if debug.enable
	if strcmp(params.fm.probability_map_method,'kde')
		plot(gray_probability);
	end
end
%% fast marching per frame
for n = 1 : N
	debug.index = n;
	M = size(data.seeds{n},1);
	I = data.pp_frame{n};
     if strcmp(params.fm.probability_map_method,'voronoi') % case of voronoi
     	data.features{n}.gray_probability_map = zeros(size(I));
     	voronoi_crop = cell(M,1);
     	for m = 1:M
     		voronoi_crop{m} = I(data.masks{n}==m);
     		data.features{n}.gray_probability_map(data.masks{n}==m) = gray_probability{n,m}(round(voronoi_crop{m}) + 1);
     	end
     else
     	data.features{n}.gray_probability_map = gray_probability(round(I)+1); % case of gmm or kde 
     end
     
     if M ~= params.cell_count_per_frame(n)
     	warning('Number of seeds is not equal to number of cells in frame %d', n);
     end
     results.seg{n} = TDGFastMarching(I, data.features{n}, data.seeds{n}, params);
     figure;
     subplot(1,2,1); imagesc(results.seg{n}); title(sprintf('Automatic Segmentation, method = %s', params.fm.probability_map_method));
     subplot(1,2,2); imagesc(data.ground_truth{n}); title('Manual Segmentation');

 end
%% results - move to new function

results.jaccard_all   = zeros(N,1);
results.dice_all      = zeros(N,1);
results.jaccard_valid = zeros(N,1);
results.dice_valid    = zeros(N,1);
for n = 1 : N
	debug.index = n;
	seg = results.seg{n};
	ground_truth = data.ground_truth{n};
	seeds = data.seeds{n};
	M = size(data.seeds{n}, 1);
	iou = zeros(M,1);
	iou_valid = zeros(M,1);
	for m = 1:M
		gt_label = ground_truth(data.seeds{n}(m,1), data.seeds{n}(m,2)); % TODO amanor - check if x and y are not switched
		seg_label = seg(data.seeds{n}(m,1), data.seeds{n}(m,2)); % TODO amanor - check if x and y are not switched
		gt_mask = zeros(size(ground_truth));
		gt_mask(ground_truth == gt_label) = 1;
		seg_mask = zeros(size(seg));
		seg_mask(seg == seg_label) = 1;
		cell_intersection = seg_mask & gt_mask;
		cell_union = seg_mask | gt_mask;
		cell_intersection = sum(cell_intersection(:));
		cell_union = sum(cell_union(:));
		iou(m) = cell_intersection / cell_union; % intersection over union
		iou_valid(m) = (cell_intersection / sum(gt_mask(:))) >= 0.5 ; % checks if the segmentation is valid
	end

	results.jaccard_all(n) = mean(iou);
	results.dice_all(n) = 2*results.jaccard_all(n) / (1 + results.jaccard_all(n));
	results.jaccard_valid(n) = mean(iou.*iou_valid);
	results.dice_valid(n) = 2*results.jaccard_valid(n) / (1 + results.jaccard_valid(n));

end
disp('jaccard');
disp(results.jaccard_valid);
disp('dice');
disp(results.dice_valid);