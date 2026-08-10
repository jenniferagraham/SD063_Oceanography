% Plot MSS data for one section against background CTD data in whole fjord
% Created 5.8.2026 by Ellie Fisher

%% define variables 
clear all ; clc; close all 

mac=0;
%% define the paths

if mac==0 % ellie you should be able to run it using mac=0 you may need to adjust some of the paths
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
    disk = ['L:\work\scientific_work_areas\']; %
    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    mssdataP = [disk,'oceanography\MSS34\DATA\'];
    ctddata = [disk,'\oceanography\CTD\BASproc\'];
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
    ctddata = [disk,'oceanography/CTD/BASproc/'];
    figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    addpath([disk,'oceanography/CTD/plot_transects/']) % create a similar one for MSS
end

cruise= 'SD063';

%% Create parameter object 
% Use sdaSectionParamsMSS?
mssparams = sdaSectionParamsMSS('all3m');
nMSS = 1:length(mssparams.castlist); % array with station IDs

%% load mss eventlog (Laura's version)
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
indxRow = find(mssLog.Use==1); % inWater rows only
% create work table
msslogLon = mssLog.Longitude_dd(indxRow);
msslogLat = mssLog.Latitude_dd(indxRow);
mssLogMSScast = mssLog.MSScast(indxRow);

% preallocate size of arrays for each variable
maxdepth = mssparams.maxy*2; % deepest cast (which will have greatest length) - half step interval between values, so multiplied by two
temparray = zeros(maxdepth,length(nMSS))*NaN; % NaN array with no. columns equal to number of casts

myPress = temparray;
myT = temparray;
myS = temparray;
myEPS = temparray;
asal = temparray;
ct = temparray;

%% Create figure for casts to plot onto

figure
hold on

% Create grid for sigma0 contours
Tmin=mssparams.tcaxis(1);
Tmax=mssparams.tcaxis(2);
Smin=mssparams.scaxis(1);
Smax=mssparams.scaxis(2);
[Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
sigma0 = gsw_sigma0(Sg,Tg);

alpha = 0.5;

%% for loop to load data
for ii=1:length(nMSS) % select range of casts for this section
    cast = mssparams.castlist(ii);

    mssname = [cruise,sprintf('_mss_%03d_struct.mat',cast)]; % string formatting to pad 1 digit cast numbers
    load ([mssdataP,mssname]);

    % specify rows to write to according to length of data
    myPress(1:length(mss.data.press),ii) = [mss.data.press];
    myT(1:length(mss.data.press),ii)     = [mss.data.temp];
    myS(1:length(mss.data.press),ii)     = [mss.data.sal];
    myEPS(1:length(mss.data.press),ii)   = [mss.data.epsilon];

    % Retrieving absolute salinity and conservative temperature for location of cast

    % Retrieve lat and lon for each cast
    lat = msslogLat(find(mssLogMSScast == cast)); % Indexing mssLogLat using position of cast from mssLogMSScast
    lon = msslogLon(find(mssLogMSScast == cast)); 

    % Populating array the same size as other cast variables with midpoint lat-lon
    rows = length(mss.data.press); % Adjusts the size of the lat/lon array to agree with other variables
    lat_arr = zeros(rows,1);
    lat_arr(:,:) = lat;
    lon_arr = zeros(rows,1);
    lon_arr(:,:) = lon;

    asal(1:length(mss.data.press),ii)=gsw_SA_from_SP(myS(1:length(mss.data.press),ii),...
        myPress(1:length(mss.data.press),ii),...
        lat_arr,...
        lon_arr);
    ct(1:length(mss.data.press),ii)=gsw_CT_from_t(asal(1:length(mss.data.press),ii),...
        myT(1:length(mss.data.press),ii),...
        myPress(1:length(mss.data.press),ii));

end

%% Load CTD data and retrieve ct, asal for all fjord measurements

load([ctddata,cruise,'_ctd.mat']);

nCast = length(ctds);
for n=1:nCast
    ctds(n).asal=gsw_SA_from_SP(ctds(n).salin,ctds(n).press,ctds(n).lon,ctds(n).lat);
    ctds(n).ct=gsw_CT_from_t(ctds(n).asal,ctds(n).temp,ctds(n).press);
end
%sd_ctds=ctds;

% Retrieve only data for CTD casts in Sorgenfri inner - comparable location to MSS?
ctdparams = sdaSectionParams('all3m');

% Only works if ctds.station starts at 1 
% and increases monotonically with no repeats
ctds_inner = ctds(ctdparams.sectionlist); % within condition needed?

% T-S points for CTDs
for i = 1:length(ctds_inner) % Extract all casts, store in an array
    ctdS(:,i) = ctds_inner(i).asal(:);
    ctdT(:,i) = ctds_inner(i).ct(:);
end

%% Populate figure with MSS points for section (red) and background CTD points (grey, transparent?)

scatter(ctdS(:),ctdT(:),12,[0.5,0.5,0.5],...
    'filled',...
    'MarkerFaceAlpha',alpha,...
    'DisplayName',[mssparams.sectionname, ' CTDs']);

% MSS section values (plot on top)
mssS = asal;
mssT = ct;

scatter(mssS(:),mssT(:),12,'red',...
    'filled',...
    'MarkerFaceAlpha',alpha,...
    'DisplayName',[mssparams.sectionname, ' MSS']);

grid on
box on

xlim([Smin, Smax])
ylim([Tmin, Tmax])

contour(Sg,Tg,sigma0,'k','ShowText','on', 'HandleVisibility','off')
% Suppress density contours from showing in legend

hold off

xlabel('Absolute salinity (‰)') % need to fix unicode
ylabel('Conservative temperature (°C)') % need to fix unicode
%title(['T-S Diagram - ', mssparams.sectionname, ' plus CTDs'])
legend('show')

set(gcf,'Position',[100 100 800 600])