function [ group ] = KPartition(metamodel,threshold,k,Imbalance_ratio)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

hmetis_path='C:\Users\Sina\Downloads\hmetis-1.5.3-WIN32\hmetis-1.5.3-WIN32\';

[ex_rows,ex_cols] = size(metamodel.ext);
[srows,scols] = size(metamodel.st);

%Calculate the degree of each of nodes
degree = zeros(1,srows);
for i = 1: srows
    degree(i) = length(find(metamodel.st(i,:)));
end
%Ask the user for the threshold for intermediate nodes

number_of_partitions=k;
%Based on the specified threshold, select some of the nodes as intermediate
%and some of them as internal nodes
%create a network that is optained by removing intermediate nodes and save
%this network in hmetis input file format
group = zeros(1,srows);
current_row=1;
orig_row=[];
network_cortex_temp=[];
for i = 1:srows
    if(degree(i)>threshold)
        group(i)=1;
    else
        network_cortex_temp = [network_cortex_temp ; metamodel.st(i,:)];
        orig_row(current_row)=i;
        current_row = current_row+1;
    end
end
network_cortex=[];
orig_col=[];
current_col=1;
for j=1:scols
    if (any(network_cortex_temp(:,j)))
        network_cortex =[network_cortex , network_cortex_temp(:,j)];
        orig_col(current_col)= j;
        current_col=current_col+1;
    end
end

[n,h]= size(network_cortex);

graphfile = fopen([hmetis_path 'temp.hgr'],'w');
output_line=[int2str(h) ' ' int2str(n) '\n'];
fprintf(graphfile,output_line);
for i = 1: h
    output_line=[];
    for inc=find((network_cortex(:,i))')
        output_line= [output_line int2str(inc) ' '];
    end
    fprintf(graphfile,[output_line '\n']);
end
fclose(graphfile);
                                                                                                                   % N C Ob V
%Call hmetis with  appropriate parameters
dos([hmetis_path 'khmetis.exe ' hmetis_path 'temp.hgr ' int2str(number_of_partitions) ' ' num2str(Imbalance_ratio), ' 20 4 1 3 0' ]);



%read the results and construct the subgroups varaiable based on the
%partitioning result from hmetis

disp('Hmetis finished!  Now reading Hemtis Results');

resfileid = fopen([hmetis_path  'temp.hgr.part.' num2str(number_of_partitions)]);
if (resfileid==-1)
    error('The file could not be opened!');
else
    tline = fgets(resfileid);
    if ~ischar(tline)
        disp('Hmetis Result Empty');
    else
        current_node=1;
        while ischar(tline)
            group(orig_row(current_node))=str2num(tline)+2;
            tline = fgets(resfileid);
            current_node = current_node+1;
        end
    end
    fclose(resfileid);
end

end

