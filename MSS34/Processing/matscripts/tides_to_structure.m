% Identity the tidal phase and amplitude and add this to the mss structure
% files. 

% Define paths
close all; clear all;


if ispc % ellie you should be able to run it using mac=0 you may need to adjust some of the paths
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
    disk = ['L:\work\scientific_work_areas\']; %
    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    mssdataP = [disk,'oceanography\MSS34\DATA\'];
    tidesP = ('L:\work\scientific_work_areas\oceanography\Gr1kmTM\data\'); % path to tide model on leg drive
    addpath 'L:\work\scientific_work_areas\oceanography\TMD3.0' % path to tmd_predict function on leg drive
    savepath='L:\work\scientific_work_areas\oceanography\MSS34\';
elseif ismac
    slash='/';
    disk = ['/Volumes/legwork/scientific_work_areas/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    mssdataP = [disk,'oceanography/MSS34/DATA/'];
    tidesP = ([disk,'/oceanography/Gr1kmTM/data/']);
    addpath ([disk,'/oceanography/TMD3.0'])
    savepath=([disk,'/oceanography/MSS34/']);
end

cruise='SD063';
savename='MSS_logbook_4matlab_tidesadded.csv';

%% Read master structure
load (fullfile(mssdataP,"sd063_mss.mat")) % 

% Station list (as a horizontal array)
stns = extractfield(msss,"station");

%% Construct a date array for all MSS casts
times = datetime(msss(1).time,'ConvertFrom', 'datenum'):hours(1):datetime(msss(end).time,'ConvertFrom', 'datenum');
 
% Loop over each structure (cast)
for s=1:length(stns)
    % Compute tidal cycle using timepoints
    lat = msss(s).lat; % Use point-specified latitude
    lon = msss(s).lon; % Use point-specified longitude
    % Predict the entire tide time series for this location:
    z = tmd_predict(fullfile(tidesP,'Gr1kmTM_v1.nc'),68.2796,-30.7665,times);
    % Find the time of the measurement:
    t = datetime(msss(s).time, 'ConvertFrom', 'datenum');
    % Interpolate the tide height at the t-1,t,t+1 (hourly timesteps)
    zt = interp1(times, z, [t-(1/24),t,t+(1/24)], 'linear', 'extrap'); % extrapolating values at hour behind and hour ahead
    % Raise error if there are fewer than 3 elements in zt?
    if zt(end)-zt(1) >0 % if tidal height increasing (fwd diff positive)
        msss(s).tide='flood';
    elseif zt(end)-zt(1) <0
        msss(s).tide='ebb'; % if tidal height decreasing (fwd diff negative)
    % Raise error if diff is NaN?
    end
    % Set tidal amplitude for this timepoint
    msss(s).tidalheight = zt(1);
end

%% save mat structure with tides added
%save(fullfile(mssdataP,'sd063_mss_tidesadded.mat'),'msss')

%% load mss eventlog
mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
%VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
indxRow = find(mssLog.Use==1); % inWater rows only

% Add column for tide and tidalheight from structure
tide = extractfield(msss,'tide')';
tidalheight = extractfield(msss,'tidalheight')';
mssLogFixed = mssLog(indxRow,:);
mssLogFixed.tide = tide;
mssLogFixed.tidalheight = tidalheight;

%% Export to new CSV
%writetable(mssLogFixed,fullfile(savepath,savename))