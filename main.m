% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator
clear; clc;  close all;
global debug;
debug = struct('enable', false);
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset = 'Fluo-N2DH-SIM+';
use_user_input = false;

%% load data and parameters
params         = TDGLoadParams('script-shuffle', cell_dataset);
[data, params] = TDGLoadData('script-shuffle', params);

%% segmentation 

results = TDGSegmentBatch(data, params, use_user_input,0);
if debug.enable
   % save and reset debug struct
   debug_save = debug;
   debug = struct('enable', true);
end
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
   
  

