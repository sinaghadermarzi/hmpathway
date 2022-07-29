count = 0;
[dumm,efm_n] = size(res.efms);
cver = zeros(1,efm_n);
dist(1:210) = 10000
[srows,scols] = size(metamodel.st);
for i = 1:(efm_n-1)
%    minindex = i+1;
%    mindist = norm(abs(res.efms(:,i))-abs(res.efms(:,i+1)));
    for j = i+1:efm_n
        newdist = norm(abs(res.efms(:,i))-abs(res.efms(:,j)));
        if newdist <= 0.0000000001
            minindex = j;
            count = count+1;
            efms(1:scols,count)= res.efms(:,i);
%           mindist = newdist;
            cver(i) = minindex;
        end
    end

end