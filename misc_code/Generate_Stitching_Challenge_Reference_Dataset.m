% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



clc;clear;

% constants required
threshold = 500;
min_object_size = 2000;
p2m = 0.658;

fp = '\\ITLNAS\bio-data\Stitching\Stitching Challenge BII 2015\Image_Tiles\';
fldrs = {'Level_1','Level_2','Level_3'};

for f = 1:numel(fldrs)
  cur_fp = [fp fldrs{f} filesep];
  ofp = [cur_fp 'Reference_Recentered_Images' filesep];

  if ~exist(ofp, 'dir')

    I = imread([cur_fp 'evaluation_data\MIST.tif']);
    S = segment_stitched_plate(I, threshold, min_object_size);

    [stitched_raw_images, stitched_seg_images, stitched_colony_positions] = create_comparison_colony_images_cellarray(I,S, p2m);
    clear I S;


    rfp = [fp 'Reference_Dataset\recentered_images\'];
    [ref_raw_images, ref_seg_images, ref_colony_positions] = generate_reference_recentered_images_cellarray(rfp, stitched_raw_images, stitched_seg_images, stitched_colony_positions);


    mkdir(ofp);

    for i = 1:numel(ref_raw_images)
      imwrite(ref_raw_images{i}, [ofp sprintf('img_Cy5_%08d.tif', i)]);

      fh = fopen([ofp sprintf('img_coords_%08d.txt',i)],'w');
      fprintf(fh, 'StageX: %g\n', ref_colony_positions(i,1));
      fprintf(fh, 'StageY: %g\n', ref_colony_positions(i,2));
      fclose(fh);
    end
  end


end
