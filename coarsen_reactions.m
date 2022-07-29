clearvars -except metamodel sub_groups


%reaction_names=metamodel.react_name;
%met_names = metamodel.int_met;




% this matrix is a temporary matrix consisting of rows of stoicheomtric
% matrix conrresponding to external and intermediate metabolites

%sub_meta_model={};

ext_imt = metamodel.ext;

[ex_rows,ex_cols] = size(metamodel.ext);

for i = sub_groups{1}
    ext_imt = [ext_imt ; metamodel.st(i,:)];
end

col_sub_mat = {};

new_net_temp = [];
coarse_net_info = [];
[dumm,sub_n] = size(sub_groups);
[srows,scols] = size(metamodel.st);

sub_mat_reaction_names={};

for i = 2:sub_n
    
    
    
    row_sub_mat = [];
    sub_rev = [];
    [dumm , sub_size] = size(sub_groups{i});
    
    conn_recs= [];
    
    for j = 1:sub_size
        row_sub_mat(j,:) = metamodel.st(sub_groups{i}(j),:);
%        sub_met_names{i}{j}=met_names(sub_groups{i}(j))
%        conn_recs = [conn_recs find(sub_mat(j,:))];        
    end
%    sub_rev = not(metamodel.irrev_react);
    
    conn_rec = any([row_sub_mat ; zeros(1,scols)]);
    current_col = 1;
    col_sub_mat{i} = [];
    sub_mat_reaction_indexes{i} = []; %mapping betweein columns of this submatrix and corresponding columns of original matrix
    
%    sub_mat_reaction_names{i}={};
    for j=1:scols
        if conn_rec(j)==1
            col_sub_mat{i}(:,current_col) = row_sub_mat(:,j);
            sub_rev(current_col) = not(metamodel.irrev_react(j));
            sub_mat_reaction_indexes{i}(current_col)= j;
%            sub_mat_reaction_names{i}{current_col}=reaction_names(j);
            current_col = current_col+1;
        end
    end
    
    
    
    
    
    
 %   sub_meta_model{i}.st = col_sub_mat{i};
    
    
    
    [surows,sucols] = size(col_sub_mat{i});
    

    temp = CalculateFluxModes(col_sub_mat{i},zeros(1,sucols));
    
    efms_sub{i} = temp.efms;
    

    
    subnet_recs{i} = find(conn_rec);
    
    [n_recs,sub_efm_n] = size(efms_sub{i});
    
    expanded_sub_efms{i} = zeros(scols,sub_efm_n);
    
    for k=1:sub_efm_n        
        for j = 1:n_recs
            expanded_sub_efms{i}(sub_mat_reaction_indexes{i}(j),k)= efms_sub{i}(j,k);
        end
    end   
    
    new_reactions = ext_imt*expanded_sub_efms{i};
    
    temp_sub = 1:sub_efm_n;
    
    temp_sub(2,:) = i;
    
    new_net_temp = [new_net_temp new_reactions];
    
    coarse_net_info = [coarse_net_info, temp_sub];
    
    %coarse net info is a two row matrix for annotating the coarse network stoichiometric matrix.
    %number of its columns equals to number of reactions of coarse network.
    %row[2]: element of column 'r' indicates that the reaction number 'r'
    %is added by which subnetwork
    %row[1]: element of column 'r' indicates that the reaction number 'r'
    %corresponds to which efm of that subnetwork
    %
end

[new_row_temp, new_col_temp] = size(new_net_temp);

irrev_react=[];
current_col = 1;
new_net = [];
for i = 1:new_col_temp-1
    flag = false;
    for j=i+1: new_col_temp
        if(all(new_net_temp(:,i)==new_net_temp(:,j)))
            flag = true;
        end
        if (all(new_net_temp(:,i)==-new_net_temp(:,j)))
            irrev_react(i)=1;
        end
    end
    if (flag == false)
        new_net = [new_net , new_net_temp(:,i)];
        current_col = current_col+1;
    end
end

new_net = new_net_temp;
%end of compress network


[new_row ,newcol] = size(new_net);
new_ext = new_net(1:ex_rows,:);
new_st = new_net(ex_rows+1:new_row,:);
stru = struct('stoich',new_st,'reversibilities',zeros(1,newcol));
res = CalculateFluxModes(stru);
coarse_efms = res.efms;
%fine_grain efms in terms of real network and check what kind of vectors
[crs_recs_n crs_efms_n] = size(coarse_efms);
fined_efms = [];
for i = 1:crs_efms_n
    % generate fined_efms(:,i)
    temp = zeros(scols,1);
    for j = 1:crs_recs_n
        temp = temp+coarse_efms(j,i)*expanded_sub_efms{coarse_net_info(2,j)}(:,coarse_net_info(1,j));
    end
    fined_efms = [fined_efms temp];
end

%they are 

%generate metamodel for this coarsened network 
metamodel_coarse.st  = new_st;
metamodel_coarse.irrev_react = ones(1,newcol);
metamodel_coarse.ext = new_ext;



orig_efms=CalculateFluxModes(metamodel.st,not(metamodel.irrev_react))