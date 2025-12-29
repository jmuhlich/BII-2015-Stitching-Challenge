% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.


function [ref_raw_images, ref_seg_images, ref_colony_positions] = load_reference_recentered_images(filepath, threshold, min_object_size)

% query the relevant directory for the image names
imgs = dir([filepath 'img_Cy5*.tif']);
% convert into a cell array of file names
imgs = {imgs.name}';
% get the number of images
nb_ref_colonies = numel(imgs);

% allocate memory
ref_raw_images = cell(nb_ref_colonies,1);
ref_seg_images = cell(nb_ref_colonies,1);
ref_colony_positions = zeros(nb_ref_colonies,2);
invalid = false(nb_ref_colonies,2);

% iterate over each image
for i = 1:nb_ref_colonies
  % get the filename
  fn = imgs{i};
  % load the image from disk
  ref_raw_images{i} = imread([filepath fn]);
  
  % segment the image
  remove_edge_objects = false;
  S = segment_image(ref_raw_images{i}, threshold, min_object_size, remove_edge_objects);
  
  % get the size of the image
  [m,n] = size(ref_raw_images{i});
  % get the pixel value in the middle of the segmented image
  k = S(round(m/2),round(n/2));
  if k > 0
    % if this pixel belongs to an object
    ref_seg_images{i} = S;
    % get the image number from the filename
    n = str2double(fn(9:end-4));
    
    % load the stage position from file
    fh = fopen([filepath sprintf('img_coords_%08d.txt',n)],'r');
    line = fgetl(fh);
    % get the stage X position
    stageX = line(9:end);
    line = fgetl(fh);
    % get the stage Y position
    stageY = line(9:end);
    fclose(fh);
    
    % record the stage position
    ref_colony_positions(i,:) = [str2double(stageX), str2double(stageY)];
  else
    % the middle pixel of the image does not belong to the object in question so this is an invalid reference image
    invalid(i) = true;
  end
end

% remove the invalid reference images
ref_raw_images(invalid) = [];
ref_seg_images(invalid) = [];
ref_colony_positions(invalid,:) = [];

end