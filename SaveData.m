function   SaveData(data,params,results)
% Save images,segmentations and ranks to
% ./Results/< data_set >/<dir_index>
% INPUTS:   ...
% OUTPUTS:  ...
max_directories         = 1000;
data_set                = params.cell_dataset;
current_folder          = pwd;
results_dir_name        = 'Results';
dir_content             = dir;
dir_content             = {dir_content([dir_content.isdir]).name};
N                       = params.num_of_frames;
flag = 1;
for i=1:numel(dir_content)
    if (strcmp(dir_content{i},results_dir_name))
        flag = 0;
        break
    end
end
if flag
    mkdir (sprintf('%s',results_dir_name));
end

results_dir     = strcat(current_folder,'/',results_dir_name);
dir_content     = dir(results_dir);
dir_content     = {dir_content([dir_content.isdir]).name};
data_set_dir    = strcat(results_dir,'/',data_set);
flag = 1;
for i=1:numel(dir_content)
    if (strcmp(dir_content{i},data_set))
        flag = 0;
        break
    end
end
if flag 
    mkdir (sprintf('%s',data_set_dir));
end
dir_content     = dir(data_set_dir);
dir_content     = {dir_content([dir_content.isdir]).name};

for j=1:max_directories
    flag = 1;
    for i=1:numel(dir_content)
        if (strcmp(dir_content{i},sprintf('%d',j)))
            flag = 0;
            break
        end
        
    end
    if flag
        dir_number = sprintf('%d',j);
        dir_name   = strcat(data_set_dir,'/',dir_number);
        mkdir (sprintf('%s',dir_name))
        break
    end
        
end

seg_dir         = sprintf('%s/seg',dir_name);
image_dir       = sprintf('%s/image',dir_name);
dir_content     = dir(dir_name);
dir_content     = {dir_content([dir_content.isdir]).name};

for i=1:numel(dir_content)
    if (strcmp(dir_content{i},'seg'))
        flag = 0;
        break
    end
end
if flag 
    mkdir (sprintf('%s',seg_dir));
end
for i=1:numel(dir_content)
    if (strcmp(dir_content{i},'image'))
        flag = 0;
        break
    end
end
if flag 
    mkdir (sprintf('%s',image_dir));
end

jaccard_ranks_file  = fopen(sprintf('%s/jaccard_ranks.json',dir_name),'w');
dice_ranks_file     = fopen(sprintf('%s/dice_ranks.json',dir_name),'w');
fprintf(jaccard_ranks_file,'{\n');
fprintf(dice_ranks_file,'{\n');

for n=1:N
    seg_path    = (sprintf('%s/%i.tiff',seg_dir,n));
    seg_file    = uint16(results.seg{n});
    image_path  = (sprintf('%s/%i.tiff',image_dir,n));
    image_file  = uint16(data.loaded_frame{n});
    size(seg_file)
    
    
    imwrite(seg_file,seg_path,'tiff');
    imwrite(image_file,image_path,'tiff');
    fprintf(jaccard_ranks_file,'"%d": %f,\n',n,results.jaccard_valid_seeds(n));
    fprintf(dice_ranks_file,'"%d": %f,\n',n,results.dice_valid_seeds(n));
end
fprintf(jaccard_ranks_file,'}');
fprintf(dice_ranks_file,'}');
fclose(jaccard_ranks_file);
fclose(dice_ranks_file);
end


