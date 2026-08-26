function make_ave_bathy(startday, endday, yy)
%MAKE_AVE_BATHY Make 1-s and 30-s averaged underway echo sounder files
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version
%   version 1.1 - 20230117 - Povl Abrahamsen, DY158 - generalised for use on
%     different ships using parameters specified in SET_UNDERWAY_PARAMETERS
%   version 1.2 - 20240813 - Povl Abrahamsen, SD041 - move plots into PLOT_AVE_BATHY
%   version 1.3 - 20250309 - Kat Turner - add in little additions

% check to see if user wants different interval of time
if nargin < 4
    fprintf('This script creates averages at a 1s interval and a 30s interval.\n');
    interval = input(['If you wish for a separate length of interval insert here.\n' ...
    'Statement needs to be written in second, for example 1 minute will be input as 60 (leave blank fo no further interval): ']);
end

% check for start and end day
if nargin < 3
    yy = 2000 + mod(year(datetime('now')), 100);
end 

if nargin < 2
    startday = input('Input start jday to begin the averaging (blank for first day): ');  
    endday = input('Input end jday to end averaging at (blank for last day): ');
end

set_underway_params

%% load nav data

nav_filename = fullfile('..',strcat(cruisename,'_nav',...
    nav_sensor_sets(nav_sensor_set_best).file_add,'_1s_ave.mat'));
if ~exist(nav_filename,'file')
    warning("No average nav file found, please create this first!")
    return
end
nav_ave_1s=load(nav_filename);

%% set up new structure for bathy data

jday_start = day(datetime(nav_ave_1s.time(1), 'ConvertFrom', 'datenum'), 'dayofyear');
jday_end = day(datetime(nav_ave_1s.time(end), 'ConvertFrom', 'datenum'), 'dayofyear');

if isempty(startday)
    startday = jday_start; 
end
if isempty(endday) 
    endday = jday_end; 
end

if startday == jday_start && endday == jday_end
    filename = strcat(cruisename,'_bathy_');
else
    filename = strcat(cruisename,'_bathy_',sprintf('%d_%d_', startday,endday));
end

bathy_ave_1s=struct('time',nav_ave_1s.time);

if startday ~= jday_start || endday ~= jday_end
    valid_idx = (datetime(nav_ave_1s.time, 'ConvertFrom','datenum') >= datetime(yy,1,startday)) & (datetime(nav_ave_1s.time, 'ConvertFrom','datenum') <= datetime(yy,1,endday));
    bathy_ave_1s = structfun(@(x) x(valid_idx, :), bathy_ave_1s, 'UniformOutput', false);
end


%% cycle through our bathymetry sets

for n=1:length(bathy_sensor_sets)

    fprintf(1,'Averaging set: %s\n',bathy_sensor_sets(n).set_name_long);
    

    %% load data

    datafile=fullfile('..','bathy',bathy_sensor_sets(n).bathy_table,...
        [bathy_sensor_sets(n).bathy_table,'_all.mat']);
    if ~exist(datafile,'file')
        fprintf(1,'No data for set %s. Skipping...\n',bathy_sensor_sets(n).set_name_long);
        continue;
    end
    data=load(datafile);
    data=data.(bathy_sensor_sets(n).bathy_table);

    %% map data onto 1-s bins

    if ~isempty(bathy_sensor_sets(n).depth_below_surface_field)
        if isfield(data,[bathy_sensor_sets(n).depth_below_surface_field,'_clean'])
            bathy_data=data.([bathy_sensor_sets(n).depth_below_surface_field,'_clean']);
        else
            bathy_data=data.(bathy_sensor_sets(n).depth_below_surface_field);
        end
    else
        if isfield(data,[bathy_sensor_sets(n).depth_below_transducer_field,'_clean'])
            bathy_data=data.([bathy_sensor_sets(n).depth_below_transducer_field,'_clean']);
        else
            bathy_data=data.(bathy_sensor_sets(n).depth_below_transducer_field);
        end
        if ~isempty(bathy_sensor_sets(n).transducer_offset_field)
            bathy_data=bathy_data+data.(bathy_sensor_sets(n).transducer_offset_field);
        elseif ~isempty(bathy_sensor_sets(n).fixed_transducer_offset)
            bathy_data=bathy_data+bathy_sensor_sets(n).fixed_transducer_offset;
        else
            error('No transducer offset specified (fixed of variable) for %s.',...
                bathy_sensor_sets(n).set_name_long);
        end
    end

    bathy_interp=interp1(data.time',[data.time,...
        bathy_data],bathy_ave_1s.time,'nearest');

    % remove anything that has been interpolated
    bathy_ind=find(abs(bathy_interp(:,1)-bathy_ave_1s.time')>.5/3600/24); 
    bathy_interp(bathy_ind,:)=nan;

    if bathy_sensor_sets(n).depth_is_uncorrected
        bathy_ave_1s.([bathy_sensor_sets(n).set_name,'_depth_uncorr'])=...
            bathy_interp(:,2)';
        bathy_ave_1s.([bathy_sensor_sets(n).set_name,'_depth'])=...
            mcarter(nav_ave_1s.latitude,nav_ave_1s.longitude,bathy_interp(:,2)');
    else
        bathy_ave_1s.([bathy_sensor_sets(n).set_name,'_depth'])=...
            bathy_interp(:,2)';
    end

    clear bathy_data bathy_ind bathy_interp

end

save(fullfile('..',strcat(filename,'1s_ave.mat')),'-struct','bathy_ave_1s');

%% average 1-s data into 30-s averages

bathy_vars=fieldnames(bathy_ave_1s);
n30s=length(bathy_ave_1s.time)/30;

% simple averaging of depths
for n=1:length(bathy_vars)
    bathy_ave_30s.(bathy_vars{n})=mean(reshape(bathy_ave_1s.(bathy_vars{n}),30,n30s), 'omitnan');
end

clear n bathy_vars n30s

save(fullfile('..',strcat(filename,'30s_ave.mat')),'-struct','bathy_ave_30s');

% check user wants to save to csv
output_csv = say_what(input('Save to csv? (yes/no) ', 's'));

if output_csv == 1
    writetable(struct2table(bathy_ave_1s), ...
        fullfile('..',strcat(filename,'1s_ave.csv')));
    writetable(struct2table(bathy_ave_30s), ...
        fullfile('..',strcat(filename,'30s_ave.mat')));
end

%% plot the data

plot_ave_bathy