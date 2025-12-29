% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



function [I,cmap] = generate_distance_error_heatmap(stitched_colony_positions,stitched_colony_ind,stitched_seg_images,distance_error,P2M,MAX_DISTANCE_ERROR)


% get the centroid locations
 cent_x = stitched_colony_positions(stitched_colony_ind,1);
 cent_y = stitched_colony_positions(stitched_colony_ind,2);

 % convert from microns to pixels
 cent_x = round(cent_x/P2M);
 cent_y = round(cent_y/P2M);

 % translate coordinates to 1
[nb_rows, nb_cols] = size(stitched_seg_images{1});
pixel_buffer = 2;
cent_x = cent_x - min(cent_x) + pixel_buffer;
cent_y = cent_y - min(cent_y) + pixel_buffer;

nb_cols_I = max(cent_x) + nb_cols + pixel_buffer;
nb_rows_I = max(cent_y) + nb_rows + pixel_buffer;

% allocate heatmap image
I = zeros(nb_rows_I, nb_cols_I,'uint16');

% Populate image with heatmap segmented colony masks
for i = 1:numel(cent_x)
  [ii,jj] = find(stitched_seg_images{stitched_colony_ind(i)}>0);
  ii = ii + cent_y(i);
  jj = jj + cent_x(i);
  kk = sub2ind([nb_rows_I,nb_cols_I], ii, jj);

  I(kk) = round(distance_error(i));
end

% shrink image
I = imresize(I,0.2,'nearest');

I(I>0 & I<=10)=10;  
I(I>10 & I<=20)=20;
I(I>20 & I<=30)=30;
I(I>30 & I<=40)=40;
I(I>40 & I<=100)=50;
I(I>100 & I<=MAX_DISTANCE_ERROR)=100;
I(I>MAX_DISTANCE_ERROR)=MAX_DISTANCE_ERROR;

c = jet(7);

cmap = zeros(MAX_DISTANCE_ERROR+1,3);
cmap(2:10,1) = c(1,1); cmap(2:10,2) = c(1,2); cmap(2:10,3) = c(1,3);
cmap(11:20,1) = c(2,1); cmap(11:20,2) = c(2,2); cmap(11:20,3) = c(2,3);
cmap(21:30,1) = c(3,1); cmap(21:30,2) = c(3,2); cmap(21:30,3) = c(3,3);
cmap(31:40,1) = c(4,1); cmap(31:40,2) = c(4,2); cmap(31:40,3) = c(4,3);
cmap(41:50,1) = c(5,1); cmap(41:50,2) = c(5,2); cmap(41:50,3) = c(5,3);
cmap(51:100,1) = c(6,1); cmap(51:100,2) = c(6,2); cmap(51:100,3) = c(6,3);
cmap(101:MAX_DISTANCE_ERROR+1,1) = c(7,1);
cmap(101:MAX_DISTANCE_ERROR+1,1) = c(7,1);
cmap(101:MAX_DISTANCE_ERROR+1,1) = c(7,1);


% background = [0,0,0];
% cmap = background;
% for i = 1:7
%   cmap = vertcat(cmap, [ones(10,1).*c(i,1), ones(10,1).*c(i,2), ones(10,1).*c(i,3)]);
% end


