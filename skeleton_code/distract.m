function [proj] = distract(test, tk)
[~, M] = size(test);
%记录连续1的开始结点和终止节点
union_find = zeros(1, M);
kk = 1;
limit = 0;

for i = 1 : M
    if (i > 1 && test(i) <= limit && test(i - 1) > limit)
        union_find(i) = 0;
        kk = kk + 1;
    end
    if (test(i) > limit)
        union_find(i) = kk;
    end
end
%删除长度小于tk的union_find的结果
cluster_nums = max(union_find);
new_k = 0;
for k = 1 : cluster_nums
    idx=find(union_find == k);
    len = length(idx);
    if (len > tk)
        new_k = new_k + 1;
        union_find(idx) = new_k;   
    else 
        union_find(idx) = 0;   
    end
end
cluster_nums = max(union_find);   

proj = zeros(cluster_nums, 2);
if (cluster_nums ~= 0)
    for k = 1 : cluster_nums
        idx = find(union_find == k);
        proj(k, 1) = idx(1);
        proj(k, 2) = idx(length(idx));
    end
end

end