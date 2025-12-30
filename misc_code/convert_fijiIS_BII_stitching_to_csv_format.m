% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




fp = 'C:\majurski\image-data\BII_Stitching_Challenge\';

levels = {'Level_1','Level_2','Level_3'};

for level = 1:numel(levels)
  sfp = [fp levels{level} filesep 'Image_Tiles_Global_Positions' filesep];
  if exist([sfp 'TileConfiguration.registered.txt'],'file')

    fh_i = fopen([sfp 'TileConfiguration.registered.txt'],'r');
    fh_o = fopen([sfp 'Fiji-IS-global-positions.csv'],'w');

    line = fgetl(fh_i);
    while ischar(line)

      if numel(line) >= 4 && strcmp(line(1:4), 'img_')
        % parse data from input file
        parts = strsplit(line, ';');
        img = parts{1};
        coords = parts{3};
        coords = strtrim(coords);
        coords = coords(2:end-1);
        parts = strsplit(coords, ',');
        x = str2double(parts{1});
        y = str2double(parts{2});

        % print data to output file
        fprintf(fh_o, '%s, %g, %g\n', img, x, y);
      end
      line = fgetl(fh_i);
    end

    fclose(fh_i);
    fclose(fh_o);

  end

end
