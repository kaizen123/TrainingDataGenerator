function [seeds, params] = TDGAutoInput(ground_truth, params, index)
% outputs auto seeds based on ground truth

S = size(ground_truth);
params.cell_count_per_frame(index) = max(ground_truth(:));
L = params.cell_count_per_frame(index);
seeds = zeros(L,2);
for label = 1:L % not including background
	mask = find(ground_truth == label);
    [x,y] = ind2sub(S, mask);
	seeds(label,:) = round(mean([x,y]));
end