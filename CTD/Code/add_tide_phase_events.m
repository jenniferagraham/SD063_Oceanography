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

writetimetable(eventsTT,outfile);

%% Just at depth? 
inEvents = eventsTT(strcmp(eventsTT.EventAction_BuiltIn_String_,'atDepth'),:);

writetimetable(inEvents,atDfile);
