% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



% Get the bounding_box that contains the coordinates of the box that surrounds the object in the segmented image S.
% For example bounding_box(k,:) = [i_min i_max j_min j_max], which are the box boundaries of the
% object k.
function bb = get_bounding_box(S)

if islogical(S)
    [ii,jj] = find(S);
    bb = zeros(1,4); % bb(k,:) = [i_min i_max j_min j_max]
    bb(1,1) = min(ii);
    bb(1,2) = max(ii);
    bb(1,3) = min(jj);
    bb(1,4) = max(jj);
else

    % Get image size
    [m,n] = size(S);

    stats = regionprops(S, 'PixelIdxList');
    bb = NaN(numel(stats),4); % bb(k,:) = [i_min i_max j_min j_max]
    for k = 1:numel(stats)
        % if a label is missing from the S image, skip its empty element in stats
        if isempty(stats(k).PixelIdxList), continue, end

        % convert the list of pixel locations from linear indexing to row-column
        [ii,jj] = ind2sub([m,n],stats(k).PixelIdxList);

        % find the extents of the row-column pixel locations
        bb(k,1) = min(ii);
        bb(k,2) = max(ii);
        bb(k,3) = min(jj);
        bb(k,4) = max(jj);
    end
end

end
