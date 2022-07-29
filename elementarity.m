[fined_recs_n , fined_efms_n] = size(fined_efms);
el= [];
for i = 1:fined_efms_n
    el = [el n_of_subnet_kernel_vectors(metamodel.st,fined_efms(:,i))];
end