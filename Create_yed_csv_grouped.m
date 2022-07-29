

res = CalculateFluxModes(metamodel.st,not(metamodel.irrev_react));
efms_nr = res.efms;
[dumm,sub_n] = size(sub_groups);
[srows,scols] = size(metamodel.st);
[dumm,efm_n] = size(efms_nr);
[ex_rows,ex_cols] = size(metamodel.ext);



met_groups= zeros(1,srows);

for i = 1:sub_n
    [dumm , sub_size] = size(sub_groups{i});
    for(j = 1:sub_size)
        met_groups(sub_groups{i}(j)) = i;
    end   
end



rec_groups = zeros(1,scols);
for i = 1:scols
    if(any(find(metamodel.ext(:,i))))
        rec_groups(i) = 0;
    else        
        neighbour = find(metamodel.st(:,i));
        neighbour = neighbour';
        [dumm , neighbour_n] = size(neighbour);
        if neighbour_n ~= 0
            t = neighbour(1);
            intern = true;
            for j = 1:neighbour_n
                if(met_groups(neighbour(j))~= met_groups(t))
                    intern = false;
                end
            end
            if (intern)
                rec_groups(i) = met_groups(t);                
            
            else
                rec_groups(i) =0;
            end
        end        
    end
end






count = 0;
cver = zeros(1,efm_n);
dist(1:210) = 10000
efms = efms_nr;
efm_rev = [];
for i = 1:(efm_n -1)
%    minindex = i+1;
%    mindist = norm(abs(res.efms(:,i))-abs(res.efms(:,i+1)));
    for j = i+1:efm_n
        newdist = norm(abs(res.efms(:,i))-abs(res.efms(:,j)));
        if newdist <= 0.0000000001
            minindex = j;
            count = count+1;
            efms(1:scols,count)= efms_nr(:,i);
           mindist = newdist;
            cver(i) = minindex;
%            efms(:,j) = [];
%            efm_rev(i) = 1;
        end
    end
end

[dumm,efm_n] = size(efms);
col_sub_mat={};

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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    temp = CalculateFluxModes(col_sub_mat{i},sub_rev);
    efms_sub{i}=temp.efms;
    subnet_recs{i} = find(conn_rec);
    current_col = 1;
    [n_recs,sub_efm_n] = size(temp.efms);
    
    expanded_sub_efms{i} = zeros(scols,sub_efm_n);
    
    for k=1:sub_efm_n        
        for j = 1:n_recs
            expanded_sub_efms{i}(sub_mat_reaction_indexes{i}(j),k) =  efms_sub{i}(j,k);
        end
    end  
end




fileID = fopen('edgelist.csv','w');
edgelist = 'Source,Target';
for i = 1:efm_n
    a = floor(i/100);
    b = floor(i/10)-10*a;
    c = i-100*a-10*b;
    edgelist = [edgelist ',efm' num2str(a) num2str(b) num2str(c)];
end
for i=1:sub_n
    [dumm , sub_efm_n] = size(expanded_sub_efms{i});
    for j = 1:sub_efm_n
        edgelist = [edgelist ',sub' num2str(i) '_efm' num2str(j)];
    end    
end
edgelist = [edgelist '\n'];


for i = 1:srows
    for j = 1:scols
        if(metamodel.st(i,j) == 1 )
            edgelist = [edgelist 'r' num2str(j) ',m' num2str(i)];
            for k = 1:efm_n
                flux = efms(j,k);
                if(flux == 0)
                    dir = 'zero';
                elseif(flux>0)
                    dir = 'forw';
                elseif(flux<0)
                    dir = 'back';
                end
                edgelist = [edgelist ',' dir];
            end
            for s=1:sub_n
                [dumm , sub_efm_n] = size(expanded_sub_efms{s});
                for k = 1:sub_efm_n
                    flux = expanded_sub_efms{s}(j,k);
                    if met_groups(i) ~=s
                        flux = 0;
                    end;
                    if(flux == 0)
                        dir = 'zero';
                    elseif(flux>0)
                        dir = 'forw';
                    elseif(flux<0)
                        dir = 'back';
                    end
                    edgelist = [edgelist ',' dir];
                end
            end
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
            
        elseif(metamodel.st(i,j) == -1 )
            edgelist = [edgelist 'm' num2str(i) ',r' num2str(j)];
            for k = 1:efm_n
                flux = efms(j,k);
                if(flux == 0)
                    dir = 'zero';
                elseif(flux>0)
                    dir = 'forw';
                elseif(flux<0)
                    dir = 'back';
                end
                edgelist = [edgelist ',' dir];
            end
            for s=1:sub_n
                [dumm , sub_efm_n] = size(expanded_sub_efms{s});
                for k = 1:sub_efm_n
                    flux = expanded_sub_efms{s}(j,k);
                    if met_groups(i) ~=s
                        flux = 0;
                    end;                    
                    if(flux == 0)
                        dir = 'zero';
                    elseif(flux>0)
                        dir = 'forw';
                    elseif(flux<0)
                        dir = 'back';
                    end
                    edgelist = [edgelist ',' dir];
                end
            end
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        end
        
    end
end

for i = 1:ex_rows
    for j = 1:ex_cols
        if(metamodel.ext(i,j) == 1 )
            edgelist = [edgelist edgelist 'r' num2str(j) ',e' num2str(i)];
            for k = 1:efm_n
                flux = efms(j,k);
                if(flux == 0)
                    dir = 'zero';
                elseif(flux>0)
                    dir = 'forw';
                elseif(flux<0)
                    dir = 'back';
                end
                edgelist = [edgelist ',' dir];
            end
            for s=1:sub_n
                [dumm , sub_efm_n] = size(expanded_sub_efms{s});
                for k = 1:sub_efm_n
                    flux = expanded_sub_efms{s}(j,k);
                    if met_groups(i) ~=s
                        flux = 0;
                    end;                    
                    if(flux == 0)
                        dir = 'zero';
                    elseif(flux>0)
                        dir = 'forw';
                    elseif(flux<0)
                        dir = 'back';
                    end
                    edgelist = [edgelist ',' dir];
                end
            end
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        elseif(metamodel.ext(i,j) == -1 )
            edgelist = [edgelist 'e' num2str(i) ',r' num2str(j)];
            for k = 1:efm_n
                flux = efms(j,k);
                if(flux == 0)
                    dir = 'zero';
                elseif(flux>0)
                    dir = 'forw';
                elseif(flux<0)
                    dir = 'back';
                end
                edgelist = [edgelist ',' dir];
            end
            for s=1:sub_n
                [dumm , sub_efm_n] = size(expanded_sub_efms{s});
                for k = 1:sub_efm_n
                    flux = expanded_sub_efms{s}(j,k);
                    if met_groups(i) ~=s
                        flux = 0;
                    end;                    
                    if(flux == 0)
                        dir = 'zero';
                    elseif(flux>0)
                        dir = 'forw';
                    elseif(flux<0)
                        dir = 'back';
                    end
                    edgelist = [edgelist ',' dir];
                end
            end
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        end
        
    end
end




fclose(fileID);





nodelist = 'nodeID,type,group\n';

for i=1:srows
    nodelist = [nodelist 'm' num2str(i) ',met,' num2str(met_groups(i)) '\n'];
end
for i=1:ex_rows
    nodelist = [nodelist 'e' num2str(i) ',ext,0\n'];
end

for i=1:scols
    if metamodel.irrev_react(i)==0
        nodelist = [nodelist 'r' num2str(i) ',rev,' num2str(rec_groups(i)) '\n'];
    else
        nodelist = [nodelist 'r' num2str(i) ',irr,' num2str(rec_groups(i)) '\n'];
    end
end

fileID = fopen('nodelist.csv','w');
fprintf(fileID,nodelist);
fclose(fileID);
