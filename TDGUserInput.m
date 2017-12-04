function [seeds] = TDGUserInput(frame, params, index)
% recieves user 'seeds' that represent approximate centers of the cells and returns
% INPUTS:	frame - greyscale image on which the user marks centers of cells
%			params - parameters struct for the TDG
%			index - index of the current frame
% OUTPUTS: 	seeds - [k*3] matrix containing the user marks (x,y) coordinates and the button pressed when taken
%					where k is the the number of seeds given (usually number of cells in the frame)

% test - asaf
if index == 1
  seeds = [864.0000  162.0000
  420.0000   36.0000
  118.0000  100.0000
  232.0000  468.0000
   74.0000  468.0000
  394.0000  692.0000
  246.0000  734.0000
   26.0000  788.0000
  842.0000  776.0000];
 else
 	seeds =   [868.0000  172.0000
  414.0000   50.0000
  126.0000  110.0000
  390.0000  660.0000
   76.0000  468.0000
  244.0000  490.0000
  256.0000  736.0000
   24.0000  806.0000
  846.0000  774.0000];
end
seeds = flip(seeds,2);
  return;
  % test - asaf

disp('Cell Seeds marking instructions:');
disp('place the marker on the desired seed location, preferrably on the approximate center of the cell.');
disp('press the number of the cell with accordance to its number in other frames.');
prompt = 'press any key to continue'; 
input(prompt);
figure;
imshow(uint16(frame));
% [x,y,button] = ginput(params.cell_count_per_frame(index));
[x,y] = ginput(params.cell_count_per_frame(index));
seeds = [y,x];
% seeds = [x,y,button];
end