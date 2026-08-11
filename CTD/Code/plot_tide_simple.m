% simple tide phase calculation
close all
clear all

disk = ['L:\work\scientific_work_areas\oceanography\'];
Tdisk = ['P:\SD063\']; % JG T-drive
%Tdisk = ['T:\SD063\'];

% location of interest? 
location = 'fjordall'; % kg or melange
timenow = false;
savecsv = true;

switch location
    case 'all'
        lat = [68.2796, 68.1085, 67.91221, 67.70328];
        lon = [-30.7665, -30.42815, -31.72869, -32.8002];
        tstart = '22-Jul-2026';
        tend = '22-Aug-2026';

    case 'fjordall'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '22-Jul-2026';
        tend = '22-Aug-2026';

    case 'fjord1'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '29-Jul-2026';
        tend = '8-Aug-2026';

    case 'fjord2'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '10-Aug-2026';
        tend = '19-Aug-2026';

    case 'kg1'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '28-Jul-2026';
        tend = '30-Jul-2026';

    case 'kg2'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '7-Aug-2026';
        tend = '10-Aug-2026';

    case 'melange1'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '15-Jul-2026';
        tend = '15-Jul-2026';

    case 'melange2'
        lat = 68.2796;
        lon = -30.7665;
        tstart = '15-Jul-2026';
        tend = '15-Jul-2026';

end

%plot tidal cycle:
addpath(fullfile(Tdisk,'TMD3.0')) 

%if timenow
%    tstart = 

figure
t = datetime(tstart):hours(5/60):datetime(tend);
if strcmp(location, 'all')
    for ii=1:length(lon)
        z = tmd_predict(fullfile(Tdisk,'Gr1kmTM/data/Gr1kmTM_v1.nc'),...
            lat(ii),lon(ii),t);
        plot(t, z);
        hold on
    end
    legend('Fjord head', 'Fjord mouth', 'KG mouth', 'Melange')
else
    z = tmd_predict(fullfile(Tdisk,'Gr1kmTM/data/Gr1kmTM_v1.nc'),lat,lon,t);
    plot(t, z);
end
ylabel('tide height (m)')

ax = gca;
ax.XTick = t(1):hours(24):t(end);
ax.XMinorTick = 'on';
ax.XAxis.TickLabelFormat = 'dd-MMM HH:mm';
grid on

figname = sprintf('Tide_%s.png', location);
exportgraphics(gcf,fullfile('..', figname),'Resolution',300)

if savecsv
    csvname = sprintf('Tide_%s.csv', location);
    dzdt = gradient(z,hours(t(2)-t(1)));
    T = table(t(:), z(:), dzdt(:), 'VariableNames', {'Time','Z', 'dZdt'});
    writetable(T, fullfile('..', csvname));
end

%% Classify ebb and flood? 
s = sign(T.dZdt);

highIdx = find(diff(s) < 0) + 1;   % +ve to -ve
lowIdx  = find(diff(s) > 0) + 1;   % -ve to +ve

T.phase = repmat("flood",height(T),1);
T.phase(T.dZdt < 0) = "ebb";

% Set as high/low for +/- 20 min (4 x dt) around max/min 
for ii=1:length(highIdx)
    imax = highIdx(ii);
    T.phase(imax-4:imax+4) = "high";
end
for ii=1:length(lowIdx)
    imax = lowIdx(ii);
    T.phase(imax-4:imax+4) = "low";
end

%%
if savecsv
    csvname = sprintf('Tide_phase_%s.csv', location);
    writetable(T, fullfile('..', csvname));
end

%% Plot phase for today

figure;
scatter(T.Time(T.phase=='flood'),T.Z(T.phase=='flood'), 'r')
hold on
scatter(T.Time(T.phase=='ebb'),T.Z(T.phase=='ebb'), 'b')
scatter(T.Time(T.phase=='high'),T.Z(T.phase=='high'), 'k', 'filled')
scatter(T.Time(T.phase=='low'),T.Z(T.phase=='low'), 'y', 'filled')

xlim([datetime('today') datetime('tomorrow')])
grid on

ylabel('tide height (m)')

figname = sprintf('Tide_phase_%s_today.png', location);
exportgraphics(gcf,fullfile('..', figname),'Resolution',300)
