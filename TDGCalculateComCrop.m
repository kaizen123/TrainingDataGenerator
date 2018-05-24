function [crop] =  TDGCalculateComCrop(data,seg,crop_size,n)
    ground_truth    = data.ground_truth{n};
    temp            = unique(ground_truth(:));
    temp(temp==0)   = [];
    L               = length(temp);
    shape           = size(seg);
    crop            = zeros([L crop_size]);
    
    COM = zeros(L,2);
    com = zeros(L,2);
    %%% debug %%%
    figure
    imshow(seg,[])
    hold on
    %%%%%%%%%%%%%
    for label = 1:L
        mask            = (ground_truth == temp(label));
        required_props  = {'Centroid', 'BoundingBox', 'Area', 'PixelIdxList'};
        props           = regionprops(mask, required_props);
        if isempty(props)
            crop(label,:,:) = zeros(crop_size);
            continue
        end
        %props           = props([props.Area] > 10); % eliminate connected components noise
        temp_com        = props.Centroid;
        COM(label,:)    = round(temp_com(1,:));
        com(label,:)    = COM(label,:);
        valid_crop      = false;
        while ~valid_crop
            
        % crop limits
        
            tl = round(com(label,:) + ([-crop_size(1)/2 -crop_size(2)/2]));
            tr = round(com(label,:) + ([crop_size(1)/2 -crop_size(2)/2]));
            bl = round(com(label,:) + ([-crop_size(1)/2 crop_size(2)/2]));
            br = round(com(label,:) + ([crop_size(1)/2 crop_size(2)/2]));
            disp(label)
            disp('br:\n')
            disp(br)
            disp('tl:\n')
            disp(tl)

            valid_crop = true;
            
            if tl(1)<1
                com(label,1) = crop_size(1)/2 + 1;
                valid_crop = false;
                continue 
            end
            if tl(2)<1
                com(label,2) = crop_size(2)/2 + 1 ;
                valid_crop = false;
                continue 
            end
            if br(1) > shape(1)
                com(label,1) = shape(1) - crop_size(1)/2;
                valid_crop = false;
                continue
            end
            if br(2)>shape(2)
                com(label,2) = shape(2) - crop_size(2)/2 ;
                valid_crop = false; 
                continue 
            end
        end

    crop(label,:,:) = seg(com(label,1)-crop_size(1)/2:com(label,1)+crop_size(1)/2-1,...
    com(label,2)-crop_size(2)/2:com(label,2)+crop_size(2)/2-1);
    
    %%% debug %%%

    plot(com(label,1),com(label,2),'r*')
    hold on
    %plot(COM(label,1),COM(label,2),'b*')
    %hold on
    plot(com(label,1)-crop_size(1)/2,com(label,2)-crop_size(2)/2,'b*')
    hold on
    plot(com(label,1)+crop_size(1)/2-1,com(label,2)+crop_size(2)/2-1,'g*')
    hold on
    %disp(com(label,:))
    end
   
    
end
    
    
        

