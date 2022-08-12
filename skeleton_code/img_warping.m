function img_warp = img_warping(img, corners, n, index)

% Implement the image warping to transform the target A4 paper into the
% standard A4-size paper
% Input parameter:
% .    img - original input image
% .    corners - the 4 corners of the target A4 paper detected by the Hough transform
% .    (You can add other input parameters if you need. If you have added
% .    other input parameters, please state for what reasons in the README file)
% .    n - determine the size of the result image
% Output parameter:
% .    img_warp - the standard A4-size target paper obtained by image warping
Im = rgb2gray(img);
order_corners = sortrows(corners, 2);
if index == 1
    another_order(1, :) = order_corners(2, :);
    another_order(2, :) = order_corners(4, :);
    another_order(3, :) = order_corners(1, :);
    another_order(4, :) = order_corners(3, :);
    order_corners = another_order;
end
W = round(sqrt((order_corners(1,1) - order_corners(2,1))^2 + (order_corners(1,2) - order_corners(2,2))^2));
H = round(sqrt((order_corners(1,1) - order_corners(3,1))^2 + (order_corners(1,2) - order_corners(3,2))^2));
%计算affine transform function(inverse)
node = [1, 1; W, 1; 1, H];
B = [1 W 1; 1 1 H; 1 1 1];

C = [order_corners(1, 1)  order_corners(2, 1) order_corners(3, 1);...
    order_corners(1, 2) order_corners(2, 2) order_corners(3, 2);...
    1 1 1];
A = C * inv(B);
A
tt = [];
object = zeros(W, H, 3);
for yy = 1 : H
    for xx = 1 : W
        CC = A * [xx yy 1]';
        ii = CC(1);
        jj = CC(2);
        % 向下取整
        i = floor(ii); j = floor(jj);    
        u = ii - i; v = jj - j;
        i = i + 1; j = j + 1;
        object(xx, yy, :) = (1-u)*(1-v)*img(i,j,:) + (1-u)*v*img(i,j+1,:) + u*(1-v)*img(i+1,j,:) + u*v*img(i+1,j+1,:);
        
        %tt = [tt; x y];

    end
end
%由于边界部分并不平整，以100为界限，截取下四周的边界，并保留内部的信息
img_warp = zeros(W - 200, H - 200, 3);
for i = 101 : W - 100
    for j = 101 : H - 100
        x = i - 100;
        y = j - 100;
        img_warp(x, y, :) = object(i, j, :);
    end
end
[MM, NN, ~] = size(img_warp);
if index == 1
    %基于双线性差值拉伸，缩放图片
    ratio1 = 297 * n / MM;
    ratio2 = 210 * n / NN;
    img_warp = bilinear_resize(img_warp, ratio1, ratio2);
    %img_warp = imresize(img_warp, [297 * n, 210 * n]);
end
if index == 2
    ratio1 = 210 * n / MM;
    ratio2 = 297 * n / NN;
    img_warp = bilinear_resize(img_warp, ratio1, ratio2);
    %img_warp = imresize(img_warp, [210 * n, 297 * n]);
end
img_warp = uint8(mat2gray(img_warp)*255);
end
%show_Im = uint8(mat2gray(object)*255);
%figure
%imshow(show_Im);
%oimg = OSTU(show_Im);
%imshow(uint8(mat2gray(oimg)*255));