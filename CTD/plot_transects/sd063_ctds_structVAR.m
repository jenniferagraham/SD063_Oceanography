close all; clear all;
% need to create a structure variable with all CTD data 
% row must be a station 
% column are the variables
savename = 'sd063_ctd.mat'; 

%%
here=pwd;
if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    %sd063_CTD = [disk,'SDA063-GIANT\'];
     sd063_CTD = [disk,'CTD\BASproc\'];
     sd063_LADCP = [disk,'LADCP\Postprocessing_LDEO_IX_15beta\',...
         'processed_withVMADCP\'];
  %  skagerakCTD = [disk,'Skagerak_cruise_2025_Data\CTD\processed\final_mat\'];
  %  pathO18 = [disk,'KANG_GLAC\Povl_O-18scripts\'];
    figPb = [here,'\Figures\'];
 %   addpath([disk,'matlabF\']) % theta_sdiag function
%    addpath([disk,'matlabF\GSW\'])
    addpath([disk,'\GSWscripts\gsw_matlab_v3_06_16\'])
%    addpath([disk,'matlabF\GSW\thermodynamics_from_t\'])
    FZ=12;
elseif ismac
    %%%NOT YET EDITED - ROSIE 25/07/2026
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    sd063_CTD = [disk,'/CTD/BASproc/'];
    figPb = [here,'/Figures/'];
    addpath([disk,'matlabF/']) % theta_sdiag function
    addpath([disk,'matlabF/m_map/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    FZ=12;
end
% create the station list manually 
% !cd BASproc
% ! ls *2bd.mat > stationlist.txt
%sd063_CTDlist=[sd063_CTD,'stationlist.txt'];
%filepath = ' sd063_CTD';

stationlist = dir(fullfile(sd063_CTD, 'SD063_ctd_*_struct.mat'));

%filenames = readlines(sd063_CTDlist); 
filenames = stationlist.name;

for ii = 1:length(stationlist)
    
    currentName = stationlist(ii).name;
    load([sd063_CTD,currentName])
    stnid = sprintf('%03d',ctd.station);

    % Add LADCP data to structure... 
    % NB. Needs to be same size as CTD depths? (2db?)
    ladcpfile = fullfile(sd063_LADCP,stnid,...
        sprintf('SD063_data_%s.mat',stnid));
    if isfile(ladcpfile)
        load(ladcpfile)

        ladcp_vel = dr.u + 1j*dr.v;
        vel2db = interp1(dr.p, ladcp_vel, ctd.press); 
        ctd.ladcp_u = real(vel2db);
        ctd.ladcp_v = imag(vel2db);
    else
        fprintf('WARNING: LADCP missing for %s\n', stnid)
        ctd.ladcp_u = nan;
        ctd.ladcp_v = nan;

    end
    ctds(ctd.station) = ctd; % should I change the names?

end
save(fullfile(sd063_CTD, 'SD063_ctd.mat'),'ctds')