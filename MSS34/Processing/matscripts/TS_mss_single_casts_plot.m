%Script to plot all casts from one section for comparison
%Plot T-S diagrams for each single cast in one section
%Created 3.8.2026 by Ellie Fisher
% Rewrite as a function?

close all; clear all;

%% define paths
mac = 0; % laura uses mac,

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

%% load mss eventlog
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
indxRow = find(mssLog.Use==1); % inWater rows only
% create work table
msslogLon = mssLog.Longitude_dd(indxRow);
msslogLat = mssLog.Latitude_dd(indxRow);
mssLogMSScast = mssLog.MSScast(indxRow);

FZ=12;
set(0, 'DefaultAxesFontSize', FZ);

%% Create parameter object 
params = sdaSectionParamsMSS('3minner_towyo');

%% for loop to load data
for ii=1:length(params.castlist) % select range of casts for this section
    
    cast = params.castlist(ii);

    mssname = [cruise,sprintf('_mss_%03d_struct.mat',cast)]; % string formatting to pad 1 digit cast numbers
    load ([mssdataP,mssname]);
  
    myPress = [mss.data.press];
    myT     = [mss.data.temp];
    myS     = [mss.data.sal];
    myEPS   = [mss.data.epsilon];

    %% Retrieving absolute salinity and conservative temperature for location of cast
    
    % Calculate midpoint lat-lon value for each cast
    % Indexing mssLogLat using position of cast from mssLogMSScast
    lat = msslogLat(find(mssLogMSScast == cast)); 
    lon = msslogLon(find(mssLogMSScast == cast)); 

    %% Populating array the same size as other cast variables with midpoint lat-lon
    rows = length(mss.data.press); % Adjusts the size of the lat/lon array to agree with other variables
    lat_arr = zeros(rows,1);
    lat_arr(:,:) = lat;
    lon_arr = zeros(rows,1);
    lon_arr(:,:) = lon;

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
