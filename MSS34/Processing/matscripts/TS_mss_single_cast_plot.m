%Script to plot all casts from one section for comparison
%Plot T-S diagrams for each single cast in one section
%Created 3.8.2026 by Ellie Fisher
% Rewrite as a function?

addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
close all; clear all;

disk = ['L:\work\scientific_work_areas\oceanography\'];
mssdata = [disk,'MSS34\DATA\fasteps\'];
cruise='SD63';

% load mss eventlog
msss = readtable(fullfile(disk,"MSS34\MicroStructure_Shear_(MSS)_logbook.csv"));
msss = renamevars(msss, ...
    ["Latitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Latitude_" ...
    "Longitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Longitude_", ...
    "MSSStation_BuiltIn_String_", ...
    "EventNumber_BuiltIn_String_", ...
    "MSSCastNumber_BuiltIn_String_", ...
    "EventAction_BuiltIn_String_"], ...
    ["lat", ...
    "lon", ...
    "station", ...
    "event", ...
    "cast", ...
    "action"]);

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
params = sdaSectionParamsMSS("3minner_towyo");

%% for loop to load data
for ii=1:length(params.castlist) % select range of casts for this section
    
    cast = params.castlist(ii);

    mssname= [sprintf('SD6300%02d_eps.mat',cast)]; % string formatting to pad 1 digit cast numbers
    load ([disk,'MSS34\DATA\fasteps\',mssname]);
  
    myPress = [data.press];
    myT     = [data.temp];
    myS     = [data.sal];
    myEPS   = [data.epsilon];

    %% Retrieving absolute salinity and conservative temperature for location of cast
    % stepping through the event log in intervals of 2 (capturing only inWater entries)
    % msss_idx = ~1:2:height(msss);
    % Should be able to use this to index with cast numbers?
    
    % Calculate midpoint lat-lon value for each cast
    lat = mean(msss(msss.cast==cast,"lat")); % midpoint (mean) of latitude during cast
    lon = mean(msss(msss.cast==cast,"lon")); % midpoint (mean) of longitude during cast

    %% Populating array the same size as other cast variables with midpoint lat-lon
    rows = length(data.press); % Adjusts the size of the lat/lon array to agree with other variables
    lat_arr = zeros(rows,1);
    lat_arr(:,:) = table2array(lat);
    lon_arr = zeros(rows,1);
    lon_arr(:,:) = table2array(lat);

    asal=gsw_SA_from_SP(myS,myPress,lat_arr,lon_arr);
    ct=gsw_CT_from_t(asal,myT,myPress);
    
    %% Create grid for sigma0 contours
    Tmin=params.tcaxis(1);
    Tmax=params.tcaxis(2);
    Smin=params.scaxis(1);
    Smax=params.scaxis(2);
    [Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
    sigma0 = gsw_sigma0(Sg,Tg);
    
    alpha = 0.5;
    %% Create figure for each cast
    figure

    hold on
    
        S = asal;
        T = ct;
    
        scatter(S,T,12,...
            repmat(i,length(S),1),...
            'filled',...
            'MarkerFaceAlpha',alpha);
    
    xlabel('Absolute salinity (‰)') % need to fix unicode
    ylabel('Conservative temperature (°C)') % need to fix unicode
    title('T-S Diagram for cast:',cast)
    
    grid on
    box on
    
    xlim([Smin, Smax])
    ylim([Tmin, Tmax])
    
    contour(Sg,Tg,sigma0,'k','ShowText','on')
    
    set(gcf,'Position',[100 100 800 600])
    
    %exportgraphics(gcf,[disk,'MSS34\Processing\Figures\','SD063_TS_',num2str(cast),'.png'],'Resolution',300)

end
