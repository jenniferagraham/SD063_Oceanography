close all
clear all

if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
else
    disk = ['/Volumes/leg/work/scientific_work_areas/oceanography/'];
end

tidefile = fullfile(disk, 'CTD', 'Tide_phase_fjordall.csv');
eventfile = fullfile(disk, 'CTD_deployments_latest.csv');
outfile = fullfile(disk, 'CTD_deployments_latest_phase.csv');
atDfile = fullfile(disk, 'CTD_deployments_latest_phase_atD.csv');

reportout = fullfile(disk, 'CTD_deployments_report.csv');

% Read data
tides = readtable(tidefile);
events = readtable(eventfile);

%%
% Convert times
tides.Time = datetime(tides.Time);
%events.Time = datetime(events.Time);
events.Time = datetime(events.Time,...
    'InputFormat','HH:mm:ss dd/MM/yyyy');

%% Use timetables? 
tidesTT = table2timetable(tides,'RowTimes','Time');
eventsTT = table2timetable(events,'RowTimes','Time');

phaseAtEvents = retime(tidesTT(:, 'phase'), eventsTT.Time, 'previous');

eventsTT.phase = phaseAtEvents.phase;

%% Just at depth? 
inEvents = eventsTT(strcmp(eventsTT.EventAction_BuiltIn_String_,'atDepth'),:);

inEvents.Properties.VariableNames{'Latitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Latitude_'} = 'Latitude';
inEvents.Properties.VariableNames{'Longitude_dd__sd_gnss_kongsberg_seapath_320_port1_ingga_Longitude_'} = 'Longitude';
inEvents.Properties.VariableNames{'PrimaryPurpose_BuiltIn_String_'} = 'Purpose';
inEvents.Properties.VariableNames{'CTDCastNumber_BuiltIn_String_'} = 'CastNumber';
inEvents.Properties.VariableNames{'EventNumber_BuiltIn_String_'} = 'EventNumber';

%% Sort by region? 

inEvents.Region = strings(height(inEvents),1);

for ii=1:height(inEvents)
    event = inEvents(ii,:);
    % inshore of sill
    if event.Longitude < -30.755 &&  event.Latitude > 68.26
        if event.CastNumber >= 37 && event.CastNumber < 43
            inEvents.Region(ii) = '3-M Inner';
        else
            inEvents.Region(ii) = '3-M Ice Front';
        end

    elseif event.Longitude < -30.66 &&  event.Latitude > 68.2
        inEvents.Region(ii) = '3-M Inner';

    % sill
    elseif event.Longitude > -30.66 && event.Longitude < -30.53 ...
            &&  event.Latitude > 68.16 
        inEvents.Region(ii) = '3-M Sill';

    % offshore of sill
    elseif event.Longitude > -30.607 &&  event.Latitude > 68.106 ...
            event.Latitude < 68.3
        inEvents.Region(ii) = '3-M Outer';

    % 3M Shelf
    elseif event.Longitude > -30.6 &&  event.Longitude < -30. 
        inEvents.Region(ii) = '3-M Shelf';

    % KG Trough 
    elseif (event.Longitude > -31.85 && event.Longitude < -31)  ...
        && event.Latitude > 67.79
        % event.CastNumber == 153, 155, 3, 4 ? 
        inEvents.Region(ii) = 'Kangerlussuaq Trough';

    % Melange 
    elseif event.Longitude > -33.4 && event.Longitude < -31.6
        inEvents.Region(ii) = 'Melange';

    else
        inEvents.Region(ii) = 'Other';
    end
end

%%
inEvents.Sampling = strings(height(inEvents),1);
for ii=1:height(inEvents)
    if strcmp(inEvents.Purpose(ii), 'CTD') 
        inEvents.Sampling(ii) = 'N';
    else
        inEvents.Sampling(ii) = 'Y';
    end
end
%%
writetimetable(inEvents,reportout);

% NB. Output will contain more columns than needed. Will need to subset,
% e.g.
% Columns wanted: CTD cast | Event | Latitude | Longitude | Depth | Region | Sampled (Y/N) 

