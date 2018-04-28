
function [results] = TDGCalculateResults(seg, ground_truth, seeds, seeds_info, frame_index,s)
% returns the jaccard and dice results of the segmentation
% INPUTS:	seg - automatic segmentation frame
%           ground_truth - manual segmentation
%           seeds - seed for each cell in the frame
%           seeds_info - contains information about the correct label of the seed, and if the seed is inside the cell
%           frame_index - the frame on which we are working on
% OUTPUTS: 	results - the results struct we are working on
M = size(seeds, 1);
iou = zeros(M,1);
iou_valid = zeros(M,1);
for m = 1:M
    gt_label  = seeds_info(m).label;
    seg_label = seg(seeds(m,1), seeds(m,2));
    gt_mask   = zeros(size(ground_truth));
    gt_mask(ground_truth == gt_label) = 1;
    seg_mask = zeros(size(seg));
    seg_mask(seg == seg_label) = 1;
    cell_intersection = seg_mask & gt_mask;
    cell_union        = seg_mask | gt_mask;
    cell_intersection = sum(cell_intersection(:));
    cell_union        = sum(cell_union(:));
    iou(m)            = cell_intersection / cell_union; % intersection over union
    % iou_valid(m) = (cell_intersection / sum(gt_mask(:))) >= 0.5 ; % checks if the segmentation is valid
end

results.iou = iou;
results.iou_valid_seeds= iou([seeds_info.inside_cell]);
results.jaccard_all = mean(iou);
results.dice_all = 2*results.jaccard_all / (1 + results.jaccard_all);

% % valid results - at least 50% segmentation. else - we get 0 score
% results.jaccard_valid(frame_index) = mean(iou.*iou_valid);
% results.dice_valid(frame_index) = 2*results.jaccard_valid(frame_index) / (1 + results.jaccard_valid(frame_index));

% valid seed segmentation - input seed was inside the cell according to the ground truth
% else - we don't insert that score into the mean
results.jaccard_valid_seeds = mean(iou([seeds_info.inside_cell]));
results.dice_valid_seeds = 2*results.jaccard_valid_seeds / (1 + results.jaccard_valid_seeds);
%results.mean_dice_valid_seeds = mean(results.dice_valid_seeds,1);
%results.median_dice_valid_seeds = median(results.dice_valid_seeds,1);
%results.std_dice_valid_seeds = std(results.dice_valid_seeds,1);
end

