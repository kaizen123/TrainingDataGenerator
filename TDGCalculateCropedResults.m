 
function [results] = TDGCalculateCropedResults(seg, ground_truth)
% returns the jaccard and dice results of the segmentation
% INPUTS:	seg - automatic segmentation frame
%           ground_truth - manual segmentation
%           seeds - seed for each cell in the frame
%           seeds_info - contains information about the correct label of the seed, and if the seed is inside the cell
%           frame_index - the frame on which we are working on
% OUTPUTS: 	results - the results struct we are working on
%M = size(seeds, 1);
%iou = zeros(M,1);
%iou_valid = zeros(M,1);
%for m = 1:M
    m = min(seg(:));
    seg_label = m+1 ;
    gt_mask   = zeros(size(ground_truth));
    gt_mask(ground_truth ~= m) = m+1;
    seg_mask = zeros(size(seg));
    seg_mask(seg == seg_label) = m+1;
    cell_intersection = seg_mask & gt_mask;
    cell_union        = seg_mask | gt_mask;
    cell_intersection = sum(cell_intersection(:));
    cell_union        = sum(cell_union(:));
    iou               = cell_intersection / cell_union; % intersection over union
    % iou_valid(m) = (cell_intersection / sum(gt_mask(:))) >= 0.5 ; % checks if the segmentation is valid

results.iou = iou;
results.jaccard_all = mean(iou);
results.dice_all = 2*results.jaccard_all / (1 + results.jaccard_all);

end

