close all;
test_frame = data.pp_frame{1};
otsu_th_fix = 0.05;
otsu_mask 		= (1-(test_frame > graythresh(test_frame) - otsu_th_fix));
otsu_mask 	= 	medfilt2(otsu_mask, [9 9]);
otsu_mask 	= 	logical(otsu_mask);
temp = medfilt2(test_frame, [9 9]);
test_frame_2 = test_frame.*(1-otsu_mask) + temp.*otsu_mask;
test_frame_2 = max(test_frame_2,0);

m = size(test_frame_2,1);
n = size(test_frame_2,2);
image_sample = test_frame_2(randperm(m*n, 1000))';
gm = fitgmdist(image_sample, 2);
figure;
ezplot(@(x)pdf(gm,x));



figure;
imshow(test_frame);
figure;
imshow(test_frame_2);
figure;
imshow(otsu_mask);
