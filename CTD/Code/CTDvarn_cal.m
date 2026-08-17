% Setup script for general CTD processing code - calibration-specific additions
%
% Written by Povl Abrahamsen following SD030 and SD033, to avoid duplication of
% code/settings in cal/non-cal setup scripts
% See cruise reports for JR17003a, JR18004, DY111, SD020 and SD030 for more details

CTDvarn

varnames_add={
            'temp1_uncal' -1    0   1   0   0   1  'Temp1 ^oC uncalibrated'
            'temp2_uncal' -1    0   1   0   0   1  'Temp2 ^oC uncalibrated'
            'tempoffset1' -1    0   1   0   0   1  'Temp1 offset'
            'tempoffset2' -1    0   1   0   0   1  'Temp2 offset'
            'cond1_uncal' -1    0   1   0   0   1  'Cond1 mS cm^{-1} uncalibrated'
            'cond2_uncal' -1    0   1   0   0   1  'Cond2 mS cm^{-1} uncalibrated'
            'condoffset1' -1    0   1   0   0   1  'Cond1 offset'
            'condoffset2' -1    0   1   0   0   1  'Cond2 offset'
  'oxygen1_umol_kg_uncal' -1    0   1   0   0   1  'Oxygen1 umol kg^{-1} uncalibrated'
          'oxygenoffset1' -1    0   1   0   0   1  'Oxygen1 offset'
};
varnames_add_oxy2={
  'oxygen2_umol_kg_uncal' -1    0   1   0   0   1  'Oxygen2 umol kg^{-1} uncalibrated'
          'oxygenoffset2' -1    0   1   0   0   1  'Oxygen2 offset'
};

if ~isempty(strmatch('oxygen2_umol_kg',varnames(:,1),'exact')) % we have secondary oxygen
    varnames=[varnames;varnames_add;varnames_add_oxy2];
else
    varnames=[varnames;varnames_add];
end

% make 1/0 vector of whether sensor is present (column2>0) and variable wanted (column 3~=0)
sv=size(varnames);
vp=zeros(sv(1),1);
vpd=zeros(sv(1),1);
vp_b=zeros(sv(1),1);
for iv=1:sv(1)
    vp(iv)=(varnames{iv,2}*varnames{iv,3})>0;
    vpd(iv)=(varnames{iv,2}*varnames{iv,4})~=0;  %including derived variables
    vp_b(iv)=((varnames{iv,2}~=0)*(varnames{iv,7}));
end

% make 1/0 vector of whether 
% iic=find(strcmp(columnuse,'cal_var')); %ensure looking at right column
% sv=size(varnames);
% vpp=zeros(sv(1),1);
% for iv=1:sv(1)
%     vpc(iv)=(varnames{iv,2}*varnames{iv,iic})~=0;        
% end
vpc=vpd;
