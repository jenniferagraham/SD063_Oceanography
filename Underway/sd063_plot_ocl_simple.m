% Script to plot underway data 
% Written 9.8.2026 by Ellie Fisher
% SD063 GIANT cruise

close all; clear all;

%%

if ispc
    addpath 'L:\\work\scientific_work_areas\oceanography\CTD\plot_transects/'; % path to section params file
    addpath 'L:\\work\scientific_work_areas\oceanography\matlabF\m_map\'; % path to m_map
    disk = ['L:\\work\scientific_work_areas\oceanography\'];
    ctdDataP = [disk,'CTD\BASproc\SD063_ctd.mat'];
    figpath=[disk,'Underway\Figures\'];
else
    addpath 'Volumes/legwork/scientific_work_areas/oceanography/CTD/plot_transects/'; % path to section params file
    addpath 'Volumes/legwork/scientific_work_areas/oceanography/matlabF/m_map'; % path to m_map
    disk = ['Volumes/legwork/scientific_work_areas/oceanography/'];
    ctdDataP = [disk,'CTD/BASproc/SD063_ctd.mat'];
    figpath=[disk,'Underway/Figures/'];
end

%% Load CTD data

load(ctdDataP);

%% Load underway data

oclpath = fullfile(disk,'Underway\merged_data\ocl_merged.csv');
ocl = readtable(oclpath,"NumHeaderLines",38,"Delimiter",",");
ocl = renamevars(ocl,{'latitude_decimalDegrees_',...
                     'longitude_decimalDegrees_',...
                     'relative_wind_speed_knots_',...
                     'sea_surface_temperature_degC_',...
                     'air_temperature_degC_',...
                     'PAR_umol_m2_s_',...
                     'salinity_psu_'},...
                     {'lat','lon','windSpeed','seaTemp','airTemp','par','salinity'});

%ucsw = readtable(fullfile(disk,'Underway\merged_data\UCSW_flowrate.csv'),"NumHeaderLines",11,"Delimiter",",");
%ucsw = readtable(fullfile(disk,'Underway\merged_data\UCSW_hoist_position.csv'),"NumHeaderLines",18,"Delimiter",",");
% Read UCSW 5 min data
ucsw_5min = readtable(fullfile(disk,'Underway\merged_data\UCSW_hoist_position_5min.csv'),'NumHeaderLines',18,'Delimiter',',');

%% Read times into datetime format
times = regexprep(ocl.time(:), '\+[0-9]{2}:[0.9]{2}$',''); % Remove trailing UTC timezone +00:00
ocl.convertedTime(:) = datetime(times);

%times = regexprep(ucsw.time(:), '\+[0-9]{2}:[0.9]{2}$',''); % Remove trailing UTC timezone +00:00
%ucsw.convertedTime(:) = datetime(times);
% Round convertedTime to the nearest minute (midpoint time won't match ocl)
%ucsw.convertedTime(:) = dateshift(ucsw.convertedTime,'start','minute','current');

times = regexprep(ucsw_5min.time(:), '\+[0-9]{2}:[0.9]{2}$',''); % Remove trailing UTC timezone +00:00
ucsw_5min.convertedTime(:) = datetime(times);
% Round convertedTime to the nearest minute (midpoint time won't match ocl)
ucsw_5min.convertedTime(:) = dateshift(ucsw_5min.convertedTime,'start','minute','current'); % current minute

%% Merge 1-min ucsw with 5-min ocl table (downsamples ucsw to match)
%for i=1:height(ocl)
%    dt = ocl.convertedTime(i);
%    if isempty(find(ucsw.convertedTime==dt))==false % if matching timestamp is found in UCSW
%        ocl.salinity(i)=mean(ucsw.salinity_psu_(find(ucsw.convertedTime==dt))); % mean needed as rounding causes some duplicate timestamps
%        h = ucsw.hoist_position(find(ucsw.convertedTime==dt));
%        ocl.hoist_position(i)=string(h{1}); % take first value (needed if duplicates exist)
%    else % set values to NaN
%        %ocl.salinity(i)=NaN;
%        %ocl.hoist_position(i)=NaN;
%    end
%end

%% Merge ucsw with ocl
%oclMaster = join(ocl(ocl.convertedTime>="19-Jul-2026 00:02:29",:),... 
%                  ucsw_5min(ucsw_5min.convertedTime<="15-Aug-2026 17:50:30",:),... % both should have height 7990
%                 'Keys','convertedTime',...
%                 'LeftVariables',{'lat','lon','airTemp','seaTemp','salinity','par','windSpeed','atmospheric_pressure_hPa_'},...
%                 'RightVariables',{'flowrate_mL_min_','hoist_position'});

%% Just trim ucsw to match ocl - then both indexes will be identical
ocl = ocl(ocl.convertedTime>="19-Jul-2026 00:02:29",:);
ucsw_5min = ucsw_5min(ucsw_5min.convertedTime<="15-Aug-2026 17:50:30",:);

%% Mask ocl time series when UCSW flowrate < 0.9L/min
flowMask = find(ucsw_5min.flowrate_mL_min_ < 900); % flow rate is in mL

% Mask ocl time series with salinity threshold >15 to ensure seawater is in the system
salMask = find(ocl.salinity < 15);

% Mask ocl time series with hoist position (options UP, DEPLOYED, FLUSH)
% Mask data when hoist position is up (keep if deployed/flush, buffer of 2mins after last "up" position)
hoistMask = find(ucsw_5min.hoist_position == "UP"); % for more conservative add | ucsw_5min.hoist_position == "FLUSH");
% hoist data doesn't start at same time as ocl, so search on datetime for buffer?

%% Replace masked datapoints with NaNs

MaskedVariables = {'seaTemp','salinity'};
oclMasked = ocl;

for v = 1:length(MaskedVariables) % set NaNs in only these variables
    var = MaskedVariables{v};
    oclMasked{flowMask,var} = nan; % flow rate masking
    oclMasked{salMask,var} = nan; % salinity masking
    oclMasked{hoistMask,var} = nan; % hoist position masking
end

%% Comparison plot - masked sea temp vs. masked flow rate
figure
%yaxis left
plot(ocl_ucsw_on.convertedTime,ocl_ucsw_on.seaTemp,"k")
ylabel("Sea temperature [degC]")
%hold on
% Secondary axis
%yaxis right
figure
plot(ucsw_only_on.convertedTime, ucsw_only_on.flowrate_mL_min_)
ylabel("Flow rate [ml/min]")

%% Comparison plot - air temp vs. flow rate
figure
%yaxis left
plot(ocl.convertedTime,ocl.seaTemp) %ocl_ucsw_on.convertedTime,ocl_ucsw_on.airTemp
ylabel("Air temperature [degC]")
%hold on
% Secondary axis
%yaxis right
figure
plot(ucsw.convertedTime(1:length(ocl.convertedTime)),ucsw.flowrate_mL_min_(1:length(ocl.convertedTime)))
ylabel("Flow rate [ml/min]")

%% Correlation plot - flow rate vs sea surface temperature
scatter(ucsw.flowrate_mL_min_(1:length(ocl.airTemp)),ocl.airTemp,"filled");
ylabel("Air temperature (degC)")
xlabel("Flow rate (ml/min)")

%% Outlier filtering
% Median absolute deviation -> Hampel filter?
hSeaTemp = hampel(ocl.seaTemp,2);
hFlowRate = hampel(ucsw.flowrate_mL_min_);

%% Time series of all variables
figure

subplot(2,2,1) % temperature
plot(ocl.convertedTime, ocl.seaTemp,"b")
hold on
plot(ocl.convertedTime, ocl.airTemp,"r")
ylim([-5 25])
ylabel("Temperature (deg C)")
xlabel("Time")
legend({"Sea temp","Air temp"})

subplot(2,2,2) % wind speed
plot(ocl.convertedTime,ocl.windSpeed,"k")
ylim([0 25])
ylabel("Wind speed (knots)")
xlabel("Time")

subplot(2,2,3) % salinity
plot(ocl.convertedTime,ocl.salinity,"c")
ylim([20 inf]) % Limiting to a sensible min of salinity
ylabel("Salinity (psu)")
xlabel("Time")

subplot(2,2,4) % PAR
plot(ocl.convertedTime,ocl.par,"g")
ylim([0 1500])
ylabel("PAR (umol m-2 s-1)")
xlabel("Time")

%% Shade masked data instead of removing it
%figure
%plot(ocl.convertedTime,ocl.airTemp,'r')
%plot(ocl.convertedTime,ocl.seaTemp,'b')

%% Cruise track map
% Specify color maps
%c=colorbar;
%cmap=colormap('jet');
%clim([min(ocl.salinity) max(ocl.salinity)])

%% normalize the z values to the color scale
%z_scaled=(ocl.salinity-min(ocl.salinity))./(max(ocl.salinity)-min(ocl.salinity));
%z_scaled(z_scaled<0)=0;z_scaled(z_scaled>1)=1;
%z_scaled=round(1+z_scaled*(size(cmap,1)-1));%round to nearest index

%% Modified jet-colormap
%cd = [uint8(jet())];
%z = zeros(size(ocl.lon));
%col = ocl.salinity;

%% Plot cruise track (m_map version)

%figure
%m_proj('mercator','lon',[min(ocl.lon) max(ocl.lon)],...
%                        'lat',[min(ocl.lat) max(ocl.lat)]);
%[x,y]=m_ll2xy(ocl.lon,ocl.lat,'clip','off');
%m_plot(ocl.lon, ocl.lat, 'LineWidth', 2) % 'Color', cmap(z_scaled)
%hold on
%m_grid;
%m_coast('patch', [0.8 0.8 0.8]);
%m_usercoast(coast)

%% Read Greenland coastline
% Coastline is in EPSG:3413 (projected CRS)
%gCoast = readgeotable('L:\work\scientific_work_areas\gis\Greenland_coastlines_2017\bas_greenland_coastlines.gpkg');

%Defining CRS
%proj = projcrs(32625); UTM 25N projected CRS
%oldGeo = geocrs(4326); % ocl lat and lon are in EPSG:4326 (geographic CRS)
%newGeo = projcrs(3413); % Coastline is in EPSG:3413 (projected CRS)

% Unprojecting lat-lon to x-y (projfwd)
%[x,y]=m_ll2xy(ocl.lon,ocl.lat,'clip','off'); % m_map method
%[x,y]=projfwd(newGeo,ocl.lon,ocl.lat); % base MATLAB method

% Reprojecting x-y to lat-lon in EPSG:3413 (projinv)
%[nLat,nLon] = projinv(newGeo,y,x);

%% Plot cruise track (base MATLAB version)
%figure;
%mapshow(gCoast,'FaceColor',[0.5 0.5 0.5]);
%xlim([4.8e+05 6.6e+05])
%ylim([-2.5e+06 -2.25e+06])

%% Plot track with variable colour line
% Trying to vary colour along cruise track according to salinity
%figure
%surface([ocl.lon,ocl.lon], [ocl.lat,ocl.lat], [z,z], [col,col],...
%    'facecol','no','edgecol','interp');
%cmap=colormap("winter");
%clim([min(ocl.salinity) max(ocl.salinity)])
%cb = colorbar();
%cb.Label.String = "Salinity (psu)";

%hold on

% Plot daily checkpoints
%scatter(wayPoints.lon, wayPoints.lat, 10, "k", "filled"); % Daily checkpoints
%text(wayPoints.lon, wayPoints.lat, char(wayPoints.convertedTime));

%% Create parameter object
sectionName= 'all3m';
params = sdaSectionParams(sectionName);
stns = params.sectionlist;

%% Index based on time window of stations 

allstations = [ctds.station];

for ii=1:length(stns)
    ind(ii)=find(allstations==stns(ii));
    window(ii)=datetime(ctds(ind(ii)).gtime);
end

%% Subset to section window
%window=window'; % Transpose to column vector
%sectionStartTime = window(1);
%sectionEndTime = window(end);

%windowData = ocl(find(ocl.convertedTime>=sectionStartTime & ocl.convertedTime<=sectionEndTime),:);

%% Named checkpoints (cruise "chapters")

names = ["Melange 1";"Melange 2";"Sorgenfri 1";"Sorgenfri 2";"Sorgenfri 3";"Kivioq"];
starts = datetime(["25-Jul-2026 18:00:00";"8-Aug-2026 08:00:00";"28-Jul-2026 14:00:00";...
        "11-Aug-2026 08:00:00";"13-Aug-2026 04:00:00";"12-Aug-2026 14:00:00"]);
ends = datetime(["27-Jul-2026 18:00:00";"10-Aug-2026 10:00:00";"7-Aug-2026 21:00:00";...
        "12-Aug-2026 07:00:00";inf;"12-Aug-2026 20:00:00"]);

chapters = table(names,starts,ends);

%% Underway subplots
% Plot sea temperature, air temperature for chapters

for c=1:height(chapters)
    figure

    startTime = chapters.starts(c);
    endTime = chapters.ends(c);
    windowData = oclMasked(oclMasked.convertedTime>startTime & oclMasked.convertedTime<endTime,:);
    
    subplot(2,2,1)
    plot(windowData.convertedTime, windowData.seaTemp,"b")
    hold on
    plot(windowData.convertedTime, windowData.airTemp,"r")
    ylim([-2 15])
    ylabel("Temperature (deg C)")
    xlabel("Time")
    legend({"Sea temp","Air temp"})
    
    % Plot wind speed for section
    subplot(2,2,2)
    plot(windowData.convertedTime,windowData.windSpeed,"k")
    ylim([0 15])
    ylabel("Wind speed (knots)")
    xlabel("Time")
    
    % Plot salinity for section
    subplot(2,2,3)
    plot(windowData.convertedTime,windowData.salinity,"c")
    ylim([20 inf]) % Limiting to a sensible min of salinity
    ylabel("Salinity (psu)")
    xlabel("Time")
    
    % Plot PAR
    subplot(2,2,4)
    plot(windowData.convertedTime,windowData.par,"g")
    ylim([0 1500])
    ylabel("PAR (umol m-2 s-1)")
    xlabel("Time")
    
    % Figure supertitle
    sgtitle("Underway " + chapters.names(c))

    % Save figure to folder
    exportgraphics(gcf,[fullfile(figpath,sprintf("ocl_sd063_%s_masked.png",chapters.names(c)))],'Resolution',300)
end

%% All data for 3-miippugut
threeM = chapters(3:5,:);

data1 = oclMasked(oclMasked.convertedTime>=threeM.starts(1)&oclMasked.convertedTime<=threeM.ends(1),:);
data2 = oclMasked(oclMasked.convertedTime>=threeM.starts(2)&oclMasked.convertedTime<=threeM.ends(2),:);
data3 = oclMasked(oclMasked.convertedTime>=threeM.starts(3)&oclMasked.convertedTime<=threeM.ends(3),:);

threeM_convertedTime=vertcat(data1.convertedTime,data2.convertedTime,data3.convertedTime);
threeM_airT=vertcat(data1.airTemp,data2.airTemp,data3.airTemp);
threeM_seaT=vertcat(data1.seaTemp,data2.seaTemp,data3.seaTemp);
threeM_windS=vertcat(data1.windSpeed,data2.windSpeed,data3.windSpeed);
threeM_sal=vertcat(data1.salinity,data2.salinity,data3.salinity);
threeM_par=vertcat(data1.par,data2.par,data3.par);

%%
figure

subplot(2,2,1)
plot(threeM_convertedTime, threeM_seaT,"b")
hold on
plot(threeM_convertedTime, threeM_airT,"r")
ylim([-2 15])
ylabel("Temperature (deg C)")
xlabel("Time")
legend({"Sea temp","Air temp"})

% Plot wind speed for section
subplot(2,2,2)
plot(threeM_convertedTime,threeM_windS,"k")
ylim([0 12])
ylabel("Wind speed (knots)")
xlabel("Time")

% Plot salinity for section
subplot(2,2,3)
plot(threeM_convertedTime,threeM_sal,"c")
ylim([25 inf]) % Limiting to a sensible min of salinity
ylabel("Salinity (psu)")
xlabel("Time")

% Plot PAR
subplot(2,2,4)
plot(threeM_convertedTime,threeM_par,"g")
ylim([0 1500])
ylabel("PAR (umol m-2 s-1)")
xlabel("Time")

%% All data for melange area

melange = chapters(1:2,:);

data1 = oclMasked(oclMasked.convertedTime>=melange.starts(1)&oclMasked.convertedTime<=melange.ends(1),:);
data2 = oclMasked(oclMasked.convertedTime>=melange.starts(2)&oclMasked.convertedTime<=melange.ends(2),:);

melange_convertedTime=vertcat(data1.convertedTime,data2.convertedTime);
melange_airT=vertcat(data1.airTemp,data2.airTemp);
melange_seaT=vertcat(data1.seaTemp,data2.seaTemp);
melange_windS=vertcat(data1.windSpeed,data2.windSpeed);
melange_sal=vertcat(data1.salinity,data2.salinity);
melange_par=vertcat(data1.par,data2.par);

%%
figure

subplot(2,2,1)
plot(melange_convertedTime, melange_seaT,"b")
hold on
plot(melange_convertedTime, melange_airT,"r")
ylim([-2 12])
ylabel("Temperature (deg C)")
xlabel("Time")
legend({"Sea temp","Air temp"})

% Plot wind speed for section
subplot(2,2,2)
plot(melange_convertedTime,melange_windS,"k")
ylim([0 15])
ylabel("Wind speed (knots)")
xlabel("Time")

% Plot salinity for section
subplot(2,2,3)
plot(melange_convertedTime,melange_sal,"c")
ylim([25 inf]) % Limiting to a sensible min of salinity
ylabel("Salinity (psu)")
xlabel("Time")

% Plot PAR
subplot(2,2,4)
plot(melange_convertedTime,melange_par,"g")
ylim([0 1500])
ylabel("PAR (umol m-2 s-1)")
xlabel("Time")