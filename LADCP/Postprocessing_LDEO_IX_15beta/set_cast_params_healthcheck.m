more off;
%mkSADCP('/Data/ADCP/LADDER-1','../data/SADCP/SADCP.mat');
%-------------------------------------------------------------------
% comments: this script process LADCP without CTD input, run this for
% health check after each CTD cast in case CTD data is not ready.
% SD046: S. ZHOU
% 9-Feb 2025
%------------------------------------------------------------------- 

disp(stn)
if ismac
    % ../data/raw/%03d/%03ddn000.000
    f.ladcpup = sprintf('/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_M.000', stn);
    f.ladcpdo = sprintf('/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD046/LADCP/Data/SD046_%03d_SS_S.000', stn);
    f.res = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/LDEO_IX_15beta/processed/');
    f.checkpoints = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/LDEO_IX_15beta/checkpoints/');%JR18005_sample_data/Processing/sadcp/JR18005_006_sadcp');
    f.ctd = sprintf('/Volumes/leg/work/scientific_work_areas/oceanography/CTD/CTD_raw/SBEproc/SD000_%03d_SS_TM.cnv',stn);
end
    f.ctd_header_lines =115;
    f.ctd_fields_per_line = 20;
    f.ctd_pressure_field = 2;
    f.ctd_temperature_field = 3;
    f.ctd_salinity_field =16;
    f.ctd_time_field=14;
    f.ctd_time_base=0;

f.nav = f.ctd;
   f.nav_header_lines =115;
   f.nav_fields_per_line=20;
   f.nav_time_field=14;
   f.nav_lat_field=12;
   f.nav_lon_field=13;
   f.nav_time_base=0;

%f.sadcp = '../data/SADCP/SADCP.mat';

p.drot = 110;
p.brtk_ts = 10;
%p.poss = -60 % the latitude
p.cruise_id = 'SD046';
p.whoami = 'S. Zhou';
p.ladcp_station = stn;
p.name = sprintf('%s cast #%d',p.cruise_id,p.ladcp_station);
p.saveplot=[1:14];
p.saveplot_png  = [];


p.edit_mask_dn_bins = [1];
p.edit_mask_up_bins = [1];

p.checkpoints = [1];