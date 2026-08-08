close all; clear all;
redo=1; % re do the structures 
%% defien paths 
if ispc
    disk = 'L:\work\scientific_work_areas\';
    MSSDataP = 'L:\work\scientific_work_areas\oceanography\MSS34\DATA\fasteps\';
    MSSDataSave = 'L:\work\scientific_work_areas\oceanography\MSS34\DATA\';
    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16/library\'])
elseif ismac
    disk = '/Volumes/leg/work/scientific_work_areas/';
    MSSDataP = ['/Volumes/leg/work/scientific_work_areas/oceanography/MSS34/DATA/fasteps/'];
    MSSDataSave = ['/Volumes/leg/work/scientific_work_areas/oceanography/MSS34/DATA/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; 
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
end
%% load log book to add lat and lon to structure variable
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ["Time", "Latitude_dd", "Longitude_dd", "DepthEA640_m", "MSSstation", "EventNumber", "MSScast", "TargetDepth_m", "Comment", "Use"];
indxRow = find(mssLog.Use==1); % inWater rows only
% create work table
msslogDepth = mssLog.DepthEA640_m(indxRow);
msslogLon = mssLog.Longitude_dd(indxRow);
msslogLat = mssLog.Latitude_dd(indxRow);
mssLogMSScast = mssLog.MSScast(indxRow);
%%
files = dir(fullfile(MSSDataP,'*eps.mat'));

if isempty(files)
    error('No MSS files found.');
end

% Extract cast numbers from filenames
cast_numbers = zeros(length(files),1);

for i = 1:length(files)
    % Filename example: SD630002_eps.mat
    % search for number in filename % export to tokens outkey
    tokens = regexp(files(i).name,'SD6300(\d+)_','tokens');
    cast_numbers(i) = str2double(tokens{1}{1});
end

% Largest cast number
max_cast = max(cast_numbers);

fprintf('Found casts 1 to %d\n', max_cast);
%%

% Loop through casts
for cast = 1:max_cast

    % Find file for this cast
    idx = find(cast_numbers == cast);

    if isempty(idx)
        fprintf('Cast %d missing - skipping\n', cast);
        continue
    elseif length(idx) > 1
        warning('Multiple files found for cast %d - using first one', cast);
        idx = idx(1);
    end

    infile = files(idx).name;
    outfile = sprintf('SD063_mss_%03d_struct.mat', cast);

     if exist(outfile,'file') && redo==0
         display(outfile, 'already exist => skipping');
     else

        display(['Processing %s\n', infile]);

        % Load original file
        S = load(fullfile(MSSDataP,infile));

        S.station =cast; % add the cast number
        % Put all variables into mss structure
        mss = S;
        mss.data.corrsal = mss.data.sal - 0.080274;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % adding the lat-lon value for each cast
        castidx = find(mssLogMSScast==cast);
        mss.lat = msslogLat(castidx); % using inwater - probe would have gone straight down
        mss.lon = msslogLon(castidx); % using inwater
        mss.depth = msslogDepth;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % add absolute salinity and conservative temperature

        mss.data.asal =gsw_SA_from_SP(mss.data.corrsal,mss.data.press,mss.lat,mss.lon);
        mss.data.ct  =gsw_CT_from_t(mss.data.corrsal,mss.data.temp,mss.data.press);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Save new structure file
        save(fullfile(MSSDataSave,outfile),'mss');
    end
end

fprintf('Finished.\n');
