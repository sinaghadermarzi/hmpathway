function [ res_vectors ] = Rank_Test(metamodel , flux_vectors)
%Results_Vector = Rank_Test (Metatool_Model,Flux_Vectors) Given a metabolic model in metatool format and a matrix that
%each of its columns indicate a flux to be tested for being an elemntary
%mode
% 
%   the first row of output matrix indicates whether the corresponding flux
%   vector have passed rank test
% 
%   the second row indicates whether the corresponding vector is a steady
%   state vector 
% 
%   the third row indicates whether it satisifes the irrversibility
%   constraints

[rr, cc] = size(metamodel.st);
[~ , n]= size(flux_vectors);

temp_res = zeros(3,n);

for i = 1:n
    
    temp_st = [];
    for j = 1:cc
        if  abs(flux_vectors(j,i))>10e-10
            temp_st = [temp_st , metamodel.st(:,j)];
        end
    end
    st = temp_st;
    [~ , cols]= size(st);

    ra = rank(st);
    if (ra==cols-1)
        temp_res(1,i) = 1;
    end
    
    
    
%     mul = metamodel.st * flux_vectors(:,i);
    
    
%     if(sum(abs(mul)<10e-10))
        temp_res(2,i) = 1;
%     else
%         temp_res(2,i) = 0;
%     end
    
    temp_res(3,i) = 1;
    for j=1:cc
        if (flux_vectors(j,i)<0) & (metamodel.irrev_react(j)==1)
                temp_res(3,i) = 0;
        end
    end
    

    
end

res_vectors = temp_res;




