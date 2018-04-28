
function [params] = TDGShuffleParams(params,shuffle_rate)
% " "
% INPUTS:	
% OUTPUTS:  params: parameters struct for the TDG

N            = params.number_of_segmentation_per_frame;
if shuffle_rate<0
    shuffle_rate = 0;
end
shuffle_factor  = 1 - 1/(1+log(sqrt(shuffle_rate+1)));  
random_numer    = [zeros(1,floor(shuffle_factor*N)) ones(1,N-floor(shuffle_factor*N))];
random_logic    = logical(random_numer);
frac_factor     = log10(sqrt(shuffle_factor+1)); 
random_frac     = linspace(1 - frac_factor,1+frac_factor,N);
method_dict     = ["voronoi","voronoi"];



switch params.cell_dataset
	case 'fluo-c2dl-msc'
		params.th 			                = 0.012*(1+abs(normrnd(0,log10(shuffle_rate),1,N)));
		
		%params.cell_count_per_frame         = [9 9 8 8 2 ];
		params.convex_cell_shapes           = false;
		params.crop_size                    = [250 250];
		% PreProcessing parameters
		params.pp.remove_bg_lighting.enable = random_logic(randperm(length(random_logic)));
		params.pp.remove_bg_lighting.sigma  = 100*random_frac(randperm(length(random_frac)));
		params.pp.median_filter.enable      = random_logic(randperm(length(random_logic)));
		params.pp.median_filter.size        = [3 3];
		params.pp.gaussian_filter.enable    = random_logic(randperm(length(random_logic),N));
        params.pp.gaussian_filter.sigma     = 3*random_frac(randperm(length(random_frac)));
		
        % Voronoi parameters
        params.voronoi.num_of_bg_gaussians = 1+round(abs(normrnd(0,log10(shuffle_rate+1),1,N)));
        params.voronoi.num_of_fg_gaussians = 1+round(abs(normrnd(0,log10(shuffle_rate+1),1,N)));
		% FastMarching parameters
		params.fm.distance 					= 'diff';
		params.fm.k = 5; % std multiplier factor in the inverse gradient
		params.fm.q = 2; % std power factor in the inverse gradient
		params.fm.probability_map_method 	= method_dict(randi([1 length(method_dict)],1,N));
		params.fm.probability_map_alpha 	= rand(1,N);
		%if strcmp(params.fm.probability_map_method,'gmm')	 
		%	params.fm.foreground_n_gaussians = 1+round(abs(normrnd(0,log10(shuffle_rate+1),1,N)));
		%	params.fm.background_n_gaussians = 1+round(abs(normrnd(0,log10(shuffle_rate+1),1,N)));
end
	end