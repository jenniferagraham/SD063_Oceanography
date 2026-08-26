function make_ave_nav(startday, endday, yy, interval)
%MAKE_AVE_NAV Make 1-s and 30-s averaged underway data files
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version
%   version 1.1 - 20240813 - Povl Abrahamsen, SD041 - move plots into PLOT_AVE_NAV
%   version 1.2 - 20241213 - Povl Abrahamsen, post-SD033 - deal with datasets that
%       don't have any gaps in their GPS datastreams! And another minor bug fix.
%   version 1.3 - 20250309 - Kat Turner - add in little additions

% check to see if user wants different interval of time
if nargin < 4
    fprintf('This script creates averages at a 1s interval and a 30s interval.\n');
    interval = input(['If you wish for a separate length of interval insert here.\n' ...
    'Statement needs to be written in second, for example 1 minute will be input as 60 (leave blank fo no further interval): ']);
end

% check for start and end day
if nargin < 3
    yy = mod(year(datetime('now')), 100);
end 

if nargin < 2
    startday = input('Input start jday to begin the averaging (blank for first day): ');  
    endday = input('Input end jday to end averaging at (blank for last day): ');
end

set_underway_params

% loop through each of the sensors
for q=1:length(nav_sensor_sets)

    % load data
    gga=load(fullfile('..','nav',nav_sensor_sets(q).gga_table,...
        [nav_sensor_sets(q).gga_table,'_all.mat']));
    gga=gga.(nav_sensor_sets(q).gga_table);
    vtg=load(fullfile('..','nav',nav_sensor_sets(q).vtg_table,...
        [nav_sensor_sets(q).vtg_table,'_all.mat']));
    vtg=vtg.(nav_sensor_sets(q).vtg_table);
    hdt=load(fullfile('..','nav',nav_sensor_sets(q).hdt_table,...
        [nav_sensor_sets(q).hdt_table,'_all.mat']));
    hdt=hdt.(nav_sensor_sets(q).hdt_table);

    gga.longitude(gga.longitude<-990)=nan;
    gga.latitude(gga.latitude<-990)=nan;

    %%set up new structure
    jday_start = round(gga.time_jday(1));
    jday_end = round(gga.time_jday(end));
    if isempty(startday) startday = jday_start; end
    if isempty(endday) endday = jday_end; end

    if startday == jday_start && endday == jday_end
        filename = strcat(cruisename,'_nav',nav_sensor_sets(q).file_add);
        nav_ave_1s=struct('time',floor(gga.time(1)):(1/3600/24):...
            ceil(gga.time(end))-(1/3600/24));
    else
        filename = strcat(cruisename,'_nav',nav_sensor_sets(q).file_add, ...
            sprintf('_%d-%d',startday, endday));
        start_time = find(datetime(gga.time, 'ConvertFrom', 'datenum') >= datetime(2000+yy, 1, startday),1,'first');
        end_time = find(datetime(gga.time, 'ConvertFrom', 'datenum') <= datetime(2000+yy, 1, endday+1),1,'last');
        nav_ave_1s=struct('time',floor(gga.time(start_time)):(1/3600/24):...
            ceil(gga.time(end_time))-(1/3600/24));
    end

    

    %% map GGA data onto 1-s bins
    gga_interp=interp1(gga.time',[gga.time,...
        gga.(nav_sensor_sets(q).gga_lon_field),...
        gga.(nav_sensor_sets(q).gga_lat_field)],nav_ave_1s.time,'nearest');

    lat_temp=gga_interp(:,3);
    lon_temp=gga_interp(:,2);
    first_ind=find(~isnan(lat_temp),1);
    lat_temp(1:first_ind)=lat_temp(first_ind);
    lon_temp(1:first_ind)=lon_temp(first_ind);
    distrun_temp=[0;cumsum(sw_dist(lat_temp,lon_temp,'km'))];

    % remove anything that has been interpolated
    gga_ind=find(abs(gga_interp(:,1)-nav_ave_1s.time')>.5/3600/24);
    gga_interp(gga_ind,:)=nan;
    nav_ave_1s.longitude=gga_interp(:,2)';
    nav_ave_1s.latitude=gga_interp(:,3)';
    distrun_temp([1:(first_ind-1),gga_ind'])=nan;

    clear gga_interp gga_ind lon_temp lat_temp

    %% map VTG data onto 1-s bins

    vtg_interp=interp1(vtg.time',[vtg.time,...
        vtg.(nav_sensor_sets(q).vtg_cog_field),...
        vtg.(nav_sensor_sets(q).vtg_sog_field)],nav_ave_1s.time,'nearest');

    % remove anything that has been interpolated
    vtg_ind=find(abs(vtg_interp(:,1)-nav_ave_1s.time')>.5/3600/24);
    vtg_interp(vtg_ind,:)=nan;
    nav_ave_1s.course_over_ground=vtg_interp(:,2)';
    nav_ave_1s.speed_over_ground=vtg_interp(:,3)'.*1852./3600; % from knots to m/s

    nav_ave_1s.ve=nav_ave_1s.speed_over_ground.*sin(nav_ave_1s.course_over_ground.*pi./180);
    nav_ave_1s.vn=nav_ave_1s.speed_over_ground.*cos(nav_ave_1s.course_over_ground.*pi./180);

    nav_ave_1s.distrun=distrun_temp';

    clear vtg_interp vtg_ind distrun_temp

    %% map HDG data onto 1-s bins

    hdg_interp=interp1(hdt.time',[hdt.time,...
        hdt.(nav_sensor_sets(q).hdt_hdg_field)],nav_ave_1s.time,'nearest');
    hdg_ind=find(abs(hdg_interp(:,1)-nav_ave_1s.time')>.5/3600/24);
    hdg_interp(hdg_ind,:)=nan;

    nav_ave_1s.heading=hdg_interp(:,2)';

    clear hdg_interp hdg_ind

    %% check for dropouts

    nav_missing=find(isnan(nav_ave_1s.latitude));
    nav_missing=nav_missing(nav_missing>=first_ind);
    hdg_missing=find(isnan(nav_ave_1s.heading));
    hdg_missing=hdg_missing(hdg_missing>=first_ind);

    nav_jumps=find(diff(nav_missing)>1);
    nav_jumps=[nav_missing(1),nav_missing(nav_jumps+1);...
        nav_missing(nav_jumps)+1,nav_missing(end)];

    severe_nav_jumps=find(diff(nav_jumps)>15);

    if ~isempty(severe_nav_jumps)
        fprintf(1,'%s - nav gaps over 15 s: \n',nav_sensor_sets(q).set_name);
        jumpstrings=reshape(cellstr(datestr(nav_ave_1s.time(nav_jumps(:,severe_nav_jumps)))),2,length(severe_nav_jumps));
        jumpstrings(3,:)=num2cell(diff(nav_jumps(:,severe_nav_jumps)));
        fprintf(1,'  %s to %s (%d s)\n',jumpstrings{:});
    else
        fprintf(1,'%s - no nav gaps over 15 s\n',nav_sensor_sets(q).set_name);
    end

    %% save the 1-s data file

    save(fullfile('..',strcat(filename,'_1s_ave.mat')),...
        '-struct','nav_ave_1s');

    %% average 1-s data into 30-s averages

    nav_ave_30s = change_average_interval(nav_ave_1s, 30);

    save(fullfile('..',strcat(filename,'_30s_ave.mat')),...
        '-struct','nav_ave_30s');

    if ~isempty(interval)
        nav_ave_intervals = change_average_interval(nav_ave_1s, interval, cruisename);
        save(fullfile(strcat(filename,sprintf('_%d',interval),'s_ave.mat')),...
        '-struct','nav_ave_intervals');
    end
end

% check user wants to save to csv
output_csv = say_what(input('Save to csv? (yes/no) ', 's'));

if output_csv == 1
    writetable(struct2table(nav_ave_1s), ...
        fullfile('..',strcat(filename,'_1s_ave.csv')));
    writetable(struct2table(nav_ave_30s), ...
        fullfile('..',strcat(filename,'_30s_ave.csv')));
    if ~isempty(interval)
        writetable(struct2table(nav_ave_intervals), ...
            fullfile('..',strcat(filename,sprintf('_%d',interval),'s_ave.csv')));
    end
end

%% plot the navigation
plot_ave_nav

end

function nav_ave_intervals = change_average_interval(nav_ave_1s, interval)
    % function to calculate the averages over a different time interval

    nav_vars=fieldnames(nav_ave_1s);
    nintervals=length(nav_ave_1s.time)/interval;

    % simple averaging of most variables
    for n=1:length(nav_vars)
        nav_ave_intervals.(nav_vars{n})=mean(reshape(nav_ave_1s.(nav_vars{n}),interval,nintervals), 'omitnan');
    end

    % vector averaging for COG/SOG and heading
    [nav_ave_intervals.cog,nav_ave_intervals.sog]=cart2pol(nav_ave_intervals.vn,nav_ave_intervals.ve);
    nav_ave_intervals.cog=mod(nav_ave_intervals.cog.*180./pi,360);

    hdg_n=mean(reshape(cos(nav_ave_1s.heading.*pi./180),interval,nintervals), 'omitnan');
    hdg_e=mean(reshape(sin(nav_ave_1s.heading.*pi./180),interval,nintervals), 'omitnan');

    nav_ave_intervals.heading=mod(atan2d(hdg_e,hdg_n),360);

    clear hdg_n hdg_e nav_vars nintervals n
end

