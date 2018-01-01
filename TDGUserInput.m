function [seeds] = TDGUserInput(frame, params, index)
% recieves user 'seeds' that represent approximate centers of the cells and returns
% INPUTS:	frame - greyscale image on which the user marks centers of cells
%			params - parameters struct for the TDG
%			index - index of the current frame
% OUTPUTS: 	seeds - [k*3] matrix containing the user marks (x,y) coordinates and the button pressed when taken
%					where k is the the number of seeds given (usually number of cells in the frame)

disp('Cell Seeds marking instructions:');
disp('place the marker on the desired seed location, preferrably on the approximate center of the cell.');
disp('press the number of the cell with accordance to its number in other frames.');
prompt = 'press any key to continue'; 
input(prompt);
figure;
imshow(uint16(frame));
[x,y] = ginput(params.cell_count_per_frame(index));
seeds = [y,x];
end