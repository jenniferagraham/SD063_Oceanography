function cleanoceanlogSDA(daynumber, yy)
%
% run dspike on oceanlog, then launch interactive editor for SST and SSS
% HJV, JR177 added removal of data when flow too low, and for 5 minute period after
% gaps of over 5 minutes (this could be refined). Also added interactive
% editing of pressure and fluoremeter.
% (dont care about the rest of this stuff?)
%
% mmm, CD160, August 2004
% mmm, jr139, December 2005
% script passed on to Kat Turner from Hugh Venables, and was edited for the
% SD046 cruise in February 2025 to work with scripts provided by Povl
% Abrahamsen

if nargin<2
    [yy,~,~,~,~,~]=datevec(now);
    jday_now=floor(now)-datenum(yy,1,0);

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end

    % if jday_now<120 && daynumber>240
    %     yy=yy-1;
    % end
end

set_underway_params

for sensor=1:length(ocl_sensors)
    fprintf(1,'Cleaning oceanographic sensor %s:\n',ocl_sensors(sensor).set_name_long);

    close all
    
    filename_orig=fullfile('..','ocl',ocl_sensors(sensor).ocl_tables,...
        sprintf('%s_%.2d%.3d.mat',ocl_sensors(sensor).ocl_tables,...
        mod(yy,100),daynumber));
        

end    
% daynumber=input('Input jday number = ');
% filename = strcat('select/oceanlog',daynumber,'.mat');
filename = strcat('../ocl/OCL_raw_',daynumber,'.mat');

load(filename);

filenamesst = strcat('../ocl/SST/sbe38_underwaySST_',daynumber,'.mat');
load(filenamesst);

%pause on


% some rangechecking first:-
% 
% a = find(oceanlog.press1 < 800 | oceanlog.press1 > 1200);
% oceanlog.press1(a) = NaN;
% b = find(isnan(oceanlog.press1)~=1); 
% oceanlog.press1 = interp1(oceanlog.time_secs(b), oceanlog.press1(b), oceanlog.time_secs);
% 
% a = find(oceanlog.press2 < 800 | oceanlog.press2 > 1200);
% oceanlog.press2(a) = NaN;
% b = find(isnan(oceanlog.press2)~=1); 
% oceanlog.press2 = interp1(oceanlog.time_secs(b), oceanlog.press2(b), oceanlog.time_secs);

% some despiking:-
% 
% oceanlog_cond_dspk = dspike(OCL_raw.Conductivity_SpM,0.1);
% oceanlog_saltemp_dspk = dspike(OCL_raw.SalTemp,0.1);
% oceanlog_sst_dspk = dspike(sbe38_underwaySST.sst1,0.1);
% oceanlog_sst2_dspk = dspike(sbe38_underwaySST.sst2,0.1);
% oceanlog_fluor_dspk = dspike(OCL_raw.Fluor,0.1);
% oceanlog_trans_dspk = dspike(OCL_raw.Trans,0.1);
% oceanlog_BeamAtt_dspk = dspike(OCL_raw.BeamAtt,0.1);
% % 
% a = find(isnan(oceanlog_cond_dspk)~=1);
% OCL_raw.Conductivity_SpM = interp1(oceanlog.time_secs(a),oceanlog_cond_dspk(a),oceanlog.time_secs);
% a = find(isnan(oceanlog_saltemp_dspk)~=1);
% OCL_raw.SalTemp = interp1(oceanlog.time_secs(a),oceanlog_saltemp_dspk(a),oceanlog.time_secs);
% a = find(isnan(oceanlog_sst_dspk)~=1);
% sbe38_underwaySST.SST1 = interp1(oceanlog.time_secs(a),oceanlog_sst_dspk(a),oceanlog.time_secs);
% a = find(isnan(oceanlog_sst2_dspk)~=1);
% sbe38_underwaySST.SST2 = interp1(oceanlog.time_secs(a),oceanlog_sst2_dspk(a),oceanlog.time_secs);
% a = find(isnan(oceanlog_fluor_dspk)~=1);
% OCL_raw.Fluor = interp1(oceanlog.time_secs(a),oceanlog_fluor_dspk(a),oceanlog.time_secs);
% a = find(isnan(oceanlog_trans_dspk)~=1);
% OCL_raw.Trans = interp1(oceanlog.time_secs(a),oceanlog_trans_dspk(a),oceanlog.time_secs);
% 
% a = find(isnan(oceanlog_trans_dspk)~=1);
% OCL_raw.Trans = interp1(oceanlog.time_secs(a),oceanlog_trans_dspk(a),oceanlog.time_secs);
% 
% bf=[];
% af = OCL_raw.Flow < 0.40 | OCL_raw.Flow > 1.5;   %find where flow too low or too high
% bf(1)=af(1);
% for i=2:length(af)
%     bf(i)=(bf(i-1)+af(i))*af(i);    %counts how many consecutive low flow periods
% end
% lb=length(bf);
% for i=1:length(bf)-1
%     if bf(lb-i+1)~=0&bf(lb-i)~=0
%   bf(lb-i)=bf(lb-i+1);     %goes back through b setting non-zero values to the total count they are part of
%     end
% end
% iib=bf<300;     %removes periods shorter than 5 minutes
% c=af;
% c(iib)=0;      %creates version of a with short periods removed, can then the used for lagged removal
% c=c(1:length(af)-300);
% %this system doesn't cope with: 
% %a) small number of good flow periods resetting the counts
% %b) a way to make the lagged period longer than the period of data loss
% 
% OCL_raw.SalTemp(af)=NaN;
% OCL_raw.Conductivity_SpM(af)=NaN;
% OCL_raw.Salinity(af)=NaN;
% % oceanlog.velocity(af)=NaN;
% OCL_raw.Fluor(af)=NaN;
% OCL_raw.Trans(af)=NaN;
% % oceanlog.fstemp(af)=NaN;
% sbe38_underwaySST.SST1(af)=NaN;
% sbe38_underwaySST.SST2(af)=NaN;
% 
% OCL_raw.SalTemp(c+300)=NaN;   %remove data from 5 minutes after a drop in flow to allow variables to return, only if gap over 5 minutes
% OCL_raw.Conductivity_SpM(c+300)=NaN;    
% OCL_raw.Salinity(c+300)=NaN;
% %oceanlog.velocity(c+300)=NaN;
% OCL_raw.Fluor(c+300)=NaN;
% OCL_raw.Trans(c+300)=NaN;
% %oceanlog.fstemp(c+300)=NaN;
% sbe38_underwaySST.SST1(c+300)=NaN;
% sbe38_underwaySST.SST2(c+300)=NaN;

figure
plot(OCL_raw.FlowTime,OCL_raw.Flow,'k.')
title('Flow')
disp('Hit any key')
pause
figure
%length(OCL_raw.jday1)
%length(OCL_raw.Conductivity_SpM)
plot(OCL_raw.jday1,OCL_raw.Conductivity_SpM,'k.')
title('Cond')
ceq=input('Needs cleaning? 1/0\n');

%interactive editing
if ceq  %do this first as likely sorts out problems in other variables
    close all
disp('Conductivity');
C35=sw_c3515;
OCL_raw.Conductivity_SpM = interactive_edit(OCL_raw.jday1,OCL_raw.Conductivity_SpM,OCL_raw.Flow,'conductivity');
close all

iic=isnan(OCL_raw.Conductivity_SpM);  %remove sst, saltemp and fluor when cond bad

% sbe38_underwaySST.SST1(iic)=NaN;
% sbe38_underwaySST.SST2(iic)=NaN;
OCL_raw.SalTemp(iic)=NaN;
%OCL_raw.Fluor(iic)=NaN;
%OCL_raw.Trans(iic)=NaN;  %Not on common timestamp
OCL_raw.Salinity(iic)=NaN;
end


figure
plot(sbe38_underwaySST.jday1,sbe38_underwaySST.SST1,'k.')
title('SST')
s1eq=input('Needs cleaning? 1/0\n');
figure
plot(sbe38_underwaySST.jday2,sbe38_underwaySST.SST2,'k.')
title('SST\_2')
s2eq=input('Needs cleaning? 1/0\n');
figure
plot(OCL_raw.jday1,OCL_raw.SalTemp,'k.')
title('TSG temp')
TSGteq=input('Needs cleaning? 1/0\n');
figure
plot(OCL_raw.FluorTime,OCL_raw.Fluor,'k.')
title('Fluor')
feq=input('Needs cleaning? 1/0\n');
figure
plot(OCL_raw.TransTime,OCL_raw.BeamAtt,'k.')
title('Beam Attenuation')
treq=input('Needs cleaning? 1/0\n');
figure
C35=sw_c3515;
OCL_raw.Salinity_uncal = sw_salt(OCL_raw.Conductivity_SpM*10/C35,OCL_raw.SalTemp,0);
plot(OCL_raw.jday1,OCL_raw.Salinity,'k.'); hold on
plot(OCL_raw.jday1,OCL_raw.Salinity_uncal,'b.'); hold on
title('Salinity (direct - black, calc - blue)')
saleq=input('Needs cleaning (blue)? 1/0\n'); 
close all



if s1eq
disp('Remote (hull) temperature');
sbe38_underwaySST.SST1 = interactive_edit(sbe38_underwaySST.jday1,sbe38_underwaySST.SST1,OCL_raw.Flow,'remote hull temp');
% disp('Hit any key')
%pause
close all
end

if s2eq
disp('Remote (hull) temperature_2');
sbe38_underwaySST.SST2 = interactive_edit(sbe38_underwaySST.jday2,sbe38_underwaySST.SST2,OCL_raw.Flow,'remote hull temp_2');
% disp('Hit any key')
%pause
close all
end

if TSGteq
disp('Housing (CTD) temperature');
OCL_raw.SalTemp = interactive_edit(OCL_raw.jday1,OCL_raw.SalTemp,OCL_raw.Flow,'housing (CTD) temp');
% disp('Hit any key')
%pause
close all
end

if feq
disp('Fluorimeter');
OCL_raw.Fluor = interactive_edit(OCL_raw.FluorTime,OCL_raw.Fluor,OCL_raw.Flow,'fluorimeter');
% disp('Hit any key')
%pause
close all
end
% 
% if treq
% disp('Trans');
% OCL_raw.Trans = interactive_edit(OCL_raw.TransTime,OCL_raw.Trans,OCL_raw.Flow,'trans');
% % disp('Hit any key')
% %pause
% close all
% end

if treq
disp('BeamAtt');
OCL_raw.BeamAtt = interactive_edit(OCL_raw.TransTime,OCL_raw.BeamAtt,OCL_raw.Flow,'beamatt');
% disp('Hit any key')
%pause
close all
end

% disp('Pressure1');
% oceanlog.press1 = interactive_edit(oceanlog.time_secs,oceanlog.press1,OCL_raw.Flow,'pressure 1');
% % disp('Hit any key')
% pause
% close all
% 
% disp('Pressure2');
% oceanlog.press2 = interactive_edit(oceanlog.time_secs,oceanlog.press2,OCL_raw.Flow,'pressure 2');
% % disp('Hit any key')
% pause
% close all
C35=sw_c3515;
OCL_raw.Salinity_uncal = sw_salt(OCL_raw.Conductivity_SpM*10,OCL_raw.SalTemp,0);


%
% NOTE THE FACTOR OF 10 !!! to convert S/m to mmho/cm (which ds_salt uses)
% mmm, Dec 2005, jr139

if saleq
OCL_raw.Salinity_uncal = interactive_edit(OCL_raw.jday1,OCL_raw.Salinity_uncal,OCL_raw.Flow,'Uncalib. salinity');
% disp('Hit any key')
iic=isnan(OCL_raw.Salinity_uncal);  %remove sst, saltemp and fluor when cond bad

%sbe38_underwaySST.SST1(iic)=NaN;
%sbe38_underwaySST.SST2(iic)=NaN;
OCL_raw.Conductivity_SpM(iic)=NaN;

end

close all

figure;
plot(OCL_raw.jday1,OCL_raw.Salinity_uncal,'k-');
title('Uncalibrated salinity');
% disp('Hit any key')

close all

OCL_clean=OCL_raw;

% fileout = strcat('select/oceanlog',daynumber,'clean.mat');
fileout = strcat('../OCL/OCL_clean_',daynumber,'.mat');
save(fileout,'OCL_clean');

filesave=strcat('../OCL/SST/sbe38_underwaySST_',daynumber,'_clean.mat')
save (filesave, 'sbe38_underwaySST')
