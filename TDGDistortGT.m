function [segs] =  TDGDistortGT(params,data,S,strel_skip)


N               = params.num_of_frames;
max_strel_size  = S;
len             = length(linspace(1,max_strel_size,strel_skip));
segs            = cell(N,len);

for n = 1:N
    img = data.ground_truth{n};
      m = min(img(:));
      img(img~=m) = 1;
      idx = 0;
      for s = 1:len:max_strel_size
        idx = idx + 1 ;
        st = strel('disk',s);
        segs{n,idx} = imdilate(img,st);
      end
end
        