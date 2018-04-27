function [results] = TDGSegmentBatch(data, params, user_input)
global debug;
N = params.num_of_frames;
%% frames preprocessing and feature extraction
for n = 1 : N
    debug.index = n;
    data.pp_frame{n} = TDGPreProcessing(data.loaded_frame{n}, params);
    if user_input
        data.seeds{n} = TDGUserInput(data.loaded_frame{n}, params, n);
    else
        [data.seeds{n}, data.seeds_info{n}, data.ground_truth{n}, params] = TDGAutoInput(data.ground_truth{n}, params, n);
    end
    if debug.enable
        figure;
        subplot(1,2,1);
        imshow(data.pp_frame{n},[]);
        hold on; plot(data.seeds{n}(:,2), data.seeds{n}(:,1), 'r*');
        subplot(1,2,2);
        imshow(data.ground_truth{n},[]);
    end
    data.features{n} = TDGExtractFeatures('frame', data.pp_frame{n}, params, data.seeds{n});
    if strcmp(params.fm.probability_map_method, 'voronoi')
        data.masks{n} = data.features{n}.voronoi_mask;
    else
        data.masks{n} = data.features{n}.otsu;
    end
end

%% intensity distribution calculation for all frames together
% calculate the fg (cells) and bg density functions based on unsupervised learning algorithm.
% use the results to calculate a probability function for the cells.
frames_3d_matrix = cat(3, data.pp_frame{:});
masks_3d_matrix  = cat(3, data.masks{:});
% gray probability is a cell array in case of voronoi, or matrix in case of gmm/kde
[gray_probability] = TDGFgBgDistributions(frames_3d_matrix, masks_3d_matrix, params, data);

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
    subplot(1,2,1); imagesc(results.seg{n}); title(sprintf('Automatic Segmentation, method = %s',...
        params.fm.probability_map_method));
    subplot(1,2,2); imagesc(data.ground_truth{n}); title('Manual Segmentation');
    
end

for n = 1 : N
    debug.index = n;
    results = TDGCalculateResults(results.seg{n}, data.ground_truth{n}, data.seeds{n}, data.seeds_info{n}, results, n); 
    
end

TDGSaveData(data,params,results);

end