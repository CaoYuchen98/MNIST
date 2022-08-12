function [digits_set] = digit_segment(img, kq1, kq2)

% Implement the digit segmentation
% img: input image
% digits_set: a matrix that stores the segmented digits. The number of rows
%            equal to the number of digits in the iuput image. Each digit 
%            is stored in each row. Please make sure the segmented digit is a sqaure
%            image before expand it into a row vector.
Im = img;
%Im = rgb2gray(Im);
%1. oimg 是binary image
oimg = OSTU(Im);
%2. 计算每一行的灰度值为1的pixel的累计数量
[M N] = size(Im);
test_row = [];
for i = 1 : M
    nums = 0;
    for j = 1 : N
        if oimg(i, j) == 1
            nums = nums + 1;
        end
    end
    test_row = [test_row nums];
end
%使用第一个kq1，规定union_find搜索x轴的分类时的，最小的连续集合的数量为kq1
[x_proj] = distract(test_row,  kq1);

[Line, ~] = size(x_proj);
ttt = 1;
gaplist = [];
%寻找最大的gap作为方矩阵的宽度
for line = 1 : Line
%for line = 1 : 3
    test_col = [];
    x_start = x_proj(line, 1);
    x_end = x_proj(line, 2);
    x_gap = x_end - x_start + 1;
    gaplist = [gaplist x_gap];
    for j = 1 : N
        nums = 0;
        for i = x_start : x_end
            if oimg(i, j) > 0
                nums = nums + 1;
            end
        end
        test_col = [test_col nums];
    end
    %使用第二个kq2，规定union_find搜索y轴的分类时的，最小的连续集合的数量为kq1
    [y_proj] = distract(test_col, kq2);
    [col, ~] = size(y_proj);
    for q = 1 : col
        y_start = y_proj(q, 1);
        y_end = y_proj(q, 2);
        y_gap = y_end - y_start + 1;
        gaplist = [gaplist y_gap];
    end
end
max_gap = max(gaplist);
ttt = 1;
digits_set = [];

for line = 1 : Line
%for line = 1 : Line
    test_col = [];
    x_start = x_proj(line, 1);
    x_end = x_proj(line, 2);
    x_gap = x_end - x_start + 1;
    for j = 1 : N
        nums = 0;
        for i = x_start : x_end
            if oimg(i, j) > 0
                nums = nums + 1;
            end
        end
        test_col = [test_col nums];
    end
    [y_proj] = distract(test_col, kq2);
    [col, ~] = size(y_proj);
    for q = 1 : col
        y_start = y_proj(q, 1);
        y_end = y_proj(q, 2);
        y_gap = y_end - y_start + 1;
        
        xx_start = x_start;
        xx_end = x_end;
        xx_gap = x_gap;
        yy_start = y_start;
        yy_end = y_end;
        yy_gap = y_gap;
        %保存图像进去
        ZZZ = zeros(max_gap, max_gap);
        ratio_x =  (xx_end - xx_start + 1) / max_gap;
        ratio_y = (yy_end - yy_start + 1) / max_gap;
        x_map = round((1 - ratio_x) / 2 * max_gap) + 1;
        y_map = round((1 - ratio_y) / 2 * max_gap) + 1;
        ZZZ(x_map: x_map + xx_end - xx_start, y_map :  y_map + yy_end - yy_start )  = oimg(xx_start: xx_end, yy_start : yy_end);
        %ZZZ(:, 1 : y_start - yy_start) = 0;
        %ZZZ(:, y_end - yy_start + 2 : yy_end-yy_start + 1) = 0;
        %ZZZ(1:x_start - xx_start , :) = 0;
        %ZZZ(x_end - xx_start + 2:xx_end - xx_start + 1, :) = 0;
        size(ZZZ)
        index = 1;
        digits_set(ttt, :) = reshape(ZZZ, 1, max_gap * max_gap);
        ttt = ttt + 1;           
    end
end

        
        