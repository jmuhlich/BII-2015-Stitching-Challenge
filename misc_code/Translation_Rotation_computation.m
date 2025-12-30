% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.



function [x,y,a,dx,dy,R] = Translation_Rotation_computation(measured_centroid_x, measured_centroid_y, computed_centroid_x, computed_centroid_y)

% Translate each data to centroid
measured_centroid_xc = measured_centroid_x - mean(measured_centroid_x);
measured_centroid_yc = measured_centroid_y - mean(measured_centroid_y);
computed_centroid_xc = computed_centroid_x - mean(computed_centroid_x);
computed_centroid_yc = computed_centroid_y - mean(computed_centroid_y);

% Copmpute Rotation matrix by Singular Value Decomposition
H = [computed_centroid_xc computed_centroid_yc]' * [measured_centroid_xc measured_centroid_yc];
[U,~,V] = svd(H);
R = V*U';

% New coordinates after Rotation
x = R(1,:)*[computed_centroid_x computed_centroid_y]'; x = x';
y = R(2,:)*[computed_centroid_x computed_centroid_y]'; y = y';
a = asin(R(2))*180/pi;

% compute translation
dx = mean(measured_centroid_x - x);
dy = mean(measured_centroid_y - y);

% Translate results
x = x + dx;
y = y + dy;

% % Find the error
% err = computed - measured;
% err = err .* err;
% err = sum(err(:));
% rmse = sqrt(err/n);
