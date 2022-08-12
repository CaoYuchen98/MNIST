function warp_routine(PATH)

% Assignment 3
% img - original input image
% img_marked - image with marked sides and corners detected by Hough transform
% corners - the 4 corners of the target A4 paper
% img_warp - the standard A4-size target paper obtained by image warping
% n - determine the size of the result image

% define the n by yourself
n = 5;

% Manually detemine the corner points for 2 input images

inputs = [1,2];
for i = 1:length(inputs)
    img_name = [PATH, num2str(inputs(i)), '.JPG'];
    img = imread(img_name);
    % Run your Hough transform of Assignment 2 Q3 to obtain the corners.
    % You can also find the corners manually. If so, please change the following code accrodingly
    [img_marked, corners] = hough_transform(img);
    % corners = Corners(i, :);
    img_warp = img_warping(img, corners, n, inputs(i)); %输入inputs(i)是因为要对不同的图做一些处理，比如说翻转的角度会有区分，对图二右上角的阴影部分需要处理
    figure, 
    subplot(131),imshow(img);
    subplot(132),imshow(img_marked);
    subplot(133),imshow(img_warp);
    % Comment the above showing command and de-comment the following block if you find the corners manually.
    %{
    figure,
    subplot(121),imshow(img);
    subplot(122),imshow(img_warp);
    %}
    
    %imwrite(img_warp,'D:\HKUST_courses\image-processing\assignment 3\skeleton_code\seg_imgs\generated\2.jpg');
end