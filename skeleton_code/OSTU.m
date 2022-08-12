function oimg = OSTU(img)
    %grayimg = rgb2gray(img);%��ͼ��תΪ�Ҷ�ͼ
    grayimg = double(img);
    %����ֱ��ͼ,ÿ���Ҷȼ��ĸ���
    [r c] = size(grayimg);
    histogram = zeros(1,256);
    for i=1:r
        for j=1:c
            histogram(grayimg(i,j)+1) = histogram(grayimg(i,j)+1)+1;
        end
    end
    %��һ��
    histogram = histogram./(r*c);
    
    %��ʼ��һ����ֵ��������ÿһ���Ҷȼ�K
    k = 0;
    result = zeros(1,256);
    while (k<256)        
        %������������ۼƸ��ʺ�
        p1 = sum(histogram(1:k+1));%��1���ʵ��ۼӸ���
        p2 = sum(histogram(k+2:256));%��2���ʵ��ۼ�
        %����������ľ�ֵ��ȫ�ֵľ�ֵ
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
        %����ȫ�ַ������䷽��
        Gg = 0;
        Gb = 0;
        %ȫ�ַ���
        for i=0:255
            Gg = Gg + (i-mG)^2*histogram(i+1);
        end
        %��䷽��
        Gb = p1*(m1-mG)^2+p2*(m2-mG);
        %���ʹ��䷽������Kֵ�������ж�����������ƽ��
        result(k+1) = Gb; 
        k = k+1;
    end
    [maxGb KK] = max(result); 
    %������һ�£�ʹ��-60Ч�����
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
