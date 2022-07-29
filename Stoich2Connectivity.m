function [adj] = Stoich2Connectivity(metatoolmodel)
%Stoich2connectivity Converts a metatool model to an adjacency matirx 
%   This function takes a metatool model and convert it to an adjacency matrix of
%   metabolite nodes based on the reactions they are involved.


[st_rows ,st_columns] = size(metatoolmodel.st);
Temp = zeros(st_rows);
for i = 1:st_columns
    connected_nodes=(find(metatoolmodel.st(:,i)))';
    [~ , n_con]= size(connected_nodes);
    for j = 1:n_con
        for k=1:n_con
            if (j~=k)
                Temp(connected_nodes(j),connected_nodes(k))= Temp(connected_nodes(j),connected_nodes(k))+1;
            end
        end
    end
end

adj = [];
for i = 1:st_rows
    adj(1,i+1) = i;
end

for i = 1:st_rows
    adj(i+1,1)= i;
    for j= 1:st_rows
        if(j>i)
            adj(i+1,j+1)=Temp(i,j);
        end
    end
end
