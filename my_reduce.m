function [ sys ] = my_reduce(sys,out_fname)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
out_fid= fopen(out_fname, 'w');
%    freq_analysis(out_fid, sys);
    sys.all_int= all_integer(sys.st);
%    sys.all_int= 0; % deactivate integer calculations
    if (sys.all_int)
      sys.kn= kernel_fp(sys.st, [], sys.all_int);
    else
      sys.kn= kernel(sys.st);
    end
%    if (sys.all_int) % alternative method for making an integer kernel
%      sys.kn= make_integer_cols(sys.kn);
%    end
    sys.crel= kernel(sys.st');
    fmatout(out_fid, sys.st, 'STOICHIOMETRIC MATRIX', sys.irrev_react);
    show_dead_ends(sys.st, sys.irrev_react);
    if out_fid ~= -1
      fmatout(out_fid, sys.kn', 'KERNEL');
%%%%      fenzyme_output(out_fid, sys.kn, -ones(1, size(sys.kn, 2)), sys.react_name);
%%%%      foverall_output(out_fid, sys.kn, sys);
      fmatout(out_fid, sys.crel', 'CONSERVATION RELATIONS');
%%%%      fcons_rel_output(out_fid, sys.crel, sys.int_met);
    end
    [sys.sub, sys.irrev_rd, sys.blocked_react, sys.sub_irr_viol]= subsets(sys.kn, sys.irrev_react, sys.all_int);
    if out_fid ~= -1
      fmatout(out_fid, sys.sub, 'SUBSETS');
%%%      fenzyme_output(out_fid, sys.sub', sys.irrev_rd, sys.react_name);
      if ~isempty(sys.blocked_react)
	fprintf(out_fid, 'The following enzymes do not participate in any reaction:\n');
% 	for i= sys.blocked_react
% 	  fprintf(out_fid, '%s ', sys.react_name{i});
% 	end
	fprintf(out_fid, '\n\n');
      end
%%%      foverall_output(out_fid, sys.sub', sys, 1);
      if ~isempty(sys.sub_irr_viol)
	fmatout(out_fid, sys.sub_irr_viol, 'subsets that are removed because they violate irreversibility constraints');
%%%	fenzyme_output(out_fid, sys.sub_irr_viol', ones(1, size(sys.sub_irr_viol, 1)), sys.react_name);
%%%	foverall_output(out_fid, sys.sub_irr_viol', sys, 1);
      end
    end
%    [sys.rd, sys.rd_met, sys.irrev_rd]= reduce(sys.st, sys.sub, sys.irrev_rd); % deletes zero columns 
    [sys.rd, sys.rd_met]= reduce(sys.st, sys.sub); % keeps zero columns
    fclose(out_fid);

end

