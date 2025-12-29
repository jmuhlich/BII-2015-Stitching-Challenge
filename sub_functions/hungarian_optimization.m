% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




% Recursive function that searches for best fitted correspondence solution between colonies 
function [correspondence_vector, cost_matrix] = hungarian_optimization(cost_matrix, correspondence_vector)

% Check is there is still any tracks that can be assigned. The stopping condition
if isnan(cost_matrix), return, end

[~, row_min_index] = min(cost_matrix,[],2); % min rowwise
[col_min, col_min_index] = min(cost_matrix); % min columnwise

% Sort the maximum values
[V,IND] = sort(col_min, 'descend');
IND(isnan(V)) = [];

% Assign correspondences
for i = 1:length(IND)
    % If we found a perfect match between colonies, assign a correspondence.
    if row_min_index(col_min_index(IND(i))) == IND(i)
        correspondence_vector(IND(i)) = col_min_index(IND(i));
        cost_matrix(:, IND(i)) = nan;
        cost_matrix(col_min_index(IND(i)),:) = nan;
    end
end

% Check for the remaining colonies until all has been assigned
[correspondence_vector, cost_matrix] = hungarian_optimization(cost_matrix, correspondence_vector);

end