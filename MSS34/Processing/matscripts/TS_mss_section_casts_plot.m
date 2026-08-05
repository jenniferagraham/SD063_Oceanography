%Script to plot all casts from one section for comparison
%Plot T-S diagrams for section coloured by cast or depth
%Created 3.8.2026 by Ellie Fisher
% Rewrite as a function?

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

% load mss eventlog
msslog = readtable(fullfile(disk,'oceanography\MSS34\MicroStructure_Shear_(MSS)_logbook.csv'));
msslog = renamevars(msslog, ...
    ['Latitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Latitude_' ...
    'Longitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Longitude_', ...
    'MSSStation_BuiltIn_String_', ...
    'EventNumber_BuiltIn_String_', ...
    'MSSCastNumber_BuiltIn_String_', ...
    'EventAction_BuiltIn_String_'], ...
    ['lat', ...
    'lon', ...
    'station', ...
    'event', ...
    'cast', ...
    'action']);

gridpath= 'L:\work\scientific_work_areas\gis\bathymetry_grids\';

addpath([disk,'matlabF\']) % theta_sdiag function
addpath([disk,'matlabF\m_map\'])
addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\'])
addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
addpath(['L:\work\scientific_work_areas\oceanography\CTD\plot_transects\']) % directory with section parameter function

FZ=12;
set(0, 'DefaultAxesFontSize', FZ);

%% Create parameter object 
% Use sdaSectionParamsMSS?
params = sdaSectionParamsMSS('3mtransectmss');
nMSS = 1:length(params.castlist); % array with station IDs

% preallocate size of arrays for each variable
maxdepth = params.maxy*2; % deepest cast (which will have greatest length) - half step interval between values, so multiplied by two
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
Tmin=params.tcaxis(1);
Tmax=params.tcaxis(2);
Smin=params.scaxis(1);
Smax=params.scaxis(2);
[Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
sigma0 = gsw_sigma0(Sg,Tg);

alpha = 0.5;

%% for loop to load data
for ii=1:length(nMSS) % select range of casts for this section
    cast = params.castlist(ii);

    mssname = [cruise,sprintf('_mss_%03d_struct.mat',cast)]; % string formatting to pad 1 digit cast numbers
    load ([disk,'oceanography\MSS34\DATA\',mssname]);
    
    % specify rows to write to according to length of data
    myPress(1:length(mss.data.press),ii) = [mss.data.press];
    myT(1:length(mss.data.press),ii)     = [mss.data.temp];
    myS(1:length(mss.data.press),ii)     = [mss.data.sal];
    myEPS(1:length(mss.data.press),ii)   = [mss.data.epsilon];

    %% Retrieving absolute salinity and conservative temperature for location of cast

    % Calculate midpoint lat-lon value for each cast
    lat = mean(msslog(msslog.cast==cast,'lat')); % midpoint (mean) of latitude during cast
    lon = mean(msslog(msslog.cast==cast,'lon')); % midpoint (mean) of longitude during cast

    %% Populating array the same size as other cast variables with midpoint lat-lon
    rows = length(mss.data.press); % Adjusts the size of the lat/lon array to agree with other variables
    lat_arr = zeros(rows,1);
    lat_arr(:,:) = table2array(lat);
    lon_arr = zeros(rows,1);
    lon_arr(:,:) = table2array(lon);

    asal(1:length(mss.data.press),ii)=gsw_SA_from_SP(myS(1:length(mss.data.press),ii),...
                          myPress(1:length(mss.data.press),ii),...
                          lat_arr,...
                          lon_arr);
    ct(1:length(mss.data.press),ii)=gsw_CT_from_t(asal(1:length(mss.data.press),ii),...
                                              myT(1:length(mss.data.press),ii),...
                                              myPress(1:length(mss.data.press),ii));

end

%% Create figure, shaded by CTD cast

for i = 1:length(nMSS)

    cast = params.castlist(i);

    S = asal(:,i);
    T = ct(:,i);

    scatter(S,T,12,...
        repmat(cast,length(S),1),...
        'filled',...
        'MarkerFaceAlpha',alpha);
end

colormap(flipud(cmocean('thermal')))
cb = colorbar;
clim([1 55])
cb.Label.String = 'MSS Number';

xlabel('Absolute salinity (‰)') % need to fix unicode
ylabel('Conservative temperature (°C)') % need to fix unicode
title('T-S Diagram coloured by Cast Number - ',params.sectionname)

grid on
box on

xlim([Smin, Smax])
ylim([Tmin, Tmax])

contour(Sg,Tg,sigma0,'k','ShowText','on')

set(gcf,'Position',[100 100 800 600])