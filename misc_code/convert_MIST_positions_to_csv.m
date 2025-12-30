% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.


fp = 'C:\majurski\image-data\BII_Stitching_Challenge_old\Image_Tiles\';
levels = {'Level_1','Level_2','Level_3'};

for l = 1:numel(levels)
  cfp = [fp levels{l} filesep 'cuda' filesep];

  fhi = fopen([cfp 'img-global-positions-0.txt'],'r');
  fho = fopen([cfp 'MIST.csv'],'w');

  line = fgetl(fhi);
  while ischar(line)
    parts = strsplit(line, ';');
    fn = parts{1};
    fn = fn(7:end);

    position = parts{3};
    position = position(13:end-1);
    pos_parts = strsplit(position,',');
    x = str2double(pos_parts{1});
    y = str2double(pos_parts{2}(2:end));

    fprintf(fho, '%s, %g, %g\n', fn, x, y);

    line = fgetl(fhi);
  end
  fclose(fhi);
  fclose(fho);




%
%   cfp = [fp levels{l} filesep 'cuda2' filesep];
%
%   fhi = fopen([cfp 'img-global-positions-0.txt'],'r');
%   fho = fopen([cfp 'MIST2.csv'],'w');
%
%   line = fgetl(fhi);
%   while ischar(line)
%     parts = strsplit(line, ';');
%     fn = parts{1};
%     fn = fn(7:end);
%
%     position = parts{3};
%     position = position(13:end-1);
%     pos_parts = strsplit(position,',');
%     x = str2double(pos_parts{1});
%     y = str2double(pos_parts{2}(2:end));
%
%     fprintf(fho, '%s, %g, %g\n', fn, x, y);
%
%     line = fgetl(fhi);
%   end
%   fclose(fhi);
%   fclose(fho);


end
