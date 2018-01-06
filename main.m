% initialize debug and test mode
% cd /Users/asafmanor/Documents/GitHub/TrainingDataGenerator
clear; clc; close all;
global debug;
debug = struct('enable', true);
%% primary parameters - dataset, test method, debug etc.
disp('Welcome to the Training Data Generator for HRM Cell images!')
cell_dataset   = 'fluo-c2dl-msc';
user_input	   = false;

%% load data and parameters
default_params         = TDGLoadParams('script', cell_dataset);
[data, default_params] = TDGLoadData('script', default_params);
% here we should load non-default parameters and run to compare results
number_of_runs = 2;
params{1} = default_params;
params{1}.fm.probability_map_method = 'kde';
params{2} = default_params;
params{2}.fm.probability_map_method = 'voronoi';
for r = 1:number_of_runs
    results{r} = TDGSegmentBatch(data, params{r}, user_input);
    if debug.enable
        % save and reset debug struct
        debug_save{r} = debug;
        debug = struct('enable', true);
    end
    fprintf('method = %s\n', params{r}.fm.probability_map_method)
    disp('jaccard');
    disp(results{r}.jaccard_all*100);
    disp('dice');
    disp(results{r}.dice_all*100);
end