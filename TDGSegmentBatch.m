function [results] = TDGSegmentBatch(data, params, user_input,initial_index)
global debug;
params.num_of_frames = min([params.num_of_frames length(data.loaded_frame)]);
N = params.num_of_frames;
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
            data.features{n,s} = TDGExtractFeatures('frame', data.pp_frame{n,s}, params, data.seeds{n},s);
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
    try
        results.seg{n,s} = TDGFastMarching(I, data.features{n,s}, data.seeds{n}, params,s);
    catch ME
        if strcmp(ME.identifier,'MATLAB:assertion:failed')
            disp('FM ERROR')
            continue
        end
    end
        
    %figure;
    %subplot(1,2,1); imagesc(results.seg{n,s}); title(sprintf('Automatic Segmentation, method = %s',...
     %   params.fm.probability_map_method(s)));
    %subplot(1,2,2); imagesc(data.ground_truth{n}); title('Manual Segmentation');
    

end

end
if ~params.crop_segmentation
    for n = 1 : N
        debug.index = n;
        for s = 1 : S 
            results.ranks{n,s} = TDGCalculateResults(results.seg{n,s}, data.ground_truth{n}, data.seeds{n}, data.seeds_info{n}, n,s); 
    
        end
    end
else 

%%% crop segmentation %%%

    croped_seg          = cell(N,S+1);    %3D matrix (image per each seed)
    croped_ground_truth = cell(N,S);    %3D matrix (image per each seed)
    croped_loaded_frame = cell(N);    %3D matrix (image per each seed)
    COM                 = cell(N,S);    %2D matrix (x,y cord per each seed)
    
    % for convenient use:
    MAX_CELLS = 100;
    data.croped_seeds_info.label        = 1;
    data.croped_seeds_info.inside_cell  = 1;
    data.croped_ground_truth            = cell(N,S,MAX_CELLS);
    results.crop_seg                    = cell(N,S+1,MAX_CELLS);
    data.crop_loaded_frame              = cell(N,MAX_CELLS);
    results.crop_ranks                  = cell(N,S+1,MAX_CELLS);
  
 
    for n = 1 : N
        I = size(data.seeds{n},1);
        for s = 1 : S  % ground truth
            %if isempty(results.seg{n,s})
             %   continue;
            %end
            [croped_seg{n,s},croped_ground_truth{n,s},croped_loaded_frame{n},COM{n,s}]...
                    = TDGCalculateComCrop(data,results.seg{n,s},params.crop_size,n);
            m1 = min(croped_ground_truth{n,s}(:));
            m2 = min(croped_seg{n,s}(:));
            croped_ground_truth{n,s}(croped_ground_truth{n,s}==m1) = 0 ;
            croped_ground_truth{n,s}(croped_ground_truth{n,s}~=0) = 1 ;
            croped_seg{n,s}(croped_seg{n,s}==m2) = 0;
            croped_seg{n,s}(croped_seg{n,s}~=0 ) = 1;
            
            for i = 1 : I
                
                data.crop_loaded_frame{n,i}     = squeeze(croped_loaded_frame{n}(i,:,:));
                results.crop_seg{n,s,i}         = squeeze(croped_seg{n,s}(i,:,:));
                data.croped_ground_truth{n,s,i} = squeeze(croped_ground_truth{n,s}(i,:,:));
                
                %results.crop_ranks{n,s,i}       = TDGCalculateResults(results.crop_seg{n,s,i},...
                   %data.croped_ground_truth{n,s,i},COM{n,s}(i,:),data.croped_seeds_info, n,s);
                   results.crop_ranks{n,s,i}       = TDGCalculateCropedResults(results.crop_seg{n,s,i},...
                   data.croped_ground_truth{n,s,i});

            end
        end
    end
    
    save_data = true;
    if save_data 
        add_groundtruth = true;
        TDGSaveCropedData(data,params,results,add_groundtruth,initial_index);
    end
end

if ~params.crop_segmentation
% this parameter determines whether to include ground truth in the
% segmentation collection or not.
    save_data = true;
    if save_data 
        add_groundtruth = true;
        TDGSaveData(data,params,results,add_groundtruth,0);
    end
end

end
        