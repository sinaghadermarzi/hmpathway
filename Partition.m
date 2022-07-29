% [sbmlfile , sbmlpath, filter] = uigetfile('*.xml');
% hmetis_path = 'C:\Users\Sina\Downloads\hmetis-1.5.3-WIN32\hmetis-1.5.3-WIN32\';
% 
% sbmlmodel= TranslateSBML([sbmlpath sbmlfile],0,0);
% 
% metamodel = sbmlModel2metatool(sbmlmodel);
metamodel.st=full(cobramodel.S);
metamodel.irrev_react=not(cobramodel.rev)';
metamodel.ext=[];
cd('C:\Users\Sina\Documents\MATLAB\efmtool\efmtool');


[rr,cc] = size(metamodel.st);
sdumms=zeros(1,25);
group= [];
% for i = 4:40    
% %     group = SPartition(metamodel,4,i,20);
% %     [n_of_dumm new_model  mapping]= Legalize(metamodel,group);
% %     sdumms(i) = n_of_dumm;
%     group = [group;KPartition(metamodel,5,i,20)];
%     [n_of_dumm new_model]= Legalize(metamodel,group(i-3,:));
%     kdumms(i) = n_of_dumm;
% end

%gr = input('Enter the partitioning number : ');
my_group = KPartition(metamodel,4,6,20);
% my_group = group(gr,:);
[n_dumm, new_model, new_group, reaction_group]= Legalize(metamodel,my_group);
[leg_rr, leg_cc]= size(new_model.st);
[coarse_model, expanded_sub_efms, coarse_net_info] = Convert_Pathways_to_Reactions(new_model,new_group,reaction_group);
[n_rr_c, n_cc_c]= size(coarse_model.st);

cmd = input('To Calculate EFMs on new coarsened model enter [c]:','s');

if cmd=='c'    
    res= CalculateFluxModes(coarse_model.st,not(coarse_model.irrev_react));
    coarse_efms = res.efms;
    [~ , n_crs_efms] = size(coarse_efms);    
    fined_efms = [];
    for i = 1:n_crs_efms
        % generate fined_efms(:,i)
        temp = zeros(leg_cc,1);
        for j = 1:n_cc_c
            temp = temp + coarse_efms(j,i) * (expanded_sub_efms{coarse_net_info(2,j)}(:,coarse_net_info(1,j)) );
        end
        fined_efms = [fined_efms temp];
    end   
    unleg_vects = fined_efms(1:cc,:);
    bin_res = (abs(unleg_vects)>10e-10)';
    uniquified_bin_res = unique(bin_res,'rows')';
 %   test_results = Rank_Test(metamodel,uniquified_bin_res);
 %   number_of_efms_found = sum(all(test_results));
end
