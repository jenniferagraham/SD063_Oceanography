close all; clear all;

mac=0;

if mac==0 % ellie you should be able to run it using mac=0 you may need to adjust some of the paths
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
    disk = ['L:\work\scientific_work_areas\']; %
    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    mssdataP = [disk,'oceanography\MSS34\DATA\'];
    figpath = [disk,'oceanography\MSS34\Processing\Figures\'];
    gridpath= [disk,'\gis\bathymetry_grids\'];
    addpath([disk,'oceanography\matlabF\']) % theta_sdiag function
    addpath([disk,'oceanography\matlabF\m_map\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter function

elseif mac==1
    slash='/';
    disk = ['/Volumes/legwork/scientific_work_areas/'];
    mssdataP = [disk,'oceanography/MSS34/DATA/'];
    figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    % addpath([disk,'oceanography/CTD/plot_transects/']) % create a similar one for MSS
end

cruise='SD063';

%% Create parameter object 
% Use sdaSectionParamsMSS?
mssparams = sdaSectionParamsMSS('3minner');
nMSS = 1:length(mssparams.castlist); % array with station IDs

%% load mss eventlog (Laura's version)
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
indxRow = find(mssLog.Use==1); % inWater rows only
% create work table
msslogLon = mssLog.Longitude_dd(indxRow);
msslogLat = mssLog.Latitude_dd(indxRow);
mssLogMSScast = mssLog.MSScast(indxRow);

%% Use m_map to plot locations of casts
% Common bounding box for all sections (zoomed to fjord)
% Read a shapefile with Sorgenfri area in m_map?
% Easier to Define it from the MSS section lat and long arrays

% Indexing only works if mssLogCast is in order! Need to flip.
mssLogMSScast = flip(mssLogMSScast);
lat=msslogLon(find(flip.mssLogCast);
lon=msslogLon(find(mssLogMSScast=));

%% Plot a Plate Caree projection map over Sorgenfri area
m_proj('Equidistant Cylindrical','longitude',[-30.9 30.3],'latitude',[68.05, 68.4]);  % [-30.9 30.3] [68.05, 68.4]
m_proj("get")
%m_coord('geographic');
m_coast;
m_grid;
%%
m_proj('mercator','lon',max(lon, [], 'omitnan'),'lat',max(lat, [], 'omitnan'));
[x,y]=m_ll2xy(lon,lat,'clip','off');
section_dirs=atan2(diff(y),diff(x));
%%

% to add map 
% add TS plot with all station in the section in one color and the rest of
% the data collected on a different color. 
f=figure;
figPOS = [63 126 436 560];
set(f,'Position',figPOS)
