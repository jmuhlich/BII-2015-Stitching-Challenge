% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



function [stitched_raw_images, stitched_seg_images, stitched_colony_positions] = create_comparison_colony_images_cellarray(I, S, p2m)

% Make sure image is labeled sequentially
[S, nb_cell] = relabel_image(S);

% Get colony bounding boxes
bounding_box = get_bounding_box(S);


stitched_raw_images = cell(nb_cell,1);
stitched_seg_images = cell(nb_cell,1);

% Save single images
for i = 1:nb_cell
    A = S(bounding_box(i,1):bounding_box(i,2), bounding_box(i,3):bounding_box(i,4)) == i;
    B = I(bounding_box(i,1):bounding_box(i,2), bounding_box(i,3):bounding_box(i,4));
    B(~A) = 0;
    
    
    stitched_raw_images{i} = B;
    stitched_seg_images{i} = A;
end

% Get the centroids and save them in csv format
s = regionprops(S,'Centroid');
c = [s.Centroid];
c = reshape(c,2,[])';
stitched_colony_positions = c*p2m;

end



function [segmented_image, nb_cell] = relabel_image(segmented_image)


curclass = class(segmented_image);
nb_cell = max(segmented_image(:));
if strcmpi(curclass,'int8') && nb_cell == intmax('int8')
  segmented_image = int16(segmented_image);
end
if strcmpi(curclass,'int16') && nb_cell == intmax('int16')
  segmented_image = int32(segmented_image);
end
if strcmpi(curclass,'int32') && nb_cell == intmax('int32')
  segmented_image = int64(segmented_image);
end
if strcmpi(curclass,'uint8') && nb_cell == intmax('uint8')
  segmented_image = uint16(segmented_image);
end
if strcmpi(curclass,'uint16') && nb_cell == intmax('uint16')
  segmented_image = uint32(segmented_image);
end
if strcmpi(curclass,'uint32') && nb_cell == intmax('uint32')
  segmented_image = uint64(segmented_image);
end


curclass = class(segmented_image);
% Create a renumber_cells vector that contains the renumbering of the cells in the labeled mask
nb_cell = max(segmented_image(:));
renumber_cells = zeros(nb_cell, 1);
[m, n] = size(segmented_image);

% Get unique cell ID
u = unique(segmented_image(:));
if u(1) == 0, u(1) = []; end % delete background pixel

for i = 1:length(u), renumber_cells(u(i)) = i; end
renumber_cells = [0;renumber_cells]; % Account for background
renumber_cells = cast(renumber_cells, curclass);



% Renumber image
segmented_image = renumber_cells(segmented_image+1);
segmented_image = reshape(segmented_image, m, n);

% Nb of cells
nb_cell = length(u);

end