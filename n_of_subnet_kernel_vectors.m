function  [n_v]= n_of_subnet_kernel_vectors(stoich,flux_vector)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    temp_st = [];
    [r , c] = size(stoich);
    for i = 1:c
        if flux_vector(i,1) ~= 0
            temp_st = [temp_st , stoich(:,i)];
        end
    end
    st = temp_st;
    [~ , cols]= size(st);
%     for i = 1:r
%         if any(temp_st(i,:))
%             st = [st ; temp_st(i,:)];
%         end
%     end
    kern = null(st);
    [dumm , n_v] = size(kern);
    ra = rank(st);
end
