% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




function stitched_image = assemble_stitching_challenge_image(img_fp, csv_fp, level)

imgs = cell(0,0);
X = [];
Y = [];

% read in the image names and their locations from the csv file
fh = fopen(csv_fp, 'r');
line = fgetl(fh);
while ischar(line)
  parts = strsplit(line, ',');
  imgs = vertcat(imgs, parts(1));
  X = vertcat(X, str2double(parts{2}));
  Y = vertcat(Y, str2double(parts{3}));

  line = fgetl(fh);
end
fclose(fh);

if level == 1
  % for level one to be evaluated the Cy5 channel is needed, not the phase channel which was used for stitching
  imgs = strrep(imgs, 'img_Phase_','img_Cy5_');
end

% only keep integer translations, no subpixel resolution
X = round(X);
Y = round(Y);

% translate the image locations into 4th quadrent
X = X - min(X(:)) + 1;
Y = Y - min(Y(:)) + 1;

% correct the image filenames
for i = 1:numel(imgs)

  fn = imgs{i};
  fn = fn(8:end);
  rowPat = '_r[a-zA-Z]*[0-9]+';
  colPat = '_c[a-zA-Z]*[0-9]+';
  rmatch = regexp(fn,rowPat,'match');
  rmatch = rmatch{1};
  cmatch = regexp(fn,colPat,'match');
  cmatch = cmatch{1};

  match = regexp(rmatch, '[0-9]+', 'match');
  rowNum = str2double(match{1});
  match = regexp(cmatch, '[0-9]+', 'match');
  colNum = str2double(match{1});

  imgs{i} = sprintf('img_Cy5_r%03d_c%03d.tif',rowNum,colNum);
end

% get size of image tile
[r,c] = size(imread([img_fp imgs{1}]));
stitched_image = zeros(max(Y(:))+r-1, max(X(:))+c-1,'uint16');

for i = 1:numel(imgs)
  I = imread([img_fp imgs{i}]);
  stitched_image(Y(i):Y(i)+r-1,X(i):X(i)+c-1) = I;
end

end
