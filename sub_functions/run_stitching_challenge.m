% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




function run_stitching_challenge(filepath)

if is_octave
  pkg load image;
  pkg load statistics;
end

% append a file seperator if needed
if ~strcmpi(filepath(end),filesep), filepath = [filepath filesep]; end

% Define the Required constants
MIN_OBJECT_SIZE = 2000; % minimum object size (colonies)
P2M = 0.658; % pixel to micron ratio
% heatmap generation constant
MAX_DISTANCE_ERROR = 340; % hald a FOV in microns (1040/2 * 0.658)

% control parameters
ENABLE_OVERWRITE = false; % controls whether to overwrite existing entries

% check that the folder structure contains 3 folders named:
level_fldrs = {'Level_1','Level_2','Level_3'};

% threshold used to segment stitched images, per level
% NOTE: These are the values for the 10% overlap dataset.
level_thresholds = {592, 544, 482};

for i = 1:numel(level_fldrs)
  if ~exist([filepath level_fldrs{i}],'dir')
    error(['missing ' level_fldrs{i} ' folder in challenge directory']);
  end
end

% iterate over the levels in the stitching challenge
for level = 1:numel(level_fldrs)
  % create filepath to the current level folder
  level_fldr = [filepath level_fldrs{level} filesep];
  threshold = level_thresholds{level};

  % validate that the current level folder has the proper folder structure
  % check the mandatory folders, throwing an error if missing
  Reference_Colony_Images_fldr = [level_fldr 'Reference_Colony_Images' filesep];
  if ~exist(Reference_Colony_Images_fldr, 'dir'), error(['Missing ' level_fldrs{level} ' Reference Colonies folder']); end
  Input_Image_Tiles_fldr = [level_fldr 'Input_Image_Tiles' filesep];
  if ~exist(Input_Image_Tiles_fldr, 'dir'), error(['Missing ' level_fldrs{level} ' Input Image Tiles folder']); end
  Image_Tiles_Global_Positions_fldr = [level_fldr 'Image_Tiles_Global_Positions' filesep];
  if ~exist(Image_Tiles_Global_Positions_fldr, 'dir'), error(['Missing ' level_fldrs{level} ' Image Tiles Global Positions folder']); end

  % check the results folders, creating them if missing
  Stitched_Images_fldr = [level_fldr 'Stitched_Images' filesep];
  if ~exist(Stitched_Images_fldr, 'dir'), mkdir(Stitched_Images_fldr); end
  Evaluation_Results_fldr = [level_fldr 'Evaluation_Results' filesep];
  if ~exist(Evaluation_Results_fldr, 'dir'), mkdir(Evaluation_Results_fldr); end

  % find all global positions csv files within Image_Tiles_Global_Positions_fldr
  global_positions_files = dir([Image_Tiles_Global_Positions_fldr '*.csv']);
  global_positions_files = {global_positions_files.name}'; % convert to file names in cell array

  % iterate over the stitching challenge entries for this level
  for i_gp = 1:numel(global_positions_files)
    % extract the stitching challenge participants name from the csv file
    [~,participant_name,~] = fileparts(global_positions_files{i_gp});

    % if overwrite is not enabled, skip this entry if the accuracy data exists
    if ~ENABLE_OVERWRITE && exist([Evaluation_Results_fldr participant_name '.mat'],'file')
      continue;
    end

    disp(['Computing: ' participant_name]);

    % get a filepath to the current participant csv file
    cur_csv_filepath = [Image_Tiles_Global_Positions_fldr global_positions_files{i_gp}];
    % assemble the global positions into a stitched image
    % the level is passed into this function in order to determine if phase images need to be replaced with Cy5 images
    I = assemble_stitching_challenge_image(Input_Image_Tiles_fldr, cur_csv_filepath, level);

    % write the assemble images to the Stitched_Images_fldr
    imwrite(I, [Stitched_Images_fldr participant_name '.tif']);

    % segment the stitched image into a labeled image
    remove_edge_objects = true;
    S = segment_image(I, threshold, MIN_OBJECT_SIZE, remove_edge_objects);

    % write the labeled segmented image to the Evaluation_Results_fldr
    imwrite(S, [Evaluation_Results_fldr participant_name '-segmented.tif']);

    % convert the stitched and labeled images into cell arrays containing individual colonies
    [stitched_raw_images, stitched_seg_images, stitched_colony_positions] = create_comparison_colony_images_cellarray(I,S, P2M);

    % load the individual reference colony images into a cell array
    [ref_raw_images, ref_seg_images, ref_colony_positions] = load_reference_recentered_images(Reference_Colony_Images_fldr, threshold, MIN_OBJECT_SIZE);

    % At this point the stitched image from the participant has been cut into a cell array of individual colony images.
    % These individual colony images are then compared against the set of reference individual colony images loaded from
    % disk in order to produce evaluation results.

    % compute the stitching evaluation
    [FN,FP,total_area_error,distance_error, ref_colony_positions, ref_raw_images, ref_seg_images, ref_colony_ind,...
      stitched_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_ind, Rotation_Matrix] = compute_stitching_accuracy(ref_raw_images,...
      ref_seg_images, ref_colony_positions, stitched_raw_images, stitched_seg_images, stitched_colony_positions);

    % if more than max distance error, delete the value and add it to FP FN counts
    idx = distance_error > MAX_DISTANCE_ERROR;
    adj_distance_error = distance_error;
    adj_distance_error(idx) = [];
    adj_total_area_error = total_area_error;
    adj_total_area_error(idx) = [];
    adj_FP = FP + nnz(idx);
    adj_FN = FN + nnz(idx);


    % clear the stitched and labeled images from the workspace so they are not saved to disk redundantly
    clear I S;
    % save the workspace for later evaluation of the results
    save([Evaluation_Results_fldr participant_name '.mat'], '-v7');

    % create distance error heatmap
    [I,cmap] = generate_distance_error_heatmap(stitched_colony_positions,stitched_colony_ind,stitched_seg_images,distance_error,P2M,MAX_DISTANCE_ERROR);
    % display heatmap image using returned colormap
    h = figure; imshow(I, cmap);
    colorbar('TickLabels',{'0','10','20','30','40','50','100',num2str(MAX_DISTANCE_ERROR)}, ...
      'Ticks', [0,10,20,30,40,50,100,MAX_DISTANCE_ERROR]);

    % save heatmap
    saveas(h, [Evaluation_Results_fldr participant_name '-distance-error-heatmap.png']);
    close(h);
  end
end


% find full set of participants
all_participants = {};
for level = 1:numel(level_fldrs)
  % create filepath to the current level folder
  level_fldr = [filepath level_fldrs{level} filesep];
  Evaluation_Results_fldr = [level_fldr 'Evaluation_Results' filesep];

  % find all evaluation files within the evaluation folder
  evaluation_files = dir([Evaluation_Results_fldr '*.mat']);
  evaluation_files = {evaluation_files.name}';

  % iterate over the participants and generate summary plots
  for k = 1:numel(evaluation_files)
    % extract the stitching challenge participants name from the csv file
    [~,participant_name,~] = fileparts(evaluation_files{k});

    if isempty(all_participants) || ~any(strcmpi(all_participants, participant_name))
      all_participants = vertcat(all_participants, participant_name);
    end
  end
end

% generate summary plots

% allocate memory
D_all = cell(numel(all_participants),numel(level_fldrs));
S_all = cell(numel(all_participants),numel(level_fldrs));
FP_all = zeros(numel(all_participants),numel(level_fldrs));
FN_all = zeros(numel(all_participants),numel(level_fldrs));
nbA = 0;
nbB = 0;

% iterate over all levels
for level = 1:numel(level_fldrs)

  % create filepath to the current level folder
  level_fldr = [filepath level_fldrs{level} filesep];
  Evaluation_Results_fldr = [level_fldr 'Evaluation_Results' filesep];

  % iterate over the participants and generate summary plots
  for k = 1:numel(all_participants)

    participant_name = all_participants{k};
    % if the participant did not enter for this level, skip it
    if isempty(dir([Evaluation_Results_fldr participant_name '.mat'])), continue; end

    % load evaluation results
    disp(['Loading: ' participant_name]);
    data = load([Evaluation_Results_fldr participant_name '.mat'], 'adj_distance_error','adj_total_area_error','adj_FN','adj_FP');
    data.adj_total_area_error = data.adj_total_area_error.*100;

    D_all{k,level} = data.adj_distance_error;
    if ~isempty(data.adj_distance_error)
      nbA = max(nbA,max(data.adj_distance_error(:)));
    end
    S_all{k,level} = data.adj_total_area_error;
    if ~isempty(data.adj_total_area_error)
      nbB = max(nbB,max(data.adj_total_area_error(:)));
    end
    FP_all(k,level) = data.adj_FP;
    FN_all(k,level) = data.adj_FN;
  end
  max_FN_FP = max(max(FP_all(:)), max(FN_all(:)));
end





for level = 1:numel(level_fldrs)
  fig_size = [0 0 1 1];
  font_size = 10;
  warning off % to prevent boxplot from complaining
  mainFH = figure('units','normalized','outerposition',fig_size);

  LD = cellfun(@length,D_all(:,level));
  LS = cellfun(@length,S_all(:,level));
  A = nan(max(LD),numel(all_participants));
  B = nan(max(LD),numel(all_participants));
  for im = 1:numel(all_participants), A(1:LD(im),im) = D_all{im,level}; end
  for im = 1:numel(all_participants), B(1:LS(im),im) = S_all{im,level}; end

  subplot(2,2, 1)
  boxplot(A);
  title([strrep(level_fldrs{level},'_',' ') ' Distance Error'])
  xlabel('Participant')
  ylabel('Distance Error (microns)')
%   ylim([0,nbA]);
  yt = yticks;
  if nbA > yt(end)
    nb = yt(end) + (yt(end) - yt(end-1));
    ylim([0 nb]);
  end
  xticklabels(all_participants);
  set(gca, 'fontsize',font_size)



  subplot(2,2,2)
  boxplot(B);
  title([strrep(level_fldrs{level},'_',' ') ' Size Error'])
  xlabel('Participant')
  ylabel('Percent Size Error')
  ylim([-nbB,nbB]);
  xticklabels(all_participants);
  set(gca, 'fontsize',font_size)


  subplot(2,2,3)
  bar(FP_all(:,level))
  title([strrep(level_fldrs{level},'_',' ') ' False Positive Count'])
  xlabel('Participant')
  ylabel('Counts')
  xlim([0.5 (size(FP_all,1) + 0.5)]);
  yt = yticks;
  if max_FN_FP > yt(end)
    nb = yt(end) + (yt(end) - yt(end-1));
    ylim([0 nb]);
  end
  xticklabels(all_participants);
  set(gca, 'fontsize',font_size)


  subplot(2,2,4)
  bar(FN_all(:,level))
  title([strrep(level_fldrs{level},'_',' ') ' False Negative Count'])
  xlabel('Participant')
  ylabel('Counts')
  xlim([0.5 (size(FP_all,1) + 0.5)]);
  yt = yticks;
  if max_FN_FP > yt(end)
    nb = yt(end) + (yt(end) - yt(end-1));
    ylim([0 nb]);
  end
  xticklabels(all_participants);
  set(gca, 'fontsize',font_size)

  % Delay before calling getframe to avoid some kind of race condition that causes
  % errors/crashes in getframe under Octave in some situations.
  pause(3);

  I = getframe(mainFH);
  imwrite(I.cdata, [filepath level_fldrs{level} '_Summary.png']);
  close(mainFH);
end



% generate summary mat file
avg_distance_error = NaN(numel(level_fldrs),numel(all_participants));
std_distance_error = NaN(numel(level_fldrs),numel(all_participants));
avg_area_error = NaN(numel(level_fldrs),numel(all_participants));
std_area_error = NaN(numel(level_fldrs),numel(all_participants));

% iterate over the levels
for level = 1:numel(level_fldrs)

  % create filepath to the current level folder
  level_fldr = [filepath level_fldrs{level} filesep];
  Evaluation_Results_fldr = [level_fldr 'Evaluation_Results' filesep];

  % iterate over the participants and generate summary plots
  for k = 1:numel(all_participants)

    participant_name = all_participants{k};
    % if the participant did not enter for this level, skip it
    if isempty(dir([Evaluation_Results_fldr participant_name '.mat'])), continue; end

    % load evaluation results
    data = load([Evaluation_Results_fldr participant_name '.mat'], 'adj_distance_error','adj_total_area_error','adj_FN','adj_FP');

    avg_distance_error(level,k) = mean(data.adj_distance_error);
    std_distance_error(level,k) = std(data.adj_distance_error);

    avg_area_error(level,k) = mean(data.adj_total_area_error);
    std_area_error(level,k) = std(data.adj_total_area_error);

  end
end
avg_distance_error = array2table(avg_distance_error, 'VariableNames', strcat(all_participants, '_avg_distance_error'), 'RowNames',level_fldrs);
std_distance_error = array2table(std_distance_error, 'VariableNames', strcat(all_participants, '_std_distance_error'), 'RowNames',level_fldrs);
avg_area_error = array2table(avg_area_error, 'VariableNames', strcat(all_participants, '_avg_area_error'), 'RowNames',level_fldrs);
std_area_error = array2table(std_area_error, 'VariableNames', strcat(all_participants, '_std_area_error'), 'RowNames',level_fldrs);
t = horzcat(avg_distance_error, std_distance_error, avg_area_error, std_area_error);
spath = [filepath 'summary_stats.csv'];
if is_octave
  table2csv(t, spath);
else
  writetable(t, spath);
end


end
