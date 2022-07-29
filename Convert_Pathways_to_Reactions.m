function [ new_model , expanded_sub_efms , coarse_net_info ] = Convert_Pathways_to_Reactions(metamodel,group, reaction_group)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[srows,scols] = size(metamodel.st);
g = max(group);
for i = 1:g
    sub_groups{i}=[];
end

for i = 1:srows
    sub_groups{group(i)} = [sub_groups{group(i)} i];
end


ext_imt = metamodel.ext;

[ex_rows,ex_cols] = size(metamodel.ext);

for i = sub_groups{1}
    ext_imt = [ext_imt ; metamodel.st(i,:)];
end

col_sub_mat = {};

new_net_temp = [];
coarse_net_info = [];
[~,sub_n] = size(sub_groups);


sub_mat_reaction_names={};

irrev_react=[];

for i = 2:sub_n

    row_sub_mat = [];
    sub_rev = [];
    [~,sub_size] = size(sub_groups{i});
    
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
    sub_mat_reaction_indexes{i} = []; %mapping between columns of this submatrix and corresponding columns of original matrix
    
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
    

    temp = CalculateFluxModes(col_sub_mat{i},sub_rev);
    
    efms_sub{i} = temp.efms;
    [n_recs,sub_efm_n] = size(efms_sub{i});
    
    if sub_efm_n ~= 0
        
        subnet_recs{i} = find(conn_rec);
        
        
        
        expanded_sub_efms{i} = [];%zeros(scols,sub_efm_n);
        
        
        irrev=[];
        flag=zeros(1,sub_efm_n);
        cur_rxn=1;
        for k=1:sub_efm_n
            if (flag(k)==0)
                m=k+1;
                cr_flag=false;
                while(m <= sub_efm_n)
                    if (efms_sub{i}(:,k)==-efms_sub{i}(:,m))
                        flag(m)=1;
                        cr_flag=true;
                        irrev = [irrev 0];
                    end
                    m=m+1;
                end
                if cr_flag == false
                    irrev = [irrev 1];
                end
                expanded_sub_efms{i}(:,cur_rxn) = zeros(1,scols);
                for j = 1:n_recs
                    expanded_sub_efms{i}(sub_mat_reaction_indexes{i}(j),cur_rxn) = efms_sub{i}(j,k);
                end
                cur_rxn=cur_rxn+1;
            end
        end
        
        new_reactions = ext_imt*expanded_sub_efms{i};        
        [~ , n_of_new_reactions]= size(new_reactions);
        
        temp_info = 1:n_of_new_reactions;
        
        temp_info(2,:) = i;
        
        new_net_temp = [new_net_temp new_reactions];
        irrev_react = [irrev_react irrev];
        
        coarse_net_info = [coarse_net_info, temp_info];
    end
    
   

    %coarse net info is a two row matrix for annotating the coarse network stoichiometric matrix.
    %number of its columns equals to number of reactions of coarse network.
    %row[2]: element of column 'r' indicates that the reaction number 'r'
    %is added by which subnetwork
    %row[1]: element of column 'r' indicates that the reaction number 'r'
    %corresponds to which efm of that subnetwork
    %
end

[new_row ,newcol] = size(new_net_temp);
current_rxn = 1;
fully_internal_reactions = find(reaction_group==1);
n_intr_rxn = length(fully_internal_reactions);
expanded_sub_efms{1}=zeros(scols,n_intr_rxn);
for j=fully_internal_reactions
    new_net_temp=[new_net_temp ext_imt(:,j)];
    expanded_sub_efms{1}(j,current_rxn)=1;
    temp_info =[current_rxn;1];
    coarse_net_info = [coarse_net_info, temp_info];
    current_rxn=current_rxn + 1;
    irrev_react = [irrev_react metamodel.irrev_react(j)];
end

new_net = new_net_temp;



[new_row, snewcol] = size(new_net);
new_ext = new_net(1:ex_rows,:);
new_st = new_net(ex_rows+1:new_row,:);
% stru = struct('stoich',new_st,'reversibilities',zeros(1,newcol));
% res = CalculateFluxModes(stru);
% coarse_efms = res.efms;
% %fine_grain efms in terms of real network and check what kind of vectors
% [crs_recs_n crs_efms_n] = size(coarse_efms);
% fined_efms = [];
% for i = 1:crs_efms_n
%     % generate fined_efms(:,i)
%     temp = zeros(scols,1);
%     for j = 1:crs_recs_n
%         temp = temp+coarse_efms(j,i)*expanded_sub_efms{coarse_net_info(2,j)}(:,coarse_net_info(1,j));
%     end
%     fined_efms = [fined_efms temp];
% end
% 
% %they are 
% 
% %generate metamodel for this coarsened network 
% metamodel_coarse.st  = new_st;
% metamodel_coarse.irrev_react = ones(1,newcol);
% metamodel_coarse.ext = new_ext;
% 
% 


new_model.st=new_st;
new_model.ext=new_ext;
new_model.irrev_react=irrev_react;


end

