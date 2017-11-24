function [double_img] = TDGLoadDoubleImage(img_address)
% reads an image and converts it to a grayscale, double precision, in the range [0,1]
% INPUTS:   img_address: string, relative address of img to load
% OUTPUTS:  double_img: normalized matrix, double precision, range [0,1]

img     = double(imread(img_address));
if size(img,3) == 3
    img = rgb2gray(img);
end
double_img = img / max(max(img));
disp(sprintf('%s was loaded', img_address));

end

