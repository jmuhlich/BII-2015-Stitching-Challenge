% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




function S = segment_image(I, threshold, min_object_size, remove_edge_objects)

% threshold the image
S = I > threshold;
% enforce the minimum object size (setting smaller objects to 0)
S = bwareaopen(S,min_object_size);
% fill in any holes
S = imfill(S, 'holes');
% label connected componenets using 8 connectivity
S = labelmatrix(bwconncomp(S,8));

if remove_edge_objects
  % remove any object that is within buff of the edge of the images tiles making up the stitched image
  buff = 5;
  % set the buffer region to 0 to mimic a stitched pixel that does not come from an image tile
  I(:,1:(1+buff)) = 0;
  I(:,(end-buff):end) = 0;
  I(1:(1+buff),:) = 0;
  I((end-buff):end,:) = 0;
  % dilate the objects by 1 pixel
  S1 = imdilate(S, strel('disk',1,0));
  % find any objects that overlap a zero pixel in the image
  stats = regionprops(S1, I, 'PixelValues', 'PixelIdxList');
  % delete and objects that are within 5 of the boarder of an image tile
  relabel_required = false;
  for k = 1:numel(stats)
    if any(stats(k).PixelValues == 0)
      relabel_required = true;
      S(stats(k).PixelIdxList) = 0;
    end
  end

  if relabel_required
    % relabel the connected components to account for any removed objects
    S = labelmatrix(bwconncomp(S,8));
  end
end

end
