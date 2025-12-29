% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




function stitched_image = assemble_stitching_challenge_image(Image_Tiles_fldr, global_positions_csv_filepath, level)

% init the positions and image name data
imgs = cell(0,0);
X = [];
Y = [];

% read in the image names and their locations from the csv file
fh = fopen(global_positions_csv_filepath, 'r');
line = fgetl(fh);
while ischar(line)
  % split the read line on commas
  parts = strsplit(line, ',');
  % record the image name
  imgs = vertcat(imgs, parts(1));
  % record the global x and y coordinates
  X = vertcat(X, str2double(parts{2}));
  Y = vertcat(Y, str2double(parts{3}));

  % get the next line
  line = fgetl(fh);
end
% close the file
fclose(fh);

% if this is Level_1 change the image names so that we assemble Cy5 images
% this is required as challenge evalation requires Cy5 images
% the content of the phase and Cy5 images are the same, colony wise
if level == 1
  % for level one to be evaluated the Cy5 channel is needed, not the phase channel which was used for stitching
  imgs = strrep(imgs, 'img_Phase_','img_Cy5_');
end

% only keep integer translations, no subpixel resolution
X = round(X);
Y = round(Y);

% translate the image locations into 4th quadrent (image coordinates)
X = X - min(X(:)) + 1;
Y = Y - min(Y(:)) + 1;

% correct the image filenames in case they have been modified
for i = 1:numel(imgs)
  % get the filename from the csv file
  fn = imgs{i};
  % setup the regular expression pattern match for row numbers
  rowPat = '_r[a-zA-Z]*[0-9]+';
  % setup the regular expression pattern match for column numbers
  colPat = '_c[a-zA-Z]*[0-9]+';
  % find the row number
  rmatch = regexp(fn,rowPat,'match');
  rmatch = rmatch{1};
  % find the column number
  cmatch = regexp(fn,colPat,'match');
  cmatch = cmatch{1};

  % convert the row number to double
  match = regexp(rmatch, '[0-9]+', 'match');
  rowNum = str2double(match{1});
  % convert the column number to double
  match = regexp(cmatch, '[0-9]+', 'match');
  colNum = str2double(match{1});

  % create the proper filename to be loaded off disk
  imgs{i} = sprintf('img_w1_r%03d_c%03d_t000000000_Cy5_000.tif',rowNum,colNum);
end

% get size of an individual image tile
img_stats = imfinfo([Image_Tiles_fldr imgs{1}]);
r = img_stats.Height;
c = img_stats.Width;

% allocate memory for the stitched image
stitched_image = zeros(max(Y(:))+r-1, max(X(:))+c-1,'uint16');

% loop over each image adding it to the stitched image using an overlap blend
for i = 1:numel(imgs)
  % read the image
  I = imread([Image_Tiles_fldr imgs{i}]);
  % copy it into the stitched image
  stitched_image(Y(i):Y(i)+r-1,X(i):X(i)+c-1) = I;
end

end
