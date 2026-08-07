% simple tide phase calculation
close all
clear all

disk = ['L:\work\scientific_work_areas\oceanography\'];
Tdisk = ['P:\SD063\']; % JG T-drive
%Tdisk = ['T:\SD063\'];

% location of interest? 
location = 'all' % kg or melange
timenow = false;

switch location
    case 'all'
        lat = [68.2796, 68.1085, 67.91221, 67.70328];
        lon = [-30.7665, -30.42815, -31.72869, -32.8002];
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
t = datetime(tstart):hours(0.25):datetime(tend);
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

%% Classify ebb and flood? 
% 
% tevent = % list of stations & time...
% 
% tevent = datetime(event_dates, 'TimeZone', 'UTC');
% 
% % Ensure tide times have a timezone too
% t.TimeZone = 'UTC';
% 
% % Interpolate
% zevent = interp1(t, z, tevent);
% 
% % zevent now contains tide height at each event time
% 
% % To consider flood vs ebb?
% dzdt = gradient(z, hours(t(2)-t(1)));
% dzdtevent = interp1(t, dzdt, tevent);
% 
% state = strings(size(tevent));
% state(dzdtevent > 0) = "Flood";
% state(dzdtevent < 0) = "Ebb";
% 
