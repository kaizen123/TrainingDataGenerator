function   TDGSaveData(data,params,results)
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
S                       = params.number_of_segmentation_per_frame;
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

if ~params.multiple_segmentation_per_frame_enable 

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
    
else 
    dir_name = data_set_dir;
end

image_dir       = sprintf('%s/image',dir_name);
dir_content     = dir(dir_name);
dir_content     = {dir_content([dir_content.isdir]).name};

flag = 1;
for i=1:numel(dir_content)
   if (strcmp(dir_content{i},'image'))
      flag = 0;
      break
   end
end
if flag 
   mkdir (sprintf('%s',image_dir));
end

for s = 1 : S
    flag = 1;
    seg_dir = sprintf('%s/seg_%s',dir_name,num2str(s,'%03d'));
    for i=1:numel(dir_content)
        if (strcmp(dir_content{i},sprintf('seg_%s',num2str(s,'%03d'))))
            flag = 0;
            break
        end
    end
    if flag 
        mkdir (sprintf('%s',seg_dir));
    end
end 

for s = 1 :S
    
    jaccard_ranks_file  = fopen(sprintf('%s/jaccard_ranks_%s.json',dir_name,num2str(s,'%03d')),'w');
    dice_ranks_file     = fopen(sprintf('%s/dice_ranks_%s.json',dir_name,num2str(s,'%03d')),'w');
    fprintf(jaccard_ranks_file,'{\n');
    fprintf(dice_ranks_file,'{\n');
    seg_dir             = strcat(dir_name,sprintf('/seg_%s',num2str(s,'%03d')));

    for n=1:N
        seg_path    = (sprintf('%s/%s.tiff',seg_dir,num2str(n,'%03d')));
        seg_file    = uint16(results.seg{n,s});
        if s==1
            image_path  = (sprintf('%s/%s.tiff',image_dir,num2str(n,'%03d')));
            image_file  = uint16(data.loaded_frame{n});
        end
        imwrite(seg_file,seg_path,'tiff');
        if s==1
            imwrite(image_file,image_path,'tiff');
        end
        if n==N
            fprintf(jaccard_ranks_file,'"%d": %f\n',n,results.ranks{n,s}.jaccard_valid_seeds);
            fprintf(dice_ranks_file,'"%d": %f\n',n,results.ranks{n,s}.dice_valid_seeds);
        else
            fprintf(jaccard_ranks_file,'"%d": %f,\n',n,results.ranks{n,s}.jaccard_valid_seeds);
            fprintf(dice_ranks_file,'"%d": %f,\n',n,results.ranks{n,s}.dice_valid_seeds);
        end
    end
    fprintf(jaccard_ranks_file,'}');
    fprintf(dice_ranks_file,'}');
    fclose(jaccard_ranks_file);
    fclose(dice_ranks_file);
    

end    
    
    
    
end


