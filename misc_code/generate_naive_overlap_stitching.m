% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




fp = 'C:\majurski\image-data\BII_Stitching_Challenge\';
levels = {'Level_1','Level_2','Level_3'};
fns = {'img_Phase_r%03d_c%03d.tif','img_Cy5_r%03d_c%03d.tif','img_Cy5_r%03d_c%03d.tif'};
xs = [10,10,23];
ys = [10,10,24];


for level = 1:numel(levels)
  tfp = [fp levels{level} filesep 'Image_Tiles_Global_Positions' filesep];
  
  overlap = 10;
  imgH = 1040;
  imgW = 1392;
  deltaH = (1-(overlap/100))*imgH;
  deltaW = (1-(overlap/100))*imgW;
  
  
  fh = fopen([tfp 'Naive.csv'],'w');
  i_vals = 1:ys(level);
  j_vals = 1:xs(level);
  for i = 1:numel(i_vals)
    for j = 1:numel(j_vals)
      fn = sprintf(fns{level},i,j);
      x = round((j-1)*deltaW);
      y = round((i-1)*deltaH);
      fprintf(fh, '%s, %d, %d\n', fn, x, y);
    end
  end
  fclose(fh);
end