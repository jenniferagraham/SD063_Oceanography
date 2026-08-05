%Script to plot MSS sections
%
%Created 3.8.2026 by Laura C
% uses functions sdaSectionParamsMSS, lldistkm,
close all;
clear all; clc
FZ=12;
set(0, 'DefaultAxesFontSize', FZ);
%% define paths
mac = 0; % laura uses mac,
cruise='SD063';

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
    mssdataP = [disk,'oceanography/MSS34/DATA\'];
    figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    gridpath= [disk,'gis/bathymetry_grids/'];
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    % addpath([disk,'oceanography/CTD/plot_transects/']) % create a similar one for MSS
end

%% load mss eventlog
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ["Time", "Latitude_dd", "Longitude_dd", "DepthEA640_m", "MSSstation", "EventNumber", "MSScast", "TargetDepth_m", "Comment", "Use"];
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
%% load bathymetery 
% extract the maximum depth at the section to plot as a line on each panel 


%% Temporary 
% to add map 
% add TS plot with all station in the section in one color and the rest of
% the data collected on a different color. 
f=figure;
figPOS = [63 126 436 560];
set(f,'Position',figPOS)


subplot(3,1,1)
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


subplot(3,1,2)
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

%
subplot(3,1,3)
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
% add density countour
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')

exportgraphics(gcf,[figpath,cruise,'_MSS_',sectionName,'.png'],'Resolution',300)


