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
    disk = ['/Volumes/leg/work/scientific_work_areas/'];
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
t0 = datetime(msss(1).time,'ConvertFrom','datenum')- days(1.5); % start the time series a day earlier 
t1 = datetime(msss(end).time,'ConvertFrom','datenum')+ days(0.5); % end a day later
times = t0:minutes(1):t1;% minutes
%times = datetime(msss(1).time,'ConvertFrom', 'datenum'):hours(1):datetime(msss(end).time,'ConvertFrom', 'datenum'); % hourly 
% model for tidal height estimation using an average lat and lon in the fjord 
z = tmd_predict(fullfile(tidesP,'Gr1kmTM_v1.nc'),68.2796,-30.7665,times); 
% calcualte the change in height z with time to determine ebb and flood 
dtz = diff(z); 
times_dtz = times(1:end-1);
%%  test plot (see improved plot cast on tidal cylce )

%f=figure;
clf

%plot(times_dtz,dtz,'-r') % test for tidal hight change 
plot(times,z,'-r')
% plot the cast numbers on the tidal height 
hold on 
for s=1:length(stns)
    castname = string(msss(s).station);
    tcast = datetime(msss(s).time,'ConvertFrom','datenum');
     % plot on z 
    [~,ind] = min(abs(times - tcast)); % find the index to the closest minute
     plot(tcast,z(ind),'*k')
     text(tcast + hours(1.5), z(ind), castname)

    % or plot on the difference dz/dt
    % [~,ind] = min(abs(times_dtz - tcast)); % find the index to the closest minute
    % plot(tcast,dtz(ind),'*k')
    % text(tcast+ hours(1.5),dtz(ind),castname
end

%ylabel({'Predicted tidal height change'; 'dz/dt m per min'})
ylabel('Predicted tidal height m')

%%  Loop over each structure (cast) and add the values on the spreadsheet
for s=1:length(stns)
    % Compute tidal cycle using timepoints
    lat = msss(s).lat; % Use point-specified latitude
    lon = msss(s).lon; % Use point-specified longitude
    % Find the time of the measurement:
    t = datetime(msss(s).time, 'ConvertFrom', 'datenum');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%  base on times vector,  z is estimated hourly based on time %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interpolate the tide height at the t-1,t,t+1 (hourly timesteps)
    % zt = interp1(times, z, [t-(1/24),t,t+(1/24)], 'linear', 'extrap'); % extrapolating values at hour behind and hour ahead
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Raise error if there are fewer than 3 elements in zt?
    % if zt(end)-zt(1) >0 % if tidal height increasing (fwd diff positive)
    %     msss(s).tide='flood';
    % elseif zt(end)-zt(1) <0
    %     msss(s).tide='ebb'; % if tidal height decreasing (fwd diff negative)
    % % Raise error if diff is NaN?
    % end

    % when dtz is negative the it is flood tide, and when it is posstive is
    % is ebb tide 
     tcast = datetime(msss(s).time,'ConvertFrom','datenum'); 
     % plot on z 
    [~,ind] = min(abs(times - tcast)); % find the index to the closest minute on the prediction model 
    mytdz = round(dtz(ind),3);
    if mytdz>0 
        %flood
        msss(s).tide='flood';
    elseif mytdz<0 
        % ebb 
        msss(s).tide='ebb';
    elseif mytdz ==0 || z(ind) > 0
        % high tide 
        msss(s).tide='high';
    elseif mytdz ==0 || z(ind) < 0
        % low tide 
        msss(s).tide='low';
    end
    % Set tidal amplitude for this timepoint
    msss(s).tidalheight = z(ind);
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
for s = 1:length(msss)
    mssLogFixed.Time(s) = datetime(msss(s).time,'ConvertFrom','datenum');
end
%% Export to new CSV
%writetable(mssLogFixed,fullfile(savepath,savename))