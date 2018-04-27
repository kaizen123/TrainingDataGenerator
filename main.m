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
default_params         = TDGLoadParams('script-shuffle', cell_dataset);
[data, default_params] = TDGLoadData('script-shuffle', default_params);
% here we should load non-default parameters and run to compare results
params{1} = default_params;
params{1}.fm.probability_map_method = 'kde';
params{1}.th = 0.015;

params{2} = default_params;
params{2}.fm.probability_map_method = 'voronoi';
params{2}.voronoi.num_of_bg_gaussians = 3;
params{2}.voronoi.num_of_fg_gaussians = 2

params{3} = default_params;
params{3}.fm.probability_map_method = 'voronoi';
params{3}.voronoi.num_of_bg_gaussians = 1;
params{3}.voronoi.num_of_fg_gaussians = 1;

params{4} = default_params;
params{4}.fm.probability_map_method = 'voronoi';
params{4}.voronoi.num_of_bg_gaussians = 2;
params{4}.voronoi.num_of_fg_gaussians = 2;

params{5} = default_params;
params{5}.fm.probability_map_method = 'voronoi';
params{5}.voronoi.num_of_bg_gaussians = 3;
params{5}.voronoi.num_of_fg_gaussians = 1;

params{6} = default_params;
params{6}.fm.probability_map_method = 'voronoi';
params{6}.voronoi.num_of_bg_gaussians = 2;
params{6}.voronoi.num_of_fg_gaussians = 1;

runs = 6:6;

%% segmentation for each run
for r = runs
    results{r} = TDGSegmentBatch(data, params{r}, use_user_input);
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

%% results display , manipulation etc
%{
col=@(x)reshape(x,numel(x),1);
boxplot2=@(C,varargin)boxplot(cell2mat(cellfun(col,col(C),'uni',0)),...
    cell2mat(arrayfun(@(I)I*ones(numel(C{I}),1),col(1:numel(C)),'uni',0)),varargin{:});

close all;
for r = runs
    figure;
    boxplot2(results{r}.iou_valid_seeds);
end 
%}
