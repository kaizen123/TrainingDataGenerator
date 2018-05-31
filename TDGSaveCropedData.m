function   TDGSaveCropedData(data,params,results,add_groundtruth,initial_index,num_of_dist_segs)
% Save images,segmentations and ranks to
% ./Results/< data_set >/<dir_index>
% INPUTS:   ...
% OUTPUTS:  ...
if nargin == 3
    add_groundtruth = false;
end
max_directories         = 1000;
data_set                = params.cell_dataset;
current_folder          = pwd;
results_dir_name        = 'Results';
dir_content             = dir;
dir_content             = {dir_content([dir_content.isdir]).name};
N                       = params.num_of_frames;
S                       = params.number_of_segmentation_per_frame+num_of_dist_segs;

if add_groundtruth
    S = S + 1;
end

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
    dir_name = strcat(data_set_dir,'/',params.local_dir_name);
end

% create image dir
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

% Create seg dirs
for s = 1 : S
    flag = 1;
    seg_dir = sprintf('%s/seg_%s',dir_name,num2str(s,'%05d'));
    for i=1:numel(dir_content)
        if (strcmp(dir_content{i},sprintf('seg_%s',num2str(s,'%05d'))))
            flag = 0;
            break
        end
    end
    if flag 
        mkdir (sprintf('%s',seg_dir));
    end
end 
%concat ground_truth
for s = 1 :S 
    if add_groundtruth && s==S 
        for n=1:N
            I = size(data.seeds{n},1);
            for i = 1 : I
                results.crop_seg{n,s,i} = data.croped_ground_truth{n,s-1,i};
            end
        end
    end
          
    jaccard_ranks_file  = fopen(sprintf('%s/jaccard_ranks_%s.json',dir_name,num2str(s,'%05d')),'a');
    dice_ranks_file     = fopen(sprintf('%s/dice_ranks_%s.json',dir_name,num2str(s,'%05d')),'a');
    fprintf(jaccard_ranks_file,'{\n');
    fprintf(dice_ranks_file,'{\n');
    seg_dir             = strcat(dir_name,sprintf('/seg_%s',num2str(s,'%05d')));
    
    idx = initial_index;
    for n=1:N
        
        I = size(data.seeds{n},1);
        for i = 1: I
            idx = idx +1 ;
            seg_path    = (sprintf('%s/%s.tiff',seg_dir,num2str(idx,'%05d')));
            seg_file    = uint16(results.crop_seg{n,s,i});
            if s==1
                image_path  = (sprintf('%s/%s.tiff',image_dir,num2str(idx,'%05d')));
                image_file  = uint16(data.crop_loaded_frame{n,i});
            end
            imwrite(seg_file,seg_path,'tiff');
            if s==1
                imwrite(image_file,image_path,'tiff');
            end
            if add_groundtruth && s==S 
                if n==N && i==I
                    fprintf(jaccard_ranks_file,'"%d": 1\n',idx);
                    fprintf(dice_ranks_file,'"%d": 1\n',idx);
                else
                    fprintf(jaccard_ranks_file,'"%d": 1,\n',idx);
                    fprintf(dice_ranks_file,'"%d": 1,\n',idx);
                end
            else
         
                if n==N && i==I
                    fprintf(jaccard_ranks_file,'"%d": %f\n',idx,results.crop_ranks{n,s,i}.jaccard_all);
                    fprintf(dice_ranks_file,'"%d": %f\n',idx,results.crop_ranks{n,s,i}.dice_all);
                else
                    fprintf(jaccard_ranks_file,'"%d": %f,\n',idx,results.crop_ranks{n,s,i}.jaccard_all);
                    fprintf(dice_ranks_file,'"%d": %f,\n',idx,results.crop_ranks{n,s,i}.dice_all);
                end
            end
        end
    end
    fprintf(jaccard_ranks_file,'}');
    fprintf(dice_ranks_file,'}');
    fclose(jaccard_ranks_file);
    fclose(dice_ranks_file);
    

end    
    
    
    
end


