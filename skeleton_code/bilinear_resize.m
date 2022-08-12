function [ ZI ] = bilinear( I,zmf1, zmf2 )
  % 实现了基于双线性插值法的图像拉伸，放缩
 [IH,IW, ID] = size(I);
 ZIH = round(IH*zmf1);     
 ZIW = round(IW*zmf2);   
 ZI = zeros(ZIH,ZIW, ID);  


 %双线性插值。
 IT = zeros(IH+2,IW+2, ID);
 IT(2:IH+1,2:IW+1,:) = I;
 IT(1,2:IW+1,:)=I(1,:,:);
 IT(IH+2,2:IW+1,:)=I(IH,:,:);
 IT(2:IH+1,1,:)=I(:,1,:);
 IT(2:IH+1,IW+2,:)=I(:,IW,:);
 IT(1,1,:) = I(1,1,:);
 IT(1,IW+2,:) = I(1,IW,:);
 IT(IH+2,1,:) = I(IH,1,:);
 IT(IH+2,IW+2,:) = I(IH,IW,:);

 for zj = 1:ZIW        
     for zi = 1:ZIH
         ii = (zi-1)/zmf1; jj = (zj-1)/zmf2;
         i = floor(ii); j = floor(jj);    
         u = ii - i; v = jj - j;
         i = i + 1; j = j + 1;
         ZI(zi,zj,:) = (1-u)*(1-v)*IT(i,j,:) + (1-u)*v*IT(i,j+1,:) + u*(1-v)*IT(i+1,j,:) + u*v*IT(i+1,j+1,:);
     end
 end
 ZI = uint8(ZI);
 end  