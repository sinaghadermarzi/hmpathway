stoich = res.stoich;
met_names = res.metaboliteNames;
reaction_names = res.reactionNames;


[num_of_metabolites num_of_reactions] = size(stoich)
reaction_formula = {};
for i = 1:num_of_reactions
    product = [];
    reactant = [];
    for j = 1:num_of_metabolites
        if abs(stoich(j,i))> 0.00000001
            if stoich(j,i) > 0
                product = [product , [j ; stoich(j,i)]]
            elseif stoich(j,i) < 0
                reactant = [reactant ,[j ; -stoich(j,i)]]
            end
        end
    end
    reaction_formula{i} = [reaction_names{i} ':   '];
    [dum num_of_reactants]  = size(reactant);
    [dum num_of_products]  = size(product);
    
    
    k = 0; 
    for rec = reactant
        if k > 0
            reaction_formula{i} = [reaction_formula{i} '+ '];
        end
        reaction_formula{i} = [reaction_formula{i} num2str(rec(2,1)) ' [' met_names{rec(1,1)} '] '];
        k = k+1;
    end
    
    reaction_formula{i} = [reaction_formula{i} '=> '];
    
    pro = [];
    k = 0; 
    for pro = product
        if k > 0
            reaction_formula{i} = [reaction_formula{i} '+ '];
        end

        reaction_formula{i} = [reaction_formula{i} num2str(pro(2,1)) ' [' met_names{pro(1,1)} '] '];
        k = k+1;
    end
    
end