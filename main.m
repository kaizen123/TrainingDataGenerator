% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator
clear; clc; close all;
global debug;
debug = struct('enable', false);
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset = 'fluo-c2dl-msc';
use_user_input = false;

%% load data and parameters
params         = TDGLoadParams('script-shuffle', cell_dataset);
[data, params] = TDGLoadData('script-shuffle', params);

%% segmentation 

results = TDGSegmentBatch(data, params, use_user_input);
if debug.enable
   % save and reset debug struct
   debug_save = debug;
   debug = struct('enable', true);
end
    %{
    fprintf('method = %s\n', param.fm.probability_map_method)
    disp('jaccard');
    disp(results.jaccard_all*100);
    disp('dice');
    disp(results.dice_all*100);
    %}

