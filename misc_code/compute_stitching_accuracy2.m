% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




% Ref_path is the path to the reference colony images and stitched_path is the path to the stiched colony images
% We expect to have a raw and a segmented image per colony where all pixels outside the boundary of the colony are set to 0.
% We also expect to have a position file "colony_positions.mat" a matrix with colony ID in rows and [X,Y] coordinates in microns
% function [distance_error, area_error, FP, FN] = compute_stitching_accuracy(Ref_path,stitched_path)


% function [total_area_error, distance_error, FN, FP] = compute_stitching_accuracy(Ref_path, stitched_path)


% Ref_path = 'C:\majurski\image-data\mosaicTechniqueEvaluation\Day2_Plate_20150112\10Perc_Tiling\Reference_Dataset_Cropped\';
% stitched_path = 'C:\majurski\image-data\mosaicTechniqueEvaluation\Day2_Plate_20150112\test_20150507\Comparison\';

% ref_raw_images:     the individual recentered colonies from the
% ref_seg_images:     the individual segmented recentered colonies from the reference
% ref_colony_positions:     the individual colony stage locations
% stitched_raw_images:     the colony images from the comparison stithced image
% stitched_seg_images:     The colony segmented images from the comparison stitched image
% stitched_colony_positions:     The comparison stitched image colony locations

function [FN,FP,total_area_error,distance_error, ref_colony_positions, ref_raw_images, ref_seg_images, ref_colony_ind,...
  stitched_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_ind, R] = compute_stitching_accuracy2(ref_raw_images,...
  ref_seg_images, ref_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_positions)

% Get the number of ref and stitched colonies
nb_ref_colonies = size(ref_colony_positions,1);
[nb_rows, nb_cols] = size(ref_raw_images{1});


mid_i = round(nb_rows/2);
mid_j = round(nb_cols/2);
discard_stitched_ref_images = false(nb_ref_colonies,1);
for i = 1:nb_ref_colonies
  k = ref_seg_images{i}(mid_i,mid_j);
  if k ~= 0
    ref_seg_images{i} = ref_seg_images{i}==k;
    ref_raw_images{i}(~ref_seg_images{i}) = 0; % Make sure only the colony of interest intensity pixels are in the FOV
  else
    discard_stitched_ref_images(i) = 1;
  end
end
ref_raw_images(discard_stitched_ref_images) = [];
ref_seg_images(discard_stitched_ref_images) = [];
ref_colony_positions(discard_stitched_ref_images,:) = [];
nb_ref_colonies = size(ref_colony_positions,1);

% From the raw translation computation
Hy = 5; Vx = 3; % Reference to the paper. Hy = Y2 and Vx = X1. They are the translation on y when movinghorizontally and on x when moving vertically.
H = 1392-139; V = 1040-104; % As read from the microscope stage movement on both horizontal (H) and vertical (V)

% Compute rotation angle as the average of the value computed from horizontal and vertical. And construct the rotation matrix R
a = (asin(Hy/H) + asin(Vx/V))/2;
R = [cos(a) sin(a); -sin(a) cos(a)];

% Translate and rotate all computed coordinates
ref_centroid_x = R(1,:)*[ref_colony_positions(:,1) ref_colony_positions(:,2)]'; ref_centroid_x = ref_centroid_x';
ref_centroid_y = R(2,:)*[ref_colony_positions(:,1) ref_colony_positions(:,2)]'; ref_centroid_y = ref_centroid_y';
ref_colony_positions = [ref_centroid_x ref_centroid_y];

nb_stitched_colonies = size(stitched_colony_positions,1);

[nb_rows, nb_cols] = size(ref_raw_images{1});
mid_i = round(nb_rows/2);
mid_j = round(nb_cols/2);

discard_stitched_seg_images = false(nb_stitched_colonies,1);
for i = 1:nb_stitched_colonies
  [m1,n1] = size(stitched_raw_images{i});
  if m1 > nb_rows || n1 > nb_cols
    % discard colonies that are bigger than one FOV
    discard_stitched_seg_images(i) = 1;
  else
    % Equalize images
    [stitched_raw_images{i},stitched_seg_images{i}] = equalize_dimensions(nb_rows,nb_cols,stitched_raw_images{i},stitched_seg_images{i});
    
    stitched_raw_images{i}(~stitched_seg_images{i}) = 0; % Make sure only the colony of interest intensity pixels are in the FOV
    if ~stitched_seg_images{i}(mid_i,mid_j)
      discard_stitched_seg_images(i) = 1;
    end
  end
end


% Remove invalid stitched data
stitched_raw_images(discard_stitched_seg_images) = [];
stitched_seg_images(discard_stitched_seg_images) = [];
stitched_colony_positions(discard_stitched_seg_images,:) = [];
nb_stitched_colonies = numel(stitched_raw_images);


% Compute reference area
ref_area = cellfun(@(x) sum(x(:)), ref_seg_images);
% Compute stitched area
stitched_area = cellfun(@(x) sum(x(:)), stitched_seg_images);


% Compute Cross Correlation
Ref_Images = cellfun(@(x) x(:)', ref_raw_images, 'UniformOutput', false);
Ref_Images = double(cell2mat(Ref_Images)');
Stitched_Images = cellfun(@(x) x(:)', stitched_raw_images, 'UniformOutput', false);
Stitched_Images = double(cell2mat(Stitched_Images)');
% Since both vectors have similar values and that the background has a value of 0, subtracting the mean will affect the cross correlation value
% Ref_Images = Ref_Images - repmat(ref_mean',size(Ref_Images,1),1);
% Stitched_Images = Stitched_Images - repmat(stitched_mean',size(Stitched_Images,1),1);
% Numerator
N = Stitched_Images'*Ref_Images;
% Denominator
D1 = sqrt(sum(Ref_Images.^2));
D2 = sqrt(sum(Stitched_Images.^2));
D = repmat(D1,nb_stitched_colonies,1) .* repmat(D2',1,nb_ref_colonies);
cross_corr = N./D;

% Compute similarity matrix
similarity_matrix = -cross_corr;

% Assign Correspondences: correspondence_vector has a size = nb_ref_colonies and each row has the index of the corresponding stitched colony.
% Example: if correspondence_vector(5) = 22 ==> ref_colony 5 is the same as stitched colony 22
correspondence_vector = hungarian_optimization(similarity_matrix, zeros(nb_ref_colonies,1));

% Get the indexes of ref and stitched that correspond to each other. The accuracy will be computed on those colonies only
stitched_colony_ind = nonzeros(correspondence_vector);
ref_colony_ind = find(correspondence_vector);

% Compute cross correlation vector and sort it. Choose the best 5 matches to compute translation and rotation
similarity_vec = similarity_matrix(sub2ind(size(similarity_matrix), stitched_colony_ind, ref_colony_ind));
[~,Ind] = sort(similarity_vec);
tr_nb = 10;
% backoff the number of colonies to use if there are not that many colonies
if numel(Ind) < tr_nb
  tr_nb = numel(Ind);
end
stitched_colony_ind = stitched_colony_ind(Ind(1:tr_nb));
ref_colony_ind = ref_colony_ind(Ind(1:tr_nb));

% Compute Translation and Rotation between measured and computed locations
measured_centroid_x = ref_colony_positions(ref_colony_ind,1);
measured_centroid_y = ref_colony_positions(ref_colony_ind,2);
computed_centroid_x = stitched_colony_positions(stitched_colony_ind,1);
computed_centroid_y = stitched_colony_positions(stitched_colony_ind,2);

% compute translation
dx = mean(measured_centroid_x - computed_centroid_x);
dy = mean(measured_centroid_y - computed_centroid_y);

% Translate results
computed_centroid_x = stitched_colony_positions(:,1) + dx;
computed_centroid_y = stitched_colony_positions(:,2) + dy;

% Compute similarity matrix
similarity_matrix = -cross_corr;

% Update Correspondences: correspondence_vector has a size = nb_ref_colonies and each row has the index of the corresponding stitched colony.
% Example: if correspondence_vector(5) = 22 ==> ref_colony 5 is the same as stitched colony 22
correspondence_vector = hungarian_optimization(similarity_matrix, zeros(nb_ref_colonies,1));

% Get the indexes of ref and stitched that correspond to each other. The accuracy will be computed on those colonies only
stitched_colony_ind = nonzeros(correspondence_vector);
ref_colony_ind = find(correspondence_vector);

% Compute false positive and false negative
FP = uint32(nb_stitched_colonies - nb_ref_colonies); % number of colonies added by the stitching method
FN = uint32(nb_ref_colonies - nb_stitched_colonies); % number of colonies undetected by the stitching method

% Compute location error
measured_centroid_x = ref_colony_positions(ref_colony_ind,1);
measured_centroid_y = ref_colony_positions(ref_colony_ind,2);
computed_centroid_x1 = computed_centroid_x(stitched_colony_ind);
computed_centroid_y1 = computed_centroid_y(stitched_colony_ind);
distance_error = sqrt( (measured_centroid_x - computed_centroid_x1).^2 + (measured_centroid_y - computed_centroid_y1).^2);

% Compute area error
total_area_error = (stitched_area(stitched_colony_ind) - ref_area(ref_colony_ind))./ref_area(ref_colony_ind);
1;

end

