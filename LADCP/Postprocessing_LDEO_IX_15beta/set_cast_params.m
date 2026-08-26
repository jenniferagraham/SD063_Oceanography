more off;
%mkSADCP('/Data/ADCP/LADDER-1','../data/SADCP/SADCP.mat');
%-------------------------------------------------------------------
% comments: this script takes processed CTD (if available in BASproc) and
% calibrated CTD (if available in BASproc) for LADCP processing, if
% neither files exist, a preliminary version of script will take CTD raw
% date from SBEproc to convert CTD input into same format as processed one.
% SD063: S. ZHOU
% 9-Feb 2025
%------------------------------------------------------------------- 

disp(stn)

if ismac
    ladcp_rawdir='/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD063/LADCP/Data';
    ladcp_logdir='/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD063/LADCP/Logs';
    ctd_rawdir='/Volumes/leg/work/scientific_work_areas/oceanography/CTD/SBEproc';
    ctd_procdir='/Volumes/leg/work/scientific_work_areas/oceanography/CTD/BASproc';
    sadcp_dir = '/Volumes/leg/work/scientific_work_areas/oceanography/VMADCP/processed/CODAS/150kHz/os150nb_STA_postproc/contour/';
    f.res = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/processed_withVMADCP/SD063_%03d_ladcp',stn);
    f.checkpoints = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/checkpoints/');
    f.MVBSresultsdir = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/processed_withVMADCP/%03d/',stn);
    f.sadcp='/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/converted_input/SDA_sadcp.mat';
    gsw_dir='/Volumes/leg/work/scientific_work_areas/oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16';
elseif ispc % change the drive name accordingly!!
    ladcp_rawdir='L:\system\ctd_seabird_sbe911plus\acquisition\data\SD063\LADCP\Data';
    ladcp_logdir='L:\system\ctd_seabird_sbe911plus\acquisition\data\SD063\LADCP\Logs';
    ctd_rawdir='L:\work\scientific_work_areas\oceanography\CTD\SBEproc';
    ctd_procdir='L:\work\scientific_work_areas\oceanography\CTD\BASproc';
    sadcp_dir='L:\work\scientific_work_areas\oceanography\VMADCP\processed\CODAS\150kHz\os150nb_STA_postproc\contour'; 
    f.res = sprintf('L:\\work\\scientific_work_areas\\oceanography\\LADCP\\Postprocessing_LDEO_IX_15beta\\processed_withVMADCP\\SD063_%03d_ladcp',stn);
    f.checkpoints = sprintf('L:\\work\\scientific_work_areas\\oceanography\\LADCP\\Postprocessing_LDEO_IX_15beta\\checkpoints\\');
    f.MVBSresultsdir = sprintf('L:\\work\\scientific_work_areas\\oceanography\\LADCP\\Postprocessing_LDEO_IX_15beta\\processed_withVMADCP\\%03d\\',stn);
    f.sadcp='L:\work\scientific_work_areas\oceanography\LADCP\Postprocessing_LDEO_IX_15beta\converted_input\SDA_sadcp.mat';
    gsw_dir='L:\work\scientific_work_areas\oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16';
elseif isunix
    ladcp_rawdir='/mnt/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD063/LADCP/Data';
    ladcp_logdir='/mnt/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD063/LADCP/Logs';
    ctd_rawdir='/mnt/leg/work/scientific_work_areas/ctd/SBEproc';
    ctd_procdir='/mnt/leg/work/scientific_work_areas/ctd/BASproc';
    f.res = sprintf('/mnt/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/processed/SD063_%03d_ladcp',stn);
    f.checkpoints = sprintf('/mnt/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/checkpoints/');
    f.MVBSresultsdir = sprintf('/mnt/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/processed/%03d/',stn);
else
    error('Paths not defined for your platform. If ispc, check the drive name.)');
end

% add GSW toolbox
addpath(gsw_dir)

f.ladcpdo=fullfile(ladcp_rawdir,sprintf('SD063_%03d_SS_M.000',stn));
% upward looking commented out because it's not mounted
f.ladcpup=' ';%fullfile(ladcp_rawdir,sprintf('SD063_%03d_SS_S.000',stn));

f.ladcplogdo=fullfile(ladcp_logdir,sprintf('SD063_%03d_SS_M.txt',stn));
% upward looking commented out because it's not mounted
f.ladcplogup=' ';%fullfile(ladcp_logdir,sprintf('SD063_%03d_SS_S.txt',stn));

ctd_cnv=fullfile(ctd_rawdir,sprintf('SD063_%03d_SS_actm.cnv',stn));
ctd_mstar=fullfile(ctd_procdir,sprintf('SD063_ctd_%03d.1hz',stn));
ctd_prof_mstar=fullfile(ctd_procdir,sprintf('SD063_ctd_%03d_090_2db.mat',stn));
ctd_mstar_cal=fullfile(ctd_procdir,sprintf('SD063_ctd_%03d_cal.1hz',stn));
ctd_prof_mstar_cal=fullfile(ctd_procdir,sprintf('SD063_ctd_%03d_090_cal.2db.mat',stn));

if ~exist(ctd_mstar,'file') || ~exist(ctd_prof_mstar,'file')
  if exist(ctd_cnv,'file')
    set_cast_params_prelim_sd063;
    return;
  else
    error('Missing CTD files (neither preliminary nor mstar available)');
  end
end
fprintf(1,'Loading CTD time series & nav data from %s\n',ctd_mstar);
ctd_1hz=load(ctd_mstar,'gtime','scan','press','temp1','cond1','salin1','lonscan','latscan','-mat');
ctd_date=datenum(ctd_1hz.gtime)+ ...
    ctd_1hz.scan(1:end-1)./3600./24./24;
ctd_juldate=ctd_date-datenum(max(datevec(ctd_date(1))),1,0);

ctd_lon=ctd_1hz.lonscan(1:end-1);
ctd_lat=ctd_1hz.latscan(1:end-1);
ctd_pres=ctd_1hz.press(1:end-1);
ctd_temp=ctd_1hz.temp1(1:end-1);
ctd_cond=ctd_1hz.cond1(1:end-1);
ctd_sal=ctd_1hz.salin1(1:end-1);

ctd_cnv=fullfile(ctd_rawdir,sprintf('SD063_%03d_SS_actm.cnv',stn));

[ctd_rawdate,ctd_rawdata,~,~,~]=cnv2mat(ctd_cnv);
ctd_raw.date=ctd_rawdata(:,2)./3600./24+datenum(ctd_rawdate)-datenum(ctd_rawdate(1),1,0);
ctd_raw.pres=ctd_rawdata(:,3);
ctd_pres(isnan(ctd_pres))=interp1(ctd_raw.date,ctd_raw.pres,ctd_juldate(isnan(ctd_pres)),'nearest','extrap');

f.nav=sprintf('converted_input/SD063_%03d_nav.txt',stn);

if exist(ctd_mstar_cal,'file')
    ctd_mstar=ctd_mstar_cal;
end
if exist(ctd_prof_mstar_cal,'file')
    ctd_prof_mstar=ctd_prof_mstar_cal;
end
[ctddate,ctddata,ctdnames,~,~]=cnv2mat(ctd_cnv);
ctdnames=strtrim(strtok(cellstr(ctdnames(:,12:end)),':'));


if exist(f.nav,'file')
    delete(f.nav);
end
fid=fopen(f.nav,'w');
fprintf(fid,'%.8f %.6f %.6f\n',[ctd_juldate,ctd_lat,ctd_lon]');
fclose(fid);

f.nav_time_base=1;

f.ctd=sprintf('converted_input/SD063_%03d_ctd.txt',stn);

if exist(f.ctd,'file')
    delete(f.ctd);
end
fid=fopen(f.ctd,'w');
fprintf(fid,'%.8f %.2f %.3f %.3f\n',[ctd_juldate,ctd_pres,ctd_temp,ctd_sal]');...
fclose(fid);

f.ctd_time_base=1;

f.ctdprof=sprintf('converted_input/SD063_%03d_ctdprof.txt',stn);

fprintf(1,'Loading CTD profile data from %s\n',ctd_prof_mstar);
ctd_2db=load(ctd_prof_mstar,'press','salin','temp');
ctd_prof_sal=ctd_2db.salin(~isnan(ctd_2db.temp));
ctd_prof_pres=ctd_2db.press(~isnan(ctd_2db.temp));
ctd_prof_temp=ctd_2db.temp(~isnan(ctd_2db.temp));
% if ctd_prof_pres(1)>8
%     ctd_prof_pres=[4;ctd_prof_pres];
%     ctd_prof_temp=ctd_prof_temp([1,1:end]);
%     ctd_prof_sal=ctd_prof_sal([1,1:end]);
% end

if exist(f.ctdprof,'file')
    delete(f.ctdprof);
end

fid=fopen(f.ctdprof,'w');
fprintf(fid,'%.2f %.3f %.3f\n',[ctd_prof_pres,ctd_prof_temp,ctd_prof_sal]');...
fclose(fid);
f.sadcp='/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/converted_input/SDA_sadcp.mat';

if ~exist('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/converted_input/SDA_sadcp.mat','file')

    sadcp_files = 'os150nb.nc';
    tim_sadcp = julian(datevec(ncread(fullfile(sadcp_dir,sadcp_files),'time')'+datenum(2025,1,1)))';
    good_ind=find(~isnan(tim_sadcp));
    lat_sadcp = ncread(fullfile(sadcp_dir,sadcp_files),'lat')';
    lon_sadcp = ncread(fullfile(sadcp_dir,sadcp_files),'lon')';
    u_sadcp = ncread(fullfile(sadcp_dir,sadcp_files),'u');
    v_sadcp = ncread(fullfile(sadcp_dir,sadcp_files),'v');
    z_sadcp = ncread(fullfile(sadcp_dir,sadcp_files),'depth',[1 1],[Inf 1]);

    tim_sadcp=tim_sadcp(good_ind);
    lat_sadcp=lat_sadcp(good_ind);
    lon_sadcp=lon_sadcp(good_ind);
    u_sadcp=u_sadcp(:,good_ind);
    v_sadcp=v_sadcp(:,good_ind);

    %%%%%%%
    %Mask any data that is below 25% good
    pg = ncread(fullfile(sadcp_dir,sadcp_files),'pg');
    pg=pg(:,good_ind);
    mask_pg=ones(size(pg));
    mask_pg(pg<25) = NaN;

    u_sadcp = u_sadcp.*mask_pg;
    v_sadcp = v_sadcp.*mask_pg;
    %%%%%%%

    save (f.sadcp,'*_sadcp');
    clear *_sadcp
end

p.drot = 110;
p.brtk_ts = 10;

%p.poss = -60 % the latitude
p.cruise_id = 'SD063';
p.whoami = 'C. Schmidt';
p.ladcp_station = stn;
p.name = sprintf('%s cast #%d',p.cruise_id,p.ladcp_station);
p.saveplot= [];
p.saveplot_png = 1:15;


p.edit_mask_dn_bins = [1];
p.edit_mask_up_bins = [1];

p.checkpoints = [1];

% if ismember(stn,[1 8 11 16 17 48 49 53 56 57 63])
%     p.btrk_mode = 0;
% end