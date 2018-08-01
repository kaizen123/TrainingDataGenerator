% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator
clear; clc;  close all;
global debug;
debug = struct('enable', false);
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset = 'Fluo-C2DL-MSC';
use_user_input = false;

%% load data and parameters
params         = TDGLoadParams('script', cell_dataset);
[data, params] = TDGLoadData('script', params);

%% segmentation 

[data,results] = TDGSegmentBatch(data, params, use_user_input,params.initial_save_index );
if debug.enable
   % save and reset debug struct
   debug_save = debug;
   debug = struct('enable', true);
end

calculate_ranks_hist(results.crop_ranks,params);
%% display ranks
   %{
    for s=1:params.number_of_segmentation_per_frame
        for n = 1:params.num_of_frames
            fprintf('method = %s\n', params.fm.probability_map_method)
            disp('jaccard');
            disp(results.ranks{n,s}.jaccard_valid_seeds);
            disp('dice');
            disp(results.ranks{n,s}.dice_valid_seeds);
        end
        end
%}
   
  

