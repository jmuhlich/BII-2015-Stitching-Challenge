% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




function [ref_raw_images, ref_seg_images, ref_colony_positions] = generate_reference_recentered_images_cellarray(fp, stitched_raw_images, stitched_seg_images, stitched_colony_positions)


[ref_raw_images, ref_seg_images, ref_colony_positions] = load_reference_recentered_images(fp);

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




nb_stitched_colonies = numel(stitched_raw_images);



% ************************************************************************
% CODE FROM compute_stitching_accuracy
% ************************************************************************

discard_stitched_seg_images = false(nb_stitched_colonies,1);
for i = 1:nb_stitched_colonies
    % Equalize images
    [~,stitched_raw_images{i}] = equalize_dimensions(ref_raw_images{1},stitched_raw_images{i});
    [~,stitched_seg_images{i}] = equalize_dimensions(ref_seg_images{1},stitched_seg_images{i});
    % Crop image to the microscope Field of View
    stitched_raw_images{i} = stitched_raw_images{i}(1:nb_rows, 1:nb_cols);
    stitched_seg_images{i} = stitched_seg_images{i}(1:nb_rows, 1:nb_cols);
    stitched_raw_images{i}(~stitched_seg_images{i}) = 0; % Make sure only the colony of interest intensity pixels are in the FOV
    if ~stitched_seg_images{i}(mid_i,mid_j) , discard_stitched_seg_images(i) = 1; end
end


% Remove invalid stitched data
stitched_raw_images(discard_stitched_seg_images) = [];
stitched_seg_images(discard_stitched_seg_images) = [];
stitched_colony_positions(discard_stitched_seg_images,:) = [];
nb_stitched_colonies = numel(stitched_raw_images);




% Compute reference metrics: integrated intensity, perimeter, eccentricity, MajorAxisLength, MinorAxisLength, normalized cross correlation
ref_int_intensity = cellfun(@(x) sum(x(:)), ref_raw_images);
ref_area = cellfun(@(x) sum(x(:)), ref_seg_images);
s = cellfun(@(x) regionprops(x,'Perimeter', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength'), ref_seg_images, 'UniformOutput', false);
ref_perimeter = cellfun(@(x) x.Perimeter, s);
ref_eccentricity = cellfun(@(x) x.Eccentricity, s);
ref_MajorAxisLength = cellfun(@(x) x.MajorAxisLength, s);
ref_MinorAxisLength = cellfun(@(x) x.MinorAxisLength, s);

% Compute stitched metrics: integrated intensity, perimeter, eccentricity, MajorAxisLength, MinorAxisLength, normalized cross correlation
stitched_int_intensity = cellfun(@(x) sum(x(:)), stitched_raw_images);
stitched_area = cellfun(@(x) sum(x(:)), stitched_seg_images);
s = cellfun(@(x) regionprops(x,'Perimeter', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength'), stitched_seg_images, 'UniformOutput', false);
stitched_perimeter = cellfun(@(x) x.Perimeter, s);
stitched_eccentricity = cellfun(@(x) x.Eccentricity, s);
stitched_MajorAxisLength = cellfun(@(x) x.MajorAxisLength, s);
stitched_MinorAxisLength = cellfun(@(x) x.MinorAxisLength, s);

% Compute measurements error between Ref and stitched. Columns correspond to ref images
% Compute integrated intensity error
Ref = repmat(ref_int_intensity',nb_stitched_colonies,1);
Stc = repmat(stitched_int_intensity,1,nb_ref_colonies);
integrated_intensity_error = abs(Ref - Stc);
integrated_intensity_error = integrated_intensity_error/max(integrated_intensity_error(:));

% Compute perimeter error
Ref = repmat(ref_perimeter',nb_stitched_colonies,1);
Stc = repmat(stitched_perimeter,1,nb_ref_colonies);
perimeter_error = abs(Ref - Stc);
perimeter_error = perimeter_error/max(perimeter_error(:));

% Compute eccentricity error
Ref = repmat(ref_eccentricity',nb_stitched_colonies,1);
Stc = repmat(stitched_eccentricity,1,nb_ref_colonies);
eccentricity_error = abs(Ref - Stc);
eccentricity_error = eccentricity_error/max(eccentricity_error(:));

% Compute MajorAxisLength error
Ref = repmat(ref_MajorAxisLength',nb_stitched_colonies,1);
Stc = repmat(stitched_MajorAxisLength,1,nb_ref_colonies);
MajorAxisLength_error = abs(Ref - Stc);
MajorAxisLength_error = MajorAxisLength_error/max(MajorAxisLength_error(:));

% Compute MinorAxisLength error
Ref = repmat(ref_MinorAxisLength',nb_stitched_colonies,1);
Stc = repmat(stitched_MinorAxisLength,1,nb_ref_colonies);
MinorAxisLength_error = abs(Ref - Stc);
MinorAxisLength_error = MinorAxisLength_error/max(MinorAxisLength_error(:));

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
similarity_matrix = eccentricity_error + MajorAxisLength_error + MinorAxisLength_error - cross_corr;

% Assign Correspondences: correspondence_vector has a size = nb_ref_colonies and each row has the index of the corresponding stitched colony.
% Example: if correspondence_vector(5) = 22 ==> ref_colony 5 is the same as stitched colony 22
correspondence_vector = hungarian_optimization(similarity_matrix, zeros(nb_ref_colonies,1));


% Get the indexes of ref and stitched that correspond to each other. The accuracy will be computed on those colonies only
stitched_colony_ind = nonzeros(correspondence_vector);
ref_colony_ind = find(correspondence_vector);

% Compute cross correlation vector and sort it. Choose the best 5 matches to compute translation and rotation
similarity_vec = similarity_matrix(sub2ind(size(similarity_matrix), stitched_colony_ind, ref_colony_ind));
[~,Ind] = sort(similarity_vec);
stitched_colony_ind = stitched_colony_ind(Ind(1:5));
ref_colony_ind = ref_colony_ind(Ind(1:5));

% Compute Translation and Rotation between measured and computed locations
measured_centroid_x = ref_colony_positions(ref_colony_ind,1);
measured_centroid_y = ref_colony_positions(ref_colony_ind,2);
computed_centroid_x = stitched_colony_positions(stitched_colony_ind,1);
computed_centroid_y = stitched_colony_positions(stitched_colony_ind,2);
[computed_centroid_x,computed_centroid_y,a,dx,dy,R] = Translation_Rotation_computation(measured_centroid_x, measured_centroid_y, computed_centroid_x, computed_centroid_y);


% ************************************************************************
% END CODE FROM compute_stitching_accuracy
% ************************************************************************





% Translate and rotate all computed coordinates
computed_centroid_x = R(1,:)*[stitched_colony_positions(:,1) stitched_colony_positions(:,2)]'; computed_centroid_x = computed_centroid_x';
computed_centroid_y = R(2,:)*[stitched_colony_positions(:,1) stitched_colony_positions(:,2)]'; computed_centroid_y = computed_centroid_y';

% Translate results
computed_centroid_x = computed_centroid_x + dx;
computed_centroid_y = computed_centroid_y + dy;


measured_centroid_x = ref_colony_positions(:,1);
measured_centroid_y = ref_colony_positions(:,2);



buff = -2;
% remove colonies
mv = max(computed_centroid_x(:));
idx1 = (measured_centroid_x) > (mv-buff);

mv = min(computed_centroid_x(:));
idx2 = (measured_centroid_x) < (mv+buff);

mv = max(computed_centroid_y(:));
idx3 = (measured_centroid_y) > (mv-buff);

mv = min(computed_centroid_y(:));
idx4 = (measured_centroid_y) < (mv+buff);



% figure, plot(computed_centroid_x, computed_centroid_y,'.');
% figure, plot(measured_centroid_x, measured_centroid_y,'.');
% hold on, plot(measured_centroid_x(idx1|idx2|idx3|idx4), measured_centroid_y(idx1|idx2|idx3|idx4),'r.');



ref_colony_positions(idx1|idx2|idx3|idx4, :) = [];
ref_raw_images(idx1|idx2|idx3|idx4, :) = [];
ref_seg_images(idx1|idx2|idx3|idx4, :) = [];





end
