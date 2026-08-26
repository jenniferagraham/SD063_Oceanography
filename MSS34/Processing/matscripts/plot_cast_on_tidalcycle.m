% Plot MSS station on the predicted tidal height

% answers the question what is the timing of the sampling
close all; clear all;
FZ=12;
set(0, 'DefaultAxesFontSize', FZ);
includemap=0;
%% Define paths


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
     figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
 
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
%%  test

f=figure;f.Position=[290 270 881 420];
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
    plot(tcast,z(ind),'*k','LineWidth',2)

    % select what numebrs to plot because to avoid cluttering
    if msss(s).station >=31 && msss(s).station <= 43
        if mod(s,2) == 0 % only even numbers
            if mod(s/2,2) == 0 % every second even number is plotted to the right
                text(tcast + hours(1.5), z(ind), castname,'FontSize',FZ)
            else % the others are ploted left
                text(tcast - hours(5.5), z(ind), castname,'FontSize',FZ)
            end
        end
    elseif msss(s).station >=8 && msss(s).station <= 13 || msss(s).station == 20
        text(tcast - hours(5.5), z(ind), castname,'FontSize',FZ)
    elseif msss(s).station ==14 || msss(s).station ==21
        text(tcast + hours(1.5), z(ind)+0.03, castname,'FontSize',FZ)
    elseif msss(s).station == 16 || msss(s).station ==23 
       text(tcast + hours(1.5), z(ind)-0.02, castname,'FontSize',FZ)
   
    else
        text(tcast + hours(1.5), z(ind), castname,'FontSize',FZ)
    end
    % or plot on the difference dz/dt
    % [~,ind] = min(abs(times_dtz - tcast)); % find the index to the closest minute
    % plot(tcast,dtz(ind),'*k')
    % text(tcast+0.1,dtz(ind),castname
end

%ylabel({'Predicted tidal height change'; 'dz/dt m per min'})
ylabel('Predicted tidal height m')
box on 
grid on 

    exportgraphics(gcf,[figpath,cruise,'_MSS_caston_tidalcycle.png'],'Resolution',300)
