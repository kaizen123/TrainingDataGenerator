function [results] = TDGSegmentBatch(data, params, user_input)
global debug;
N = params.num_of_frames;
N = length(data.loaded_frame);
S = params.number_of_segmentation_per_frame;
%% frames preprocessing and feature extraction

for n = 1 : N
        debug.index = n;
        if user_input
            data.seeds{n} = TDGUserInput(data.loaded_frame{n}, params, n);
        else
            [data.seeds{n}, data.seeds_info{n}, data.ground_truth{n}, params] = TDGAutoInput(data.ground_truth{n}, params, n);
        end
        for s = 1 : S
            data.pp_frame{n,s} = TDGPreProcessing(data.loaded_frame{n}, params,s);

            %if debug.enable
            %figure;
            %subplot(1,2,1);
            %imshow(data.pp_frame{n,s},[]);
            %hold on; plot(data.seeds{n}(:,2), data.seeds{n}(:,1), 'r*');
            %subplot(1,2,2);
            %imshow(data.ground_truth{n},[]);
            %end   
            data.features{n,s} = TDGExtractFeatures('frame', data.pp_frame{n}, params, data.seeds{n},s);
            if strcmp(params.fm.probability_map_method, 'voronoi')
                data.masks{n,s} = data.features{n,s}.voronoi_mask;
            else
                data.masks{n,s} = data.features{n,s}.otsu;
            end
        end
end

%% intensity distribution calculation for all frames together
% calculate the fg (cells) and bg density functions based on unsupervised learning algorithm.
% use the results to calculate a probability function for the cells.
for s = 1 : S
    frames_3d_matrix = cat(3, data.pp_frame{:,s});
    masks_3d_matrix  = cat(3, data.masks{:,s});
    % gray probability is a cell array in case of voronoi, or matrix in case of gmm/kde
    gray_probability = TDGFgBgDistributions(frames_3d_matrix,masks_3d_matrix, params, data,s);
%% fast marching per frame
for n = 1 : N
    debug.index = n;
    M = size(data.seeds{n},1);
        I = data.pp_frame{n,s};
        if strcmp(params.fm.probability_map_method(s),'voronoi') % case of voronoi
            data.features{n,s}.gray_probability_map = zeros(size(I));
            voronoi_crop = cell(M,1);
            for m = 1:M
                voronoi_crop{m} = I(data.masks{n}==m);
                data.features{n,s}.gray_probability_map(data.masks{n,s}==m) = gray_probability{n,m}(round(voronoi_crop{m}) + 1);
            end
        else
            data.features{n,s}.gray_probability_map = gray_probability(round(I)+1); % case of gmm or kde
        end
    
    if M ~= params.cell_count_per_frame(n)
        warning('Number of seeds is not equal to number of cells in frame %d', n);
    end
    results.seg{n,s} = TDGFastMarching(I, data.features{n,s}, data.seeds{n}, params,s);
    figure;
    %subplot(1,2,1); imagesc(results.seg{n,s}); title(sprintf('Automatic Segmentation, method = %s',...
     %   params.fm.probability_map_method(s)));
    %subplot(1,2,2); imagesc(data.ground_truth{n}); title('Manual Segmentation');
    

end

end

for n = 1 : N
    debug.index = n;
    for s = 1 : S 
        results.ranks{n,s} = TDGCalculateResults(results.seg{n,s}, data.ground_truth{n}, data.seeds{n}, data.seeds_info{n}, n,s); 
    
    end
end

TDGSaveData(data,params,results);

end