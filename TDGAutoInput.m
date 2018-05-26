function [seeds, seeds_info, ground_truth, params] = TDGAutoInput(ground_truth, params, frame_index)
% outputs auto seeds based on ground truth labels
% seeds are produced in the center of mass location of each cell
% with an added gaussian noise in the two axes
% the function deals with the case of multiple connected components marked on the same label,
% by applying new labels to second (and forth) components on that same label
sigma = 0;
global debug
L = max(ground_truth(:));
% in case we need new labels, we start the count from the last original label up.
new_label = L + 1;
current_cell = 0;
for label = 1:L % not including background
    mask = (ground_truth == label);
    required_props = {'Centroid', 'BoundingBox', 'Area', 'PixelIdxList'};
    props = regionprops(mask, required_props);
    props = props([props.Area] > 10); % eliminate connected components noise
    for idx = 1:size(props,1) 
        % if there is more than one connected componenet, we change the label
        if idx > 1
            ground_truth(props(idx).PixelIdxList) = new_label;
            correct_label = new_label;
            new_label = new_label + 1;
        else
            correct_label = label;
        end
        current_cell = current_cell + 1;
        centroid = props(idx).Centroid;
        bounding_box = props(idx).BoundingBox;
        var_cols = sigma * (bounding_box(2) + bounding_box(4)/2);
        var_rows = sigma * (bounding_box(1) + bounding_box(3)/2); % x + width(x)/2
        seeds(current_cell,:) = round([centroid(2) + sqrt(var_cols)*randn(), centroid(1) + sqrt(var_rows)*randn()]);
        seeds_info(current_cell).label = correct_label; % fixed label
        seeds_info(current_cell).inside_cell = ...
            (ground_truth(seeds(current_cell,1), seeds(current_cell,2)) == correct_label); % is the seed inside the cell?
        if seeds_info(current_cell).inside_cell == false && debug.enable
            warning('seed number %d is not inside the cell with label %d', current_cell, correct_label)
            fprintf('frame #%d : centroid location is:', frame_index)
            disp(centroid)
            fprintf('ground_truth at centroid location:')
            disp(ground_truth(round(centroid(2)), round(centroid(1))))
            fprintf('ground_truth at centroid + noise location:')
            disp(ground_truth(seeds(current_cell,1), seeds(current_cell,2)))
            fprintf('correct label is %d\n', correct_label)
        end
    end
end
params.cell_count_per_frame(frame_index) = current_cell;