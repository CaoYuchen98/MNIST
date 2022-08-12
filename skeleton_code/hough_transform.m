function [img_marked, corners] = hough_transform(img)
    
    % Implement the Hough transform to detect the target A4 paper
    % Input parameter:
    % .    img - original input image
    % .    (You can add other input parameters if you need. If you have added
    % .    other input parameters, please state for what reasons in the PDF file)
    % Output parameter:
    % .    img_marked - image with marked sides and corners detected by Hough transform
    % .    corners - the 4 corners of the target A4 paper
    Im = img;
    %Im1 = Im;
    Im1 = rgb2gray(Im);
    rotI = Im1;
    %preprocess
    se = strel('disk', 13);%选取13使边界更清晰（消除内部pepper噪声）
    SE = se.Neighborhood; 
    Im_dia = imdilate(rotI, SE);
    Im_ero = imerode(rotI, SE);
    %Im2 = Im_dia - rotI;
    %Im2 = rotI - Im_ero;  
    Im2 = Im_dia - Im_ero;  %捕获边缘效果更好

    k = 4; %缩放比例
    BW = im2bw(Im2, 0.2);  %BW指的是未缩减的边缘二值图像
    BW1 = imresize(BW, 1/ k);  %BW1指的是缩减后的边缘二值图片
    %1. 得到Hough变换的Hough计数空间
    %[m, n] = size(BW);
    [mm, nn] = size(BW1); %缩放后的长宽
    %k = 4;
    %draw hough transform and the picture
    theta_max = 90;
    rho_max = floor(sqrt(mm ^ 2 + nn ^ 2)) - 1;
    theta_range = -theta_max  : theta_max - 1;
    rho_range = -rho_max : rho_max;
    Hough = zeros(length(rho_range), length(theta_range));
    for i = 1 : mm
        for j = 1 : nn
            if (BW1(i, j) > 0)
                x = i - 1;
                y = j - 1;
                for (theta = theta_range)
                    rho = round((x * cosd(theta)) + y * sind(theta));
                    Hough(rho + rho_max + 1, theta + theta_max + 1) = Hough(rho + rho_max + 1, theta + theta_max + 1) + 1;
                end
            end
        end
    end
    Hough(rho_max + 1, theta_max + 1) = 0;

    %2. houghpeaks，在Hough空间中找到投票数高于阈值的点(>0.3 Max)
    threshold = round(0.3 * max(Hough(:)));
    %符合要求的点对加投票数存储于store_pair中
    store_pair = [];
    for rho = rho_range
        index_rho = rho + rho_max + 1;
        for theta = theta_range;
            index_theta = theta + theta_max + 1;
            if (Hough(index_rho, index_theta) > threshold)
                store_pair = [store_pair ; rho, theta, Hough(index_rho, index_theta)];  %a保存对应的rho 和 theta值(不是索引)
            end
        end
    end

    %3. 基于k-mean对符合要求的点进行聚类
    kk = 4;
    %选取节点的信息
    node = store_pair(:, 1 : 2);
    [size_node, wdw] = size(node);
    %把角度转换为弧度，使-90和89度的点相邻
    transform_angle = [cosd(2 * node(:, 2)), sind(2 * node(:, 2))];
    %调用kmeans对点--弧度进行2分类
    [Idx1, centroid] = kmeans(transform_angle, 2);  
    group1 = [];
    group2 = [];
    for t = 1 : size_node
        if (Idx1(t) == 1)
            group1 = [group1; abs(node(t, 1))];
        else
            group2 = [group2; abs(node(t, 1))];
           %group2 = [group2; node(t, 1)];
        end
    end
    %在每个group下对rho值进行二分类
    [Idx2, centroid] = kmeans(group1, 2);
    [Idx3, centroid] = kmeans(group2, 2);
    Idx = [];
    h = 1;
    g = 1;
    for t = 1 : size_node
        if (Idx1(t) == 1)
            if (Idx2(h) == 1)
                Idx(t) = 1;
                h = h + 1;
                continue;
            end
            if (Idx2(h) == 2)
                Idx(t) = 2;
                h = h + 1;
                continue;
            end
        end
        if (Idx1(t) == 2)
            if (Idx3(g) == 1)
                Idx(t) = 3;
                g = g + 1;
                continue;
            end
            if (Idx3(g) == 2)
                Idx(t) = 4;
                g = g + 1;
                continue;
            end
        end
    end
    %得到Idx，表示对每个符合要求的节点进行了分类(从1至4)
    %选取每个类中最大投票数的点，共取出来4个点(rho, theta)对
    select_4 = zeros(kk, 2);
    themax = zeros(kk);
    for t = 1 :size_node
        frequency = store_pair(t, 3);
        for id = 1 : kk
            if (Idx(t) == id)
                if (themax(id) < frequency)
                    themax(id) = frequency;
                    select_4(id, :) = node(t, :);  %找到密度最大的各聚类下的点，总共4个
                end
            break;
            end
        end
    end

    %4. 根据霍夫空间的四个点找到原空间的四条直线
    num = 0;    
    select_4(:, 1) = select_4(:, 1) * k;  %变化rho为原来的大小
    [m, n] = size(Im1);
    show1 = Im;  %show1表示原照片--彩色
    %figure%, imshow(show1), hold on;
    Hough_trans = zeros(m, n); 
    show2 = Im;
   % figure, imshow(show2), hold on;
    for t = 1 : kk
        result = [];
        rho = select_4(t, 1);
        theta = select_4(t, 2);
        if (theta == 0)
            for i = 1 : m
                if (round(rho - i) == 0)
                    Hough_trans(i, :) = 255;
                    for j = 1 : n
                        result = [result; i, j];
                        show1(i, j, 2) = 255; 
                    end
                end
            end
        elseif (theta == -90)
            for j = 1 : n
                if (round(rho + j) == 0)
                    Hough_trans(:, j) = 255;
                    for i = 1 : m
                        result = [result; i, j];
                        show1(i, j, 2) = 255; 
                    end
                end
            end
        %theta ~= 0
        elseif (theta ~= 0 && theta < 45 && theta > -45)
            for j = 1 : n
                i = round((rho - j * sind(theta)) / cosd(theta));
                if (i > 0 && i <= m)
                    Hough_trans(i, j) = 255;
                    show1(i, j, 2) = 255; 
                    result = [result; i, j];
                end
            end
        else
        % theta <= -45 or theta >= 45
            for i = 1 : m
                j = round((rho - i * cosd(theta)) / sind(theta));
                if (j > 0 && j <= n)
                    Hough_trans(i, j) = 255;
                    show1(i, j, 2) = 255; 
                    result = [result; i, j];
                end
            end
        end
        if (~isempty(result))
            x1 = result(1, 1);
            y1 = result(1, 2);
            [aa,d] = size(result)
            x2 = result(aa, 1);
            y2 = result(aa, 2);    
            %plot([y1,y2],[x1,x2],'Color','r','LineWidth',2);
        end
    end

    %寻找四个交点
    theNode = [];
  
    for i = 1 : 2
        for j = 3 : 4
            rho1 = select_4(i, 1);
            rho2 = select_4(j, 1);
            theta1 = select_4(i, 2);
            theta2 = select_4(j, 2);
            para1 = cosd(theta1);
            para2 = cosd(theta2);
            if (theta1 == theta2)
                continue;
            end
            if (theta1 == -90)
                yy = -1 * rho1;
                xx = (rho2 + rho1 * sind(theta2)) / (para2);
                if (xx > 0 && xx < m && yy > 0 && yy < n)
                    theNode = [theNode; xx, yy];
                end
            elseif (theta2 == -90)
                yy = -1 * rho2;
                xx = (rho1 + rho2 * sind(theta1)) / (para1);
                if (xx > 0 && xx < m && yy > 0 && yy < n)
                    theNode = [theNode; xx, yy];
                end
            else
                yy = (rho1 * para2 - rho2 * para1) / (sind(theta1) * para2 - sind(theta2) * para1);
                xx = (rho1 - yy * sind(theta1)) / (para1);
                yy = round(yy);
                xx = round(xx);
                if (xx > 0 && xx < m && yy > 0 && yy < n)
                    theNode = [theNode; xx, yy];
                end
            end
        end
    end

    %添加点
    [point_nums, no_use] = size(theNode);
    %figure, imshow(Im), hold on;
    %for t = 1 : point_nums
        %scatter(theNode(t,2),theNode(t,1),'markerfacecolor', [ 0, 1, 0 ] );
    %end
    %hold off;
    
    Node = zeros(m, n);
    for t = 1 : point_nums
        Node(round(theNode(t,1)),round(theNode(t,2))) = 255;
    end
    img_marked = Hough_trans;
    corners = theNode;
end
    
        
