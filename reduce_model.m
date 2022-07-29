MASK_LENGTH=cc-18;

cd('C:\Users\Sina\Documents\MATLAB\efmtool\efmtool');
NUMBER_OF_RANDS= 1000000;
unique_rands = unique( floor(rand(1,  NUMBER_OF_RANDS )*cc)+1);
mask=unique_rands(1:MASK_LENGTH);

reduced_model.ext=[];
reduced_model.st=metamodel.st(:,mask);
reduced_model.irrev_react=metamodel.irrev_react(:,mask);

%Backup
%   metamodel_b=metamodel;


%Restore
%   metamodel=metamodel_b;


%Apply
%   metamodel=reduced_model;

% CalculateFluxModes(uniquified_st{6},not(uniquified_irrev_react{6}));

% CalculateFluxModes(metamodel.st,not(metamodel.irrev_react));