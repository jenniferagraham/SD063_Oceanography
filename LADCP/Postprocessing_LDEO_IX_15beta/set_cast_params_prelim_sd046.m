more off;
%mkSADCP('/Data/ADCP/LADDER-1','../data/SADCP/SADCP.mat');
%-------------------------------------------------------------------
% on stn 4, switched heads but not serial numbers in DEFAULTS.expect
% on stn 9, uplooker bombed; after stn 17, no uplooker available
%------------------------------------------------------------------- 

disp(stn)

if ismac
    ctd_rawdir = '/Volumes/leg/work/scientific_work_areas/ctd/SBEproc';
    ctd_procdir = '/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
    f.ladcpup = sprintf('/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_S.000', stn);
    f.ladcpdo = sprintf('/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_M.000', stn);
    f.res = sprintf('/Volumes/leg/work/scientific_work_areas/physics/LADCP/LDEO_IX_15beta/processed/SD046_%03d_ladcp',stn);
    f.checkpoints = sprintf('/Volumes/leg/work/scientific_work_areas/physics/LADCP/LDEO_IX_15beta/checkpoints/');
elseif ispc % change the drive name accordingly!!
    f.ladcpup = sprintf('L:\leg\system\ctd_seabird_sbe911plus\acquisition\data\SD046\LADCP\Data\SD046_%03d_SS_S.000', stn);
    f.ladcpdo = sprintf('L:\leg\system\ctd_seabird_sbe911plus\acquisitio\/data\SD046\LADCP\Data\SD046_%03d_SS_M.000', stn);
    f.res = sprintf('L:\leg\work\scientific_work_areas\physics\LADCP\LDEO_IX_15beta\processed/SD046_%03d_ladcp',stn);
    f.checkpoints = sprintf('L:\Volumes\leg\work\scientific_work_areas\physics\LADCP\LDEO_IX_15beta\checkpoints\');
elseif isunix
    f.ladcpup = sprintf('/mnt/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_S.000', stn);
    f.ladcpdo = sprintf('/mnt/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_M.000', stn);
    f.res = sprintf('/mnt/leg/work/scientific_work_areas/physics/LADCP/LDEO_IX_15beta/processed/SD046_%03d_ladcp',stn);
    f.checkpoints = sprintf('/mnt/leg/work/scientific_work_areas/physics/LADCP/LDEO_IX_15beta/checkpoints/');
else
    error('Paths not defined for your platform. If ispc, check drive name!)');
end


ctd_cnv=fullfile(ctd_rawdir,sprintf('SD046_%03d_SS_actm.cnv',stn));

[ctddate,ctddata,ctdnames,~,~]=cnv2mat(ctd_cnv);
ctdnames=strtrim(strtok(cellstr(ctdnames(:,12:end)),':'));

f.nav=sprintf('converted_input/SD046_%03d_nav.txt',stn);

ctd_yearday=ctddata(:,strmatch('timeS',ctdnames))./3600./24+datenum(ctddate)-datenum(ctddate(1),1,0);
ctd_lat=ctddata(:,strmatch('latitude',ctdnames));
ctd_lon=ctddata(:,strmatch('longitude',ctdnames));
ctd_pres=ctddata(:,strmatch('prDM',ctdnames));
ctd_temp=ctddata(:,strmatch('t090C',ctdnames));
ctd_cond=ctddata(:,strmatch('c0mS/cm',ctdnames));
ctd_sal=gsw_SP_from_C(ctd_cond,ctd_temp,ctd_pres);
ctd_scan=ctddata(:,strmatch('scan',ctdnames));
ctd_pump=ctddata(:,strmatch('pumps',ctdnames));

ctd_yearday_1hz=ctd_yearday(1:24:end);
ctd_lon_1hz=nan(size(ctd_yearday_1hz(1:end-1)));
ctd_lat_1hz=nan(size(ctd_yearday_1hz(1:end-1)));
ctd_pres_1hz=nan(size(ctd_yearday_1hz(1:end-1)));
ctd_temp_1hz=nan(size(ctd_yearday_1hz(1:end-1)));
ctd_cond_1hz=nan(size(ctd_yearday_1hz(1:end-1)));

for n=1:length(ctd_yearday_1hz)-1
    ind=find(ctd_yearday>=ctd_yearday_1hz(n) & ...
        ctd_yearday<ctd_yearday_1hz(n+1));
    ctd_lon_1hz(n)=nanmean(ctd_lon(ind));
    ctd_lat_1hz(n)=nanmean(ctd_lat(ind));
    ctd_pres_1hz(n)=nanmean(ctd_pres(ind));
    ctd_temp_1hz(n)=nanmean(ctd_temp(ind));
    ctd_cond_1hz(n)=nanmean(ctd_cond(ind));
end
ctd_yearday_1hz=ctd_yearday_1hz(1:end-1);
ctd_sal_1hz=gsw_SP_from_C(ctd_cond_1hz,ctd_temp_1hz,ctd_pres_1hz);

fid=fopen(f.nav,'w');
fprintf(fid,'%.8f %.6f %.6f\n',[ctd_yearday_1hz,ctd_lat_1hz,ctd_lon_1hz]');
fclose(fid);
f.nav_time_base=1; % time base: 0, seconds elapsed; 1, year day; 2, Georgian (decimal day)

f.ctd=sprintf('converted_input/SD046_%03d_ctd.txt',stn);

fid=fopen(f.ctd,'w');
fprintf(fid,'%.8f %.2f %.3f %.3f\n',[ctd_yearday_1hz,ctd_pres_1hz,ctd_temp_1hz,ctd_sal_1hz]');...
fclose(fid);

f.ctd_time_base=1; % time base: 0, seconds elapsed; 1, year day; 2, Georgian (decimal day)

f.ctdprof=sprintf('converted_input/SD046_%03d_ctdprof.txt',stn);

ctd_prof_pres=1:2:max(ctd_pres);
ctd_prof_temp=nan(size(ctd_prof_pres));
ctd_prof_sal=nan(size(ctd_prof_pres));

[~,ctd_botind]=max(ctd_pres);
temp_pres=ctd_pres(ctd_scan<=ctd_botind & ctd_pump);
temp_temp=ctd_temp(ctd_scan<=ctd_botind & ctd_pump);
temp_sal=ctd_sal(ctd_scan<=ctd_botind & ctd_pump);

for n=1:length(ctd_prof_pres)
    ourinds=find(temp_pres>(ctd_prof_pres(n)-1) & ...
        temp_pres<=ctd_prof_pres(n)+1);
    if isempty(ourinds), continue, end
    ctd_prof_temp(n)=nanmedian(temp_temp(ourinds));
    ctd_prof_sal(n)=nanmedian(temp_sal(ourinds));
end    

fid=fopen(f.ctdprof,'w');
fprintf(fid,'%.2f %.3f %.3f\n',[ctd_prof_pres;ctd_prof_temp;ctd_prof_sal]);...
fclose(fid);

%f.sadcp = '../data/SADCP/SADCP.mat';

p.drot = 110;
p.brtk_ts = 10;
%p.poss = -60 % the latitude
p.cruise_id = 'SD046';
p.whoami = 'S. Zhou';
p.ladcp_station = stn;
p.name = sprintf('%s cast #%d',p.cruise_id,p.ladcp_station);
p.saveplot= [];
p.saveplot_png = 1:14;


p.edit_mask_dn_bins = [1];
p.edit_mask_up_bins = [1];

p.checkpoints = [1];