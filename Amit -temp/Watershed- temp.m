%% load data 

img = double(imread('t000.tif'))/(2^16-1);
img = imgaussfilt(img);
 m_1 = mean( min(img));
 m_2 = min(mean(img));
 m_3 = mean(min(img.'));
 m_4 = min(mean(img.'));
level = graythresh(img);
img_2 =imhmin(img,m_1);

img_1 = (img>level).*img;

%% 
d_1 = bwdist(~img_1);
d_1 = medfilt2(d_1,[3 3]);
imshow(d_1);
    
d_2 =  bwdist(~img_2);



%% 
L_1 = watershed(d_1);
img_1(L_1==0)=0;
L_2 = watershed(img_2);
img_2(L_2==0)=0;

imshow(img_2*1.7);




%%

y = [863 422 115 241 69 400 244 36 841];
x = [171 46 94 469 463 694 737 779 788];  %% next time - try to enlarge the regions of the seeds
seed = zeros(size(img));
S = sparse(x,y,1);
shape_S=size(S);
seed(1:shape_S(1),1:shape_S(2))=S;
seed_img = imimposemin(d_1,seed);
gradients = imgradient(d_1);
seed_grad = imimposemin(gradients,seed);
L=watershed(seed_grad);
imshow(seed_grad);
imshow(label2rgb(L));