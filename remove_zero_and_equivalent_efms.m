
distilled_fined_efms = [];
[fined_recs_n , fined_efms_n] = size(new_fined_efms);
checked = false(1,fined_efms_n);
for i = 1:(fined_efms_n - 1)
    if ~(checked(i))
        distilled_fined_efms = [distilled_fined_efms new_fined_efms(:,i)];
        for j =i+1:fined_efms_n
            if ~checked(j)
                if (abs(new_fined_efms(:,i)>0.0001))==(abs(new_fined_efms(:,j))>0.0001);
                    checked(j) = true;
                end
            end
        end
    end
end

ranks = [];
[~ , n_of_efms_distilled] = size(distilled_fined_efms);
for i = 1:n_of_efms_distilled
    ranks(i) = n_of_subnet_kernel_vectors(metamodel.st,distilled_fined_efms(:,i));
end
