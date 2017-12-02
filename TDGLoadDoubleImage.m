function [double_img] = TDGLoadDoubleImage(img_address)
% reads an image and converts it to a grayscale, double precision, in the range [0,1]
% INPUTS:   img_address: string, relative address of img to load
% OUTPUTS:  double_img: normalized matrix, double precision, range [0,1]

try
	img = double(imread(img_address));
catch
	fprintf('%s does not exist. returning 0.\n', img_address);
	double_img = false;
	return;
end
if size(img,3) == 3
    img = rgb2gray(img);
end
% double_img = img / max(max(img));
double_img = img;
fprintf('%s was loaded\n', img_address);

end

