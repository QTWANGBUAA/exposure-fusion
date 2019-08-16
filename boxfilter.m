function imDst = boxfilter(imSrc, r)

%   BOXFILTER   O(1) time box filtering using cumulative sum
%
%   - Definition imDst(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
%   - Running time independent of r; 
%   - Equivalent to the function: colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum);
%   - But much faster.

[hei, wid] = size(imSrc);
imDst = zeros(size(imSrc));

%cumulative sum over Y axis
imCum = cumsum(imSrc, 1);
%difference over Y axis
imDst(1:r+1, :) = imCum(1+r:2*r+1, :);
imDst(r+2:hei-r, :) = imCum(2*r+2:hei, :) - imCum(1:hei-2*r-1, :);
imDst(hei-r+1:hei, :) = repmat(imCum(hei, :), [r, 1]) - imCum(hei-2*r:hei-r-1, :);

%cumulative sum over X axis
imCum = cumsum(imDst, 2);
%difference over Y axis
imDst(:, 1:r+1) = imCum(:, 1+r:2*r+1);
imDst(:, r+2:wid-r) = imCum(:, 2*r+2:wid) - imCum(:, 1:wid-2*r-1);
imDst(:, wid-r+1:wid) = repmat(imCum(:, wid), [1, r]) - imCum(:, wid-2*r:wid-r-1);

%%% the following implementation is for C langugage
% [height, width] = size(imSrc);
% Sum = zeros(size(imSrc));
% imDst = zeros(size(imSrc));
% rho = r;
% %%%%Sum along Y direction
% 
% for j=1:width
%     Sum(1,j) = imSrc(1,j);
% end
% for i=2:height
%     for j=1:width
%         Sum(i,j) = Sum(i-1,j)+imSrc(i,j);
%     end
% end
% for i=1:rho+1
%     for j=1:width
%         imDst(i,j) = Sum(i+rho,j);
%     end
% end
% for i=rho+2:height-rho
%     for j=1:width
%         imDst(i,j) = Sum(i+rho,j)-Sum(i-rho-1,j);
%     end
% end
% for i=height-rho+1:height
%     for j=1:width
%         imDst(i,j) = Sum(height,j)-Sum(i-rho-1, j);
%     end
% end
% 
% 
% 
% %%% Sum along X direction
% 
% for i=1:height
%     Sum(i,1) = imDst(i,1);
% end
% 
% for i=1:height
%     for j=2:width
%         Sum(i,j) = Sum(i,j-1)+imDst(i,j);
%     end
% end
% 
% for i=1:height
%     for j=1:rho+1
%         imDst(i,j) = Sum(i,j+rho);
%     end
% end
% 
% for i=1:height
%     for j=rho+2:width-rho
%         imDst(i,j) = Sum(i,j+rho)-Sum(i,j-rho-1);
%     end
% end
% 
% for i=1:height
%     for j=width-rho+1:width
%         imDst(i,j) = Sum(i,width)-Sum(i, j-rho-1);
%     end
% end
 end
 
