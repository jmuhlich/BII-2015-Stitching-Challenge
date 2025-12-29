% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.






fp = '\\ITLNAS\bio-data\Stitching\mosaicTechniqueEvaluation\Unfiltered_Data\Day2_Plate_20150112\10Perc_Tiling\';
ofp = '\\ITLNAS\bio-data\Stitching\Stitching Challenge BII 2015\Image_Tiles\';


mkdir([ofp 'Level1_Image_Tiles']);
% create the 10x10 phase contrast stitching challenge image tile grid
i_vals = 0:9;
j_vals = 8:17;
for i = 1:numel(i_vals)
  for j = 1:numel(j_vals)
    fns = sprintf('img_w1_r%03d_c%03d_t000000000_Phase_000.tif',i_vals(i),j_vals(j));
    fnd = sprintf('img_Phase_r%03d_c%03d.tif',i,j);
    copyfile([fp fns],[ofp 'Level1_Image_Tiles' filesep fnd]);
    
    % copy both the phase and Cy5 because only the Cy5 can be used to generate stitching accuracy results
    fns = sprintf('img_w1_r%03d_c%03d_t000000000_Cy5_000.tif',i_vals(i),j_vals(j));
    fnd = sprintf('img_Cy5_r%03d_c%03d.tif',i,j);
    copyfile([fp fns],[ofp 'Level1_Image_Tiles' filesep fnd]);
  end
end








mkdir([ofp 'Level2_Image_Tiles']);
% create the 10x10 Cy5 stitching challenge image tile grid
i_vals = 6:15;
j_vals = 6:15;
for i = 1:numel(i_vals)
  for j = 1:numel(j_vals)
    fns = sprintf('img_w1_r%03d_c%03d_t000000000_Cy5_000.tif',i_vals(i),j_vals(j));
    fnd = sprintf('img_Cy5_r%03d_c%03d.tif',i,j);
    copyfile([fp fns],[ofp 'Level2_Image_Tiles' filesep fnd]);
  end
end





mkdir([ofp 'Level3_Image_Tiles']);
% create the 23x22 Cy5 stitching challenge image tile grid
i_vals = 0:23;
j_vals = 0:22;
for i = 1:numel(i_vals)
  for j = 1:numel(j_vals)
    fns = sprintf('img_w1_r%03d_c%03d_t000000000_Cy5_000.tif',i_vals(i),j_vals(j));
    fnd = sprintf('img_Cy5_r%03d_c%03d.tif',i,j);
    copyfile([fp fns],[ofp 'Level3_Image_Tiles' filesep fnd]);
  end
end


