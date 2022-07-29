
[dumm,sub_n] = size(sub_groups);
[srows,scols] = size(metamodel.st);
for i = 1:sub_n
    row_sub_mat = [];
    sub_rev = [];
    [dumm , sub_size] = size(sub_groups{i});
    conn_recs= [];
    for j = 1:sub_size
        row_sub_mat(j,:) = metamodel.st(sub_groups{i}(j),:);
%        conn_recs = [conn_recs find(sub_mat(j,:))];
        
    end
%    sub_rev = not(metamodel.irrev_react);
    
    conn_rec = any([row_sub_mat ; zeros(1,scols)]);
    current_col = 1;
    col_sub_mat = [];
    for j=1:scols
        if conn_rec(j)==1
            col_sub_mat(:,current_col) = row_sub_mat(:,j);
            sub_rev(current_col) = not(metamodel.irrev_react(j));
            current_col = current_col+1;
        end
    end
    temp_stru = struct('stoich',col_sub_mat,'reversibilities',sub_rev);
    temp = CalculateFluxModes(temp_stru);
    efms_sub{i}=temp.efms;
    subnet_recs{i} = find(conn_rec);
    current_col = 1;
    [n_recs,sub_efm_n] = size(temp.efms);
    for j = 1:scols
        if conn_rec(j) == 1
            expanded_sub_efms{i}(j,:)=temp.efms(current_col,:);
            current_col = current_col+1;
        else
            expanded_sub_efms{i}(j,:)= zeros(1,sub_efm_n);
        end
    end
end
