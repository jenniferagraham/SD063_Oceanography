% Updates file SD063_ctd_CastEventList.mat with all casts
% Created by Ellie Fisher 15.8.2026

addpath 'L:'\work\scientific_work_areas\oceanography\CTD\BASproc\; % Path to BASproc (location of cast event list file)
disk = 'L:\\work\scientific_work_areas\oceanography\';
ctds = readtable(fullfile(disk,'CTD_Deployments_Latest.csv')); % Loads most recent eventlog
eventsave=fullfile(disk,'CTD\BASproc\SD063_ctd_CastEventList.mat');

%% Index with only inWater entries (one per cast)
indxRow = find(ctds.EventAction_BuiltIn_String_=="inWater"); % inWater rows only
% create work table
casts = ctds.CTDCastNumber_BuiltIn_String_(indxRow,:);
events = ctds.EventNumber_BuiltIn_String_(indxRow,:);

%% Create cast event list
CastEvent=[casts,events];  %start a matched list of cast and event number

save (eventsave, 'CastEvent') % save to mat file