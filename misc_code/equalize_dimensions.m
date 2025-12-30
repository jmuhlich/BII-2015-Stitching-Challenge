% NIST-developed software is provided by NIST as a public service. You may use, copy and distribute copies of the software in any medium, provided that you keep intact this entire notice. You may improve, modify and create derivative works of the software or any portion of the software, and you may copy and distribute such modifications or works. Modified works should carry a notice stating that you changed the software and should note the date and nature of any such change. Please explicitly acknowledge the National Institute of Standards and Technology as the source of the software.

% NIST-developed software is expressly provided "AS IS." NIST MAKES NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.

% You are solely responsible for determining the appropriateness of using and distributing the software and you assume all risks associated with its use, including but not limited to the risks and costs of program errors, compliance with applicable laws, damage to or loss of data, programs or equipment, and the unavailability or interruption of operation. This software is not intended to be used in any situation where a failure could cause risk of injury or damage to property. The software developed by NIST employees is not subject to copyright protection within the United States.




% Make images I1 and I2 the same dimensions by padding them with 0
function [I,S] = equalize_dimensions(tgt_m,tgt_n, I,S)


% Get image sizes
[mI,nI] = size(I);
[mS,nS] = size(S);
assert(mI==mS && nI==nS, 'Image and mask must be same dimensions');
assert(tgt_m>=mS&&tgt_n>=nS, 'Target size must be larger than current size');

stats = regionprops(S,'centroid','boundingbox');


bb = [stats.BoundingBox(2), stats.BoundingBox(2)+stats.BoundingBox(4)-1,stats.BoundingBox(1),stats.BoundingBox(1)+stats.BoundingBox(3)-1];
bb = round(bb);
I = I(bb(1):bb(2),bb(3):bb(4));
S = S(bb(1):bb(2),bb(3):bb(4));

ci = round(stats.Centroid(2)-stats.BoundingBox(2)+1);
cj = round(stats.Centroid(1)-stats.BoundingBox(1)+1);

padx = round(tgt_n/2) - cj;
pady = round(tgt_m/2) - ci;
if padx < 0
  padx = 0;
end
if pady < 0
  pady = 0;
end
I = padarray(I,[pady,padx], 0, 'pre');
S = padarray(S,[pady,padx], 0, 'pre');

[mS,nS] = size(S);
padx = tgt_n - nS;
pady = tgt_m - mS;
if padx < 0
  jj = abs(padx);
  I = I(:,(jj+1):end);
  S = S(:,(jj+1):end);
  [mS,nS] = size(S);
  padx = tgt_n - nS;
end
if pady < 0
  ii = abs(pady);
  I = I((ii+1):end,:);
  S = S((ii+1):end,:);
  [mS,nS] = size(S);
  pady = tgt_m - mS;
end
I = padarray(I,[pady,padx], 0, 'post');
S = padarray(S,[pady,padx], 0, 'post');
