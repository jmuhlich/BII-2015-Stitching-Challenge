% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



% script to call the compute_stitching_accuracy function

% constants required
threshold = 500;
min_object_size = 2000;
p2m = 0.658;

fp = '\\ITLNAS\bio-data\Stitching\Stitching Challenge BII 2015\Image_Tiles\';
fp = 'C:\majurski\image-data\BII_Stitching_Challenge\Image_Tiles\';
fldrs = {'Level_1','Level_2','Level_3'};

for f = 1:numel(fldrs)
  plate_fp = [fp  fldrs{f} filesep];
  disp(['Dataset: ' fldrs{f}]);

  % discover participants stitched images that need to be evaluated
  participants = dir([plate_fp 'evaluation_data' filesep '*.tif']);
  participants = {participants.name}';
  % strip off the .tif extension
  for i = 1:numel(participants)
    participants{i} = participants{i}(1:end-4);
  end

  for p = 1:numel(participants)
    method = participants{p};
    disp(['Evaluating: ' method]);

    ofp = [plate_fp 'Stitching_Error' filesep];
    if ~exist([ofp method '.mat'],'file')
      I = imread([plate_fp 'evaluation_data' filesep method '.tif']);
      S = segment_stitched_plate(I, threshold, min_object_size);

      [stitched_raw_images, stitched_seg_images, stitched_colony_positions] = create_comparison_colony_images_cellarray(I,S, p2m);
      clear I S;

      rfp = [plate_fp 'Reference_Recentered_Images' filesep];
      [ref_raw_images, ref_seg_images, ref_colony_positions] = load_reference_recentered_images(rfp);

      % ref_raw_images:     the individual recentered colonies from the
      % ref_seg_images:     the individual segmented recentered colonies from the reference
      % ref_colony_positions:     the individual colony stage locations
      % stitched_raw_images:     the colony images from the comparison stithced image
      % stitched_seg_images:     The colony segmented images from the comparison stitched image
      % stitched_colony_positions:     The comparison stitched image colony locations


      [FN,FP,total_area_error,distance_error, ref_colony_positions, ref_raw_images, ref_seg_images, ref_colony_ind,...
        stitched_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_ind, R] = compute_stitching_accuracy2(ref_raw_images,...
        ref_seg_images, ref_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_positions);

      if ~exist(ofp, 'dir')
        mkdir(ofp);
      end
      save([ofp method '.mat']);

    end
  end
end
