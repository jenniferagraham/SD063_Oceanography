%MAKE_AVE_OCL Make 1-s and 30-s averaged underway data files
%
%   version 0.1 - 20120331 - Paul Holland, JR165 - initial version?
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - adapted for RVDAS, 
%     generalised for use on different ships using parameters specified in 
%     SET_UNDERWAY_PARAMETERS
%   version 1.1 - 20240813 - Povl Abrahamsen, SD041 - fix treatment of
%     non-numeric fields, move plots into PLOT_AVE_OCL
%   version 1.2 - 20240919 - Povl Abrahamsen, post-SD041 - deal with data 
%     streams that start and stop and different times from the first file. 
%     This was an issue on SD041 where the flow meter was switched off 
%     before the end of the cruise, causing problems for processing met 
%     data that carried on beyond that date.
%   version 1.3 - 20241213 - Povl Abrahamsen, post-SD033 - deal with nav
%     files that don't start and end on the same dates as the ocl files.

clear 

set_underway_params

%% load data

for q=1:length(ocl_tables)

    fprintf('Variable: %s \n', ocl_tables{q});

    load(fullfile('..','ocl',ocl_tables{q},[ocl_tables{q},'_all.mat']));
    data=eval(ocl_tables{q});

    if q==1
        ocl_ave_1s=struct('time',floor(data.time(1)):(1/3600/24):...
            ceil(data.time(end))-(1/3600/24));
        j_day_start=round(data.time_jday(1));
        j_day_end=round(data.time_jday(end));

    else % we need to check that our data are the same length...
        if floor(data.time(1)) < ocl_ave_1s.time(1)
            % we need to pad the start of our data with nans!
            for r=1:(q-1)
                ocl_data.([ocl_tables{r},'_interp'])=...
                    [nan((ocl_ave_1s.time(1)-floor(data.time(1)))*24*3600,size(ocl_data.([ocl_tables{r},'_interp']),2));...
                     ocl_data.([ocl_tables{r},'_interp'])];
            end
            ocl_ave_1s=struct('time',floor(data.time(1)):(1/3600/24):...
                ceil(ocl_ave_1s.time(end))-(1/3600/24));
        end
        if ceil(data.time(end)) > ceil(ocl_ave_1s.time(end))
            % we need to pad the end of our data with nans!
            for r=1:(q-1)
                ocl_data.([ocl_tables{r},'_interp'])=...
                    [ocl_data.([ocl_tables{r},'_interp']);...
                     nan((ceil(data.time(end))-ceil(ocl_ave_1s.time(end)))*24*3600,size(ocl_data.([ocl_tables{r},'_interp']),2))];
            end
            ocl_ave_1s=struct('time',floor(ocl_ave_1s.time(1)):(1/3600/24):...
                ceil(data.time(end))-(1/3600/24));
        end
    end

    % remove any non-numeric fields before interpolating
    data_fields = fieldnames(data);
    for r=1:length(data_fields)
        if ~isnumeric(data.(data_fields{r}))
            data=rmfield(data,data_fields{r});
        end
    end

    % % remove all points with non-finite time stamp values - shouldn't be
    % %     necessary following fixes to append_/concatenate_table.m
    % valid_indices = ~isnan(data.time);
    % data_fields = fieldnames(data);
    % for k = 1:numel(data_fields)
    %     data.(data_fields{k})= data.(data_fields{k})(valid_indices);
    % end

    % map data onto 1-s bins
    ocl_data.([ocl_tables{q},'_fields'])=fieldnames(data);
    data_interp=interp1(data.time',struct2array(data),ocl_ave_1s.time,'nearest');

    % remove anything that has been interpolated
    ind=find(abs(data_interp(:,strmatch('time',ocl_data.([ocl_tables{q},'_fields']),'exact'))-...
        ocl_ave_1s.time')>.5/3600/24); 
    data_interp(ind,:)=nan;
    fprintf('Removed %d nan values from ocl_tables %s\n', sum(ind), ocl_tables{q});
    ocl_data.([ocl_tables{q},'_interp'])=data_interp;

end

clear('data','data_interp','ind',ocl_tables{:})

%% populate data fields, applying factory cals if necessary

ocl_field_types=fields(ocl_sensors);
for n=1:length(ocl_field_types)
    for o=1:length(ocl_sensors.(ocl_field_types{n}))
        sensor_info=ocl_sensors.(ocl_field_types{n}){o};
        ocl_ave_1s.(sensor_info{3})=ocl_data.([sensor_info{1},'_interp'])(:,...
            strmatch(sensor_info{2},ocl_data.([sensor_info{1},'_fields']),'exact'))';
        if length(sensor_info)>6 && ~isempty(sensor_info{7})
            ocl_ave_1s.(sensor_info{3})=feval(sensor_info{7},ocl_ave_1s.(sensor_info{3}));
        end
        if any(ismember(ocl_data.([sensor_info{1},'_fields']),[sensor_info{2},'_uncal']))
            ocl_ave_1s.([sensor_info{3},'_uncal'])=ocl_data.([sensor_info{1},'_interp'])(:,...
                strmatch([sensor_info{2},'_uncal'],ocl_data.([sensor_info{1},'_fields']),'exact'))';
            if length(sensor_info)>6 && ~isempty(sensor_info{7})
                ocl_ave_1s.([sensor_info{3},'_uncal'])=feval(sensor_info{7},...
                    ocl_ave_1s.([sensor_info{3},'_uncal']));
            end
        end
    end
end

clear ocl_field_types sensor_info

save(fullfile('..',[cruisename,'_ocl_1s_ave.mat']),'-struct','ocl_ave_1s');

% check to see if user wishes to save specific dates
check_date_subset=say_what(input('Do you wish to save a subset period? (y/n)',"s"));

if check_date_subset==1
    startday = input('Input start jday to begin the averaging: ');  
    endday = input('Input end jday to end averaging at: ');
    yy = input('Input year: ', "s");
    
    valid_idx = (datetime(ocl_ave_1s.time, 'ConvertFrom','datenum') >= datetime(yy,1,startday)) & (datetime(ocl_ave_1s.time, 'ConvertFrom','datenum') <= datetime(yy,1,endday));
    subset_ocl_ave_1s = structfun(@(x) x(valid_idx, :), ocl_ave_1s, 'UniformOutput', false);
    
    save(fullfile('..',[cruisename,sprintf('_ocl_%d_%d_1s_ave.mat', startday, endday)]),'-struct','subset_ocl_ave_1s');
end

%% average 1-s data into 30-s averages
%ocl_ave_30s = ocl_ave_over_interval(ocl_ave_1s, 30, ocl_calc_std);

ocl_vars=fieldnames(ocl_ave_1s);
n30s=length(ocl_ave_1s.time)/30;

% load navigation for calculating absolute wind
nav_ave_30s=load(fullfile('..',[cruisename,'_nav',...
nav_sensor_sets(nav_sensor_set_best).file_add,'_30s_ave.mat']));

% simple averaging of most variables
for n=1:length(ocl_vars)
    ocl_ave_30s.(ocl_vars{n})=mean(reshape(ocl_ave_1s.(ocl_vars{n}),30,n30s), 'omitnan');
end

if length(nav_ave_30s.time)~=length(ocl_ave_30s.time)
    error('Length of averaged nav and ocl files is different!')
end

ocl_ave_30s.("latitude") = nav_ave_30s.latitude;
ocl_ave_30s.("longitude") = nav_ave_30s.longitude;

if ocl_calc_true_wind

  if length(ocl_sensors.ocl_wind_rel_speed)~=length(ocl_sensors.ocl_wind_rel_dir)
    error('Must have the same number of relative wind speed/direction sensors!');
  end

  for n=1:length(ocl_sensors.ocl_wind_rel_speed)

    rel_speed_name=ocl_sensors.ocl_wind_rel_speed{n}{3};
    rel_dir_name=ocl_sensors.ocl_wind_rel_dir{n}{3};
    abs_speed_name=ocl_true_wind_names{n}{1};
    abs_dir_name=ocl_true_wind_names{n}{2};
    abs_u_name=ocl_true_wind_names{n}{3};
    abs_v_name=ocl_true_wind_names{n}{4};

    % vector averaging for relative wind
    [wind_rel_v_1s,wind_rel_u_1s]=pol2cart(ocl_ave_1s.(rel_dir_name).*pi./180,...
        ocl_ave_1s.(rel_speed_name));
    [ocl_ave_30s.(rel_dir_name),ocl_ave_30s.(rel_speed_name)]=cart2pol(...
        mean(reshape(wind_rel_v_1s,30,n30s), 'omitnan'),mean(reshape(wind_rel_u_1s,30,n30s), 'omitnan'));
    ocl_ave_30s.(rel_dir_name)=mod(ocl_ave_30s.(rel_dir_name).*180./pi,360);

    % calculate true wind

    [wind_rel_v,wind_rel_u]=pol2cart((ocl_ave_30s.(rel_dir_name)+nav_ave_30s.heading+180).*pi./180,...
        ocl_ave_30s.(rel_speed_name)); % vector for which way the wind is blowing TO
    ocl_ave_30s.(abs_u_name)=wind_rel_u+nav_ave_30s.ve;
    ocl_ave_30s.(abs_v_name)=wind_rel_v+nav_ave_30s.vn;
    [ocl_ave_30s.(abs_dir_name),ocl_ave_30s.(abs_speed_name)]=cart2pol(ocl_ave_30s.(abs_v_name),ocl_ave_30s.(abs_u_name));
    ocl_ave_30s.(abs_dir_name)=mod(ocl_ave_30s.(abs_dir_name).*180./pi+180,360); % direction the wind is blowing FROM

  end
else

  if length(ocl_sensors.ocl_wind_true_speed)~=length(ocl_sensors.ocl_wind_true_dir)
    error('Must have the same number of relative wind speed/direction sensors!');
  end

  % vector averaging for true wind - untested
  for n=1:length(ocl_sensors.ocl_wind_true_speed)

    abs_speed_name=ocl_true_wind_names{n}{1};
    abs_dir_name=ocl_true_wind_names{n}{2};
    abs_u_name=ocl_true_wind_names{n}{3};
    abs_v_name=ocl_true_wind_names{n}{4};

    [wind_true_v_1s,wind_true_u_1s]=pol2cart(ocl_ave_1s.(ocl_sensors.ocl_wind_true_dir{n}{3}).*pi./180,...
        ocl_ave_1s.(ocl_sensors.ocl_wind_true_speed{n}{3}));
    ocl_ave_30s.(abs_u_name)=mean(reshape(wind_true_u_1s,30,n30s), 'omitnan');
    ocl_ave_30s.(abs_v_name)=mean(reshape(wind_true_v_1s,30,n30s), 'omitnan');
    [ocl_ave_30s.(abs_dir_name),ocl_ave_30s.(abs_speed_name)]=cart2pol(...
        ocl_ave_30s.(abs_v_name),ocl_ave_30s.(abs_u_name));
    ocl_ave_30s.(abs_dir_name)=mod(ocl_ave_30s.(abs_dir_name).*180./pi,360); % direction the wind is blowing FROM

  end
end

clear wind_rel_* ocl_vars n30s n

save(fullfile('..',[cruisename,'_ocl_30s_ave.mat']),'-struct','ocl_ave_30s');

if check_date_subset==1
    valid_idx = (datetime(ocl_ave_int.time, 'ConvertFrom','datenum') >= datetime(yy,1,startday)) & (datetime(ocl_ave_int.time, 'ConvertFrom','datenum') <= datetime(yy,1,endday));
    subset_ocl_ave_30s = structfun(@(x) x(valid_idx, :), ocl_ave_int, 'UniformOutput', false);
    save(fullfile('..',[cruisename,sprintf('_ocl_%d_%d_30s_ave.mat', startday, endday)]),'-struct','subset_ocl_ave_30s');
end

check_interval = say_what(input( ...
    "Do you wish to create an average over a different interval? (y/n) ", "s"));

if check_interval == 1
    interval = integer(input("Input interval in minutes: ", "s"));
    ocl_ave_int = ocl_ave_over_interval(ocl_ave_30s, interval, ocl_calc_std);
end

%% plots

plot_ave_ocl
plot_tot_ocl_map(j_day_start, j_day_end, year(datetime('now')))

function ocl_ave_int = ocl_ave_over_interval(ocl_ave_30s, interval, ocl_calc_std)
    ocl_vars=fieldnames(ocl_ave_30s);
    ns=length(ocl_ave_30s.time)/(interval*2); % assuming interval in minutes
    
    % simple averaging of most variables
    for n=1:length(ocl_vars)
        if contains(ocl_vars{n}, ocl_calc_std)
            ocl_ave_int.([ocl_vars{n},'_avg'])=mean(reshape(ocl_ave_30s.(ocl_vars{n}),interval,ns), 'omitnan');
            ocl_ave_int.([ocl_vars{n},'_max'])=max(reshape(ocl_ave_30s.(ocl_vars{n}),interval,ns), 'omitnan');
            ocl_ave_int.([ocl_vars{n},'_min'])=min(reshape(ocl_ave_30s.(ocl_vars{n}),interval,ns), 'omitnan');
        else
            ocl_ave_int.(ocl_vars{n})=mean(reshape(ocl_ave_30s.(ocl_vars{n}),interval,ns), 'omitnan');
        end
    end
end
    