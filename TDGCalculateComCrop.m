function [crop,croped_ground_truth,croped_loaded_frame,shifted_COM] =  TDGCalculateComCrop(data,seg,crop_size,n)
    ground_truth        = data.ground_truth{n};
    temp                = unique(ground_truth(:));
    temp(temp==0)       = [];
    L                   = length(temp);
    shape               = size(seg);  
    crop                = zeros([L crop_size]);
    croped_ground_truth = zeros([L crop_size]);
    croped_loaded_frame = zeros([L crop_size]);
    
    COM                 = zeros(L,2);
    com                 = zeros(L,2);
    shifted_COM         = zeros(L,2);
    %%% debug %%%
    %{
    figure
    imshow(seg,[])
    hold on
    %}
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
            
        % crop limits
        
        if com(label,1)<=crop_size(1)/2
            com(label,1) = crop_size(1)/2 + 1;
        end
        if com(label,1)>= shape(2) - crop_size(1)/2
            com(label,1) = shape(2) - crop_size(1)/2;
        end
        
        if com(label,2)<=crop_size(2)/2
            com(label,2) = crop_size(2)/2 + 1;
        end
        if com(label,2)>= shape(1) - crop_size(2)/2
            com(label,2) = shape(1) - crop_size(2)/2;
        end
        
        
    

    crop(label,:,:)     = seg(com(label,2)-crop_size(1)/2:com(label,2)+crop_size(1)/2-1,...
    com(label,1)-crop_size(2)/2:com(label,1)+crop_size(2)/2-1);
    croped_ground_truth(label,:,:) = ground_truth(com(label,2)-crop_size(1)/2:com(label,2)+crop_size(1)/2-1,...
    com(label,1)-crop_size(2)/2:com(label,1)+crop_size(2)/2-1);
    croped_loaded_frame(label,:,:) = data.loaded_frame{n}(com(label,2)-crop_size(1)/2:com(label,2)+crop_size(1)/2-1,...
    com(label,1)-crop_size(2)/2:com(label,1)+crop_size(2)/2-1);
    
    % calculate shifted orig COM
    h  = crop_size(1);
    w  = crop_size(2);
    y1 = max(COM(label,1)-h/2,1);
    y2 = min(COM(label,1)+h/2,shape(1));
    x1 = max(COM(label,2)-w/2,1);
    x2 = min(COM(label,2)+w/2,shape(2));
    %[X,Y]   = meshgrid(x1:x2,y1:y2);
    %crop_indices = sub2ind(shape,Y(:),X(:));    
    shifted_COM(label,:) = [COM(label,1) - y1, COM(label,2) - x1];



    %%% debug %%%
    %{
    plot(com(label,1),com(label,2),'r*')
    hold on
    %plot(COM(label,1),COM(label,2),'b*')
    %hold on
    plot(com(label,1)-crop_size(1)/2,com(label,2)-crop_size(2)/2,'b*')
    hold on
    plot(com(label,1)+crop_size(1)/2-1,com(label,2)+crop_size(2)/2-1,'g*')
    hold on
    %disp(com(label,:))
    %}
    end
end
    
    
        

