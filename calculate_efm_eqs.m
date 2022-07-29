res = CalculateFluxModes(struct('stoich',metamodel.st,'reversibilities',not(metamodel.irrev_react)))
efm_EQs = metamodel.ext * res.efms

[ext_n efm_n] = size(efm_EQs);
efm_eq_string = {};
for i = 1:efm_n
    prod = [];
    reactt = [];
    for j = 1:ext_n
        if abs(efm_EQs(j,i))> 0.00000001
            if efm_EQs(j,i) > 0
                prod = [prod , [j ; efm_EQs(j,i)]]
            elseif efm_EQs(j,i) < 0
                reactt = [reactt ,[j ; -efm_EQs(j,i)]]
            end
        end
    end
    efm_eq_string{i} = [];
    [dum rec_n]  = size(reactt);
    [dum pro_n]  = size(prod);
    
    
    k = 0; 
    for rec = reactt
        if k > 0
            efm_eq_string{i} = [efm_eq_string{i} '+ '];
        end
        efm_eq_string{i} = [efm_eq_string{i} num2str(rec(2,1)) ' [' metamodel.ext_met{rec(1,1)} '] '];
        k = k+1;
    end
    
    efm_eq_string{i} = [efm_eq_string{i} '=> '];
    
    pro = [];
    k = 0; 
    for pro = prod
        if k > 0
            efm_eq_string{i} = [efm_eq_string{i} '+ '];
        end

        efm_eq_string{i} = [efm_eq_string{i} num2str(pro(2,1)) ' [' metamodel.ext_met{pro(1,1)} '] '];
        k = k+1;
    end
    
end