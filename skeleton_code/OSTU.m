function oimg = OSTU(img)
    %grayimg = rgb2gray(img);%将图像转为灰度图
    grayimg = double(img);
    %计算直方图,每个灰度级的概率
    [r c] = size(grayimg);
    histogram = zeros(1,256);
    for i=1:r
        for j=1:c
            histogram(grayimg(i,j)+1) = histogram(grayimg(i,j)+1)+1;
        end
    end
    %归一化
    histogram = histogram./(r*c);
    
    %初始化一个阈值，随后遍历每一个灰度级K
    k = 0;
    result = zeros(1,256);
    while (k<256)        
        %计算两个类的累计概率和
        p1 = sum(histogram(1:k+1));%类1概率的累加概率
        p2 = sum(histogram(k+2:256));%类2概率的累加
        %计算两个类的均值和全局的均值
        m1 = 0;
        m2 = 0;
        mG = 0;
        for i=0:k
            m1 = m1 + i*histogram(i+1)/p1;
        end
        for i=k+1:255
            m2 = m2 + i*histogram(i+1)/p2;
        end
        for i=0:255
            mG = mG + i*histogram(i+1);
        end
        %计算全局方差和类间方差
        Gg = 0;
        Gb = 0;
        %全局方差
        for i=0:255
            Gg = Gg + (i-mG)^2*histogram(i+1);
        end
        %类间方差
        Gb = p1*(m1-mG)^2+p2*(m2-mG);
        %获得使类间方差最大的K值，可能有多个，多个则求平均
        result(k+1) = Gb; 
        k = k+1;
    end
    [maxGb KK] = max(result); 
    %调整了一下，使用-60效果最好
    KK = KK - 60;
    oimg = grayimg;
    for i=1:r
        for j=1:c
            if(grayimg(i,j)>KK)
                oimg(i,j) = 0;
            else
                oimg(i,j) = 1;
            end
        end
    end
end
