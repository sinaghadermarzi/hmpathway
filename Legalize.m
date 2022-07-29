function [n_of_dumm new_model new_group Reaction_group] = Legalize(metamodel,group)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[m,r] = size(metamodel.st);
[g,~] = max(group);

Reaction_group = zeros(1,r);
induced_dummies = zeros(1,r);
new_st=metamodel.st;
reaction_group_participation=zeros(r,g);% a matrix whose rows corresponds to reactions and whose columns corresponds to groups and indicates that each reactions have metbolites from which groups and how many of them: if element i,j from this matrix
nx_r = m+1;
nx_c = r+1;
new_group=group;
new_model.irrev_react=metamodel.irrev_react;
for j =1:r
    %determine which group do the participating metabolites belong to
    mets = find(metamodel.st(:,j))';
    for m = mets
        reaction_group_participation(j,group(m)) = reaction_group_participation(j,group(m))+1;
    end
    % here it has been determined that from which groups we have
    % metabolites participating in this reaction.
    participating=find(reaction_group_participation(j,2:g));
    if ~isempty(participating)
        participating = participating+1;
        [Ma , Ind] = max(reaction_group_participation(j,2:g));
        Reaction_group(j) = Ind+1;
        if length(participating)>1
            %if there is more than one group involved in this reaction
            %
            %
            %ADD DUMMY NODES HERE
            
            
            for mi=mets
                if (group(mi)~=Reaction_group(j)) & (group(mi)~=1)
                    dir = sign(new_st(mi,j));
                    new_st(nx_r,nx_c) = -dir;
                    new_st(mi,nx_c)= dir;
                    new_st(nx_r,j)=metamodel.st(mi,j);
                    new_model.irrev_react(nx_c)=metamodel.irrev_react(j);
                    new_st(mi, j)=0;
                    new_group(nx_r)=1;
                    Reaction_group(nx_c)=group(mi);
                    nx_r= nx_r+1;
                    nx_c= nx_c+1;
                    induced_dummies(j)=induced_dummies(j)+1;
                end
            end
            %                 induced_dummies(r) = sum(reaction_group_participation(r,2:g))-Ma;
        end
    else
        Reaction_group(j) = 1;
    end
    
    % here it has been determined that from which groups we have
    % metabolites participating in this reaction.
end
    %Gernerate Output of legalization
    new_model.ext=metamodel.ext;
    new_model.ext(1,nx_c-1)=0;
    new_model.st=new_st;
    n_of_dumm=sum(induced_dummies);
end

