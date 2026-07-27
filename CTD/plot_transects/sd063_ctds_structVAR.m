close all; clear all;
% need to create a structure variable with all CTD data 
% row must be a station 
% column are the variables
savename = 'sd063_ctd.mat'; 

%%
mac=1; % 1 mac or 0 windows
here=pwd;
if mac==0
    disk = ['L:\work\scientific_work_areas\oceanography\CTD\'];
    %sd063_CTD = [disk,'SDA063-GIANT\'];
     sd063_CTD = [disk,'BASproc\'];
  %  skagerakCTD = [disk,'Skagerak_cruise_2025_Data\CTD\processed\final_mat\'];
  %  pathO18 = [disk,'KANG_GLAC\Povl_O-18scripts\'];
    figPb = [here,'\Figures\'];
 %   addpath([disk,'matlabF\']) % theta_sdiag function
%    addpath([disk,'matlabF\GSW\'])
    addpath([disk,'\GSWscripts\gsw_matlab_v3_06_16\'])
%    addpath([disk,'matlabF\GSW\thermodynamics_from_t\'])
    FZ=12;
elseif mac==1
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
    ctds(ii) = ctd; % should I change the names?
end
save(fullfile(sd063_CTD, 'SD063_ctd.mat'),'ctds')