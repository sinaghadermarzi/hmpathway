%res = CalculateFluxModes(metamodel.st,not(metamodel.irrev_react));


%efms=res.efms;
%efms=distilled_fined_efms;
[sbmlfile , sbmlpath, filter] = uigetfile();

sbmlmodel= TranslateSBML([sbmlpath sbmlfile],0,0);

metamodel = sbmlModel2metatool(sbmlmodel)
[cc,rr] = size(metamodel.st);

res = CalculateFluxModes(metamodel.st,ones(rr)) 
efms= res.efms;

[~,efm_n] = size(efms);
[ex_rows,ex_cols] = size(metamodel.ext);
[srows,scols] = size(metamodel.st);

fileID = fopen([sbmlpath sbmlfile '.[edgelist].csv'],'w');
edgelist = 'Source,Target';
for i = 1:efm_n
    a = floor(i/100);
    b = floor(i/10)-10*a;
    c = i-100*a-10*b;
    edgelist = [edgelist ',efm' num2str(a) num2str(b) num2str(c)];
end
edgelist = [edgelist '\n'];


for i = 1:srows
    for j = 1:scols
        if(metamodel.st(i,j) > 0 )
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
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
            
        elseif(metamodel.st(i,j) < 0  )
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
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        end        
    end
end

for i = 1:ex_rows
    for j = 1:ex_cols
        if(metamodel.ext(i,j) > 0 )
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
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        elseif(metamodel.ext(i,j)<0 )
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
            edgelist = [edgelist '\n'];
            fprintf(fileID,edgelist);
            edgelist = '';
        end
        
    end
end




fclose(fileID);

nodelist = 'nodeID,type,label\n';

for i=1:srows
    nodelist = [nodelist 'm' num2str(i) ',met,' metamodel.int_met{i} '\n'];
end
for i=1:ex_rows
    nodelist = [nodelist 'e' num2str(i) ',ext,' metamodel.ext_met{i} '\n'];
end

for i=1:scols
    if metamodel.irrev_react(i)==0
        nodelist = [nodelist 'r' num2str(i) ',rev,' metamodel.react_name{i} '\n'];
    else
        nodelist = [nodelist 'r' num2str(i) ',irr,' metamodel.react_name{i} '\n'];
    end
end


fileID = fopen([sbmlpath sbmlfile '.[nodelist].csv'],'w');
fprintf(fileID,nodelist);
fclose(fileID);


