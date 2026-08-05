% Format section TS plot, section T, S, eps plots and map in grid layout
% Created 4.8.2026 by Ellie Fisher

close all; clear all;

mac=0;

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
    ctddata = [disk,'/oceanography/CTD/BASproc/'];
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

gridpath= 'L:\work\scientific_work_areas\gis\bathymetry_grids\';

FZ=12;
set(0, 'DefaultAxesFontSize', FZ);

%% Create parameter object 
% Use sdaSectionParamsMSS?
mssparams = sdaSectionParamsMSS('3minner');
nMSS = 1:length(mssparams.castlist); % array with station IDs

%% load mss eventlog
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
indxRow = find(mssLog.Use==1); % inWater rows only
% create work table
msslogLon = mssLog.Longitude_dd(indxRow);
msslogLat = mssLog.Latitude_dd(indxRow);
mssLogMSScast = mssLog.MSScast(indxRow);
%% Create parameter object
% ready choices
% sectionName= '3msill_towyo'; % works well
sectionName= '3minner_towyo'; % works well
%sectionName= '3mtransectmss';
P = sdaSectionParamsMSS(sectionName);
% '3minner_towyo', 1 cast per station
% '3minner' , three casts per station
% 'all3m'  all casts - probably good for TS plot but not so much as a section plot
% '3mtransectinner' only in the inner part of the fjord (three casts per station)
% '3mtransectfront-sill' only in the inner part of the fjord (three casts per station)

%% create a nan structure
nCast         = length(P.castlist);
section.press = nan(1000,nCast);
section.T     = nan(1000,nCast);
section.S     = nan(1000,nCast);
section.km    = nan(1000,nCast);
section.lat   = nan(1000,nCast);
section.lon   = nan(1000,nCast);
section.eps   = nan(1000,nCast);
section.sigt  = nan(1000,nCast);
%% loop and put data onto section structure
nstn  = P.stationlist;

repeated = unique(nstn);
if length(repeated)==length(nstn) % this is one cast per station
    for ii=1:length(P.castlist) % select range of casts for this section
        % load this cast data
        cast = P.castlist(ii);
        mssname= [cruise,sprintf('_mss_%03d_struct.mat',cast)];
        load ([mssdataP,mssname]); % loads data, sensors

        tmpPress = [mss.data.press];
        % cut the profiles at 5m
        minD=5;
        minDidx = find([tmpPress-minD] == min(abs(tmpPress-minD)));
        clear tmpPress
        % keep the cast data for the desire depth range
        castPress = [mss.data.press(minDidx:end)];
        castT     = [mss.data.temp(minDidx:end)];
        castS     = [mss.data.sal(minDidx:end)];
        castEPS   = [mss.data.epsilon(minDidx:end)];   % in fasteps I do not think it is so good.
        castsigt  = [mss.data.sig_t(minDidx:end)];
        % add the lat-lon value for each cast
        castidx = find(mssLogMSScast==cast);
        castlat = msslogLat(castidx); % using inwater -probe would have gone straight down
        castlon = msslogLon(castidx); % using inwater
        % add absolute salinity and conservative temperature
        castasal=gsw_SA_from_SP(castS,castPress,castlat,castlon);
        castct=gsw_CT_from_t(castasal,castT,castPress);
        % calculate distance from the first station (left to right)
        if ii==1
            lat1 = castlat;
            lon1 = castlon;
        end
        % distance

        [d1km, d2km] = lldistkm([lat1 lon1],[castlat castlon]); % distance from the
        castdistll = d1km; %distance in km related to the first station

        % put cast data onto a section type matrix
        %rownumber(ii) = size(castEPS,1); % run once to determine the maximum
        rownumber= size(castEPS,1);
        % number of rows in the matrix\
        section.press(minD:rownumber+minD-1,ii)   = castPress;
        section.T(minD:rownumber+minD-1,ii)       = castT;
        section.S(minD:rownumber+minD-1,ii)       = castS;
        section.eps(minD:rownumber+minD-1,ii)  = castEPS;
        section.km(minD:rownumber+minD-1,ii)   = castdistll;
        section.lat(minD:rownumber+minD-1,ii)  = castlat;
        section.lon(minD:rownumber+minD-1,ii)  = castlon;
        section.sigt(minD:rownumber+minD-1,ii)  = castsigt;

    end
else % must averaged all the casts at those stations
    % working here must average cast with the same station number 
    for ii=1:length(repeated)
       idx = find(P.castlist==repeated(ii));
       castlist = P.castlist(idx);
       for ri=1:length(castlist)
          load ([mssdataP,mssname]); % loads data, sensors

        tmpPress = [mss.data.press];
        % cut the profiles at 5m
        minD=5;
        minDidx = find([tmpPress-minD] == min(abs(tmpPress-minD)));
        clear tmpPress
        % keep the cast data for the desire depth range
        castPress = [mss.data.press(minDidx:end)];
        castT     = [mss.data.temp(minDidx:end)];
        castS     = [mss.data.sal(minDidx:end)];
        castEPS   = [mss.data.epsilon(minDidx:end)];   % in fasteps I do not think it is so good.
        castsigt  = [mss.data.sig_t(minDidx:end)];
        % add the lat-lon value for each cast
        castidx = find(mssLogMSScast==cast);
        castlat = msslogLat(castidx); % using inwater -probe would have gone straight down
        castlon = msslogLon(castidx); % using inwater
        % add absolute salinity and conservative temperature
        castasal=gsw_SA_from_SP(castS,castPress,castlat,castlon);
        castct=gsw_CT_from_t(castasal,castT,castPress);
        % calculate distance from the first station (left to right)
        if ii==1
            lat1 = castlat;
            lon1 = castlon;
        end
        % distance

        [d1km, d2km] = lldistkm([lat1 lon1],[castlat castlon]); % distance from the
        castdistll = d1km; %distance in km related to the first station
       end
        % put cast data onto a section type matrix
        %rownumber(ii) = size(castEPS,1); % run once to determine the maximum
        rownumber= size(castEPS,1);
        % number of rows in the matrix\
        section.press(minD:rownumber+minD-1,ii)   = castPress;
        section.T(minD:rownumber+minD-1,ii)       = castT;
        section.S(minD:rownumber+minD-1,ii)       = castS;
        section.eps(minD:rownumber+minD-1,ii)  = castEPS;
        section.km(minD:rownumber+minD-1,ii)   = castdistll;
        section.lat(minD:rownumber+minD-1,ii)  = castlat;
        section.lon(minD:rownumber+minD-1,ii)  = castlon;
        section.sigt(minD:rownumber+minD-1,ii)  = castsigt;
    end

end

%% Load MSS data for TS plot

% preallocate size of arrays for each variable
maxdepth = mssparams.maxy*2; % deepest cast (which will have greatest length) - half step interval between values, so multiplied by two
temparray = zeros(maxdepth,length(nMSS))*NaN; % NaN array with no. columns equal to number of casts

myPress = temparray;
myT = temparray;
myS = temparray;
myEPS = temparray;
asal = temparray;
ct = temparray;

for ii=1:length(nMSS) % select range of casts for this section
    cast = mssparams.castlist(ii);

    mssname = [cruise,sprintf('_mss_%03d_struct.mat',cast)]; % string formatting to pad 1 digit cast numbers
    load ([disk,'oceanography\MSS34\DATA\',mssname]);

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

%% Load CTD data and retrieve ct, asal for TS plot

load([ctddata,cruise,'_ctd.mat']);

nCast = length(ctds);
for n=1:nCast
    ctds(n).asal=gsw_SA_from_SP(ctds(n).salin,ctds(n).press,ctds(n).lon,ctds(n).lat);
    ctds(n).ct=gsw_CT_from_t(ctds(n).asal,ctds(n).temp,ctds(n).press);
end
%sd_ctds=ctds;

% Retrieve only data for CTD casts in Sorgenfri inner - comparable location to MSS?
ctdparams = sdaSectionParams('3minner');

% Only works if ctds.station starts at 1 
% and increases monotonically with no repeats
ctds_inner = ctds(ctdparams.sectionlist); % within condition needed?

% T-S points for CTDs
for i = 1:length(ctds_inner) % Extract all casts, store in an array
    ctdS(:,i) = ctds_inner(i).asal(:);
    ctdT(:,i) = ctds_inner(i).ct(:);
end

%% load bathymetry 
% extract the maximum depth at the section to plot as a line on each panel 


%% Create map 

% Define grid layout
tiledlayout(3,2) % 3 rows, 2 columns

% Temp plot
% nexttile(1)
subplot(2,3,1)
title (['MSS ',P.sectionname])
pcolor(section.km,section.press,section.T)
shading flat
set(gca,'YDir','reverse')
h=colorbar; h.Label.String = 'Temperature (^\circC)';
xlabel('Distance (km)')
ylabel('Pressure (dbar)')

caxis([P.tcaxis(1),P.tcaxis(2)])
ylim ([0 P.maxy ])
hold on ;
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')

% Salinity plot
subplot(2,3,3)
%nexttile(3)
pcolor(section.km,section.press,section.S)
shading flat
set(gca,'YDir','reverse')
h=colorbar; h.Label.String = 'Salinity (PSU)';
caxis([P.scaxis(1),P.scaxis(2)])
xlabel('Distance (km)')
ylabel('Pressure (dbar)')
ylim ([0 P.maxy ])
hold on
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')

% Epsilon plot
subplot(2,3,6)
%nexttile(5)
pcolor(section.km,section.press,section.eps)
shading flat
hold on
plot([0 3],[10 10],'-k','linewidth',2);% what is usually removed due to deploying from a ship
set(gca,'YDir','reverse')
h=colorbar;
h.Label.String = 'log_{10}(\epsilon)';
xlabel('Distance (km)')
ylabel('Pressure (dbar)')
shading flat
ylim ([0 P.maxy])
caxis([P.epscaxis(1),P.epscaxis(2)])
% add density contour
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')

% TS plot with CTD background points
subplot(2,3,2)
%nexttile(2)
% Create grid for sigma0 contours
Tmin=mssparams.tcaxis(1);
Tmax=mssparams.tcaxis(2);
Smin=mssparams.scaxis(1);
Smax=mssparams.scaxis(2);
[Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
sigma0 = gsw_sigma0(Sg,Tg);

alpha = 0.5;

scatter(ctdS(:),ctdT(:),12,[0.5,0.5,0.5],...
    'filled',...
    'MarkerFaceAlpha',alpha,...
    'DisplayName','Inner fjord CTDs');

% MSS section values (plot on top)
mssS = asal;
mssT = ct;

scatter(mssS(:),mssT(:),12,'red',...
    'filled',...
    'MarkerFaceAlpha',alpha,...
    'DisplayName','MSS section');

grid on
box on

xlim([Smin, Smax])
ylim([Tmin, Tmax])

contour(Sg,Tg,sigma0,'k','ShowText','on', 'HandleVisibility','off')
% Suppress density contours from showing in legend

hold off

xlabel('Absolute salinity (‰)') % need to fix unicode
ylabel('Conservative temperature (°C)') % need to fix unicode
legend('show')

% Map with section points plotted
subplot(3,3,4:5)
%nexttile(4)

%exportgraphics(gcf,[figpath,cruise,'_MSS_',sectionName,'.png'],'Resolution',300)
