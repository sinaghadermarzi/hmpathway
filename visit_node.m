function [] = visit_node(node,current_cc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global adj;
global cc;
global deg;
    adjacents=find(adj(node,:));
    cc(node) = current_cc;
    deg(node)= length(adjacents);
    for i = adjacents
        if cc(i)== 0
            visit_node(i,current_cc);
        end
    end
end

