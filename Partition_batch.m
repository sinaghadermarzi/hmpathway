% [sbmlfile , sbmlpath, filter] = uigetfile('*.xml');
% hmetis_path = 'C:\Users\Sina\Downloads\hmetis-1.5.3-WIN32\hmetis-1.5.3-WIN32\';
% 
% sbmlmodel= TranslateSBML([sbmlpath sbmlfile],0,0);
% 
% metamodel = sbmlModel2metatool(sbmlmodel);
% 
% 

% metamodel.st=full(cobramodel.S);
% metamodel.irrev_react=not(cobramodel.rev)';
% metamodel.ext=[];

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
orig_kern=size(null(metamodel.st));
uniquified_st={};
uniquified_irrev_react={};
for i = 2:50
    
    %gr = input('Enter the partitioning number : ');
    my_group = KPartition(metamodel,4,i,30);
    % my_group = group(gr,:);
    [n_dumm(i), new_model, new_group, reaction_group]= Legalize(metamodel,my_group);
    [leg_rr, leg_cc]= size(new_model.st);
    [coarse_model, expanded_sub_efms, coarse_net_info] = Convert_Pathways_to_Reactions(new_model,new_group,reaction_group);
    [n_rr_c(i), n_cc_c(i)]= size(coarse_model.st);
    [uniquified_st_t,ia,ic]  = unique(coarse_model.st','rows');
     c_irrev_react_t = coarse_model.irrev_react';
     u_irrev_react_t=c_irrev_react_t(ia,:);
     uniquified_irrev_react{i}=u_irrev_react_t';
    uniquified_st{i}=uniquified_st_t';
    [~,unique_n]=size(uniquified_st{i});
    rep(i)=n_cc_c(i)-unique_n;
    kern(:,i)=(size(null(coarse_model.st)))';
    unique_kernel(:,i)=(size(null(uniquified_st{i})))';
end
