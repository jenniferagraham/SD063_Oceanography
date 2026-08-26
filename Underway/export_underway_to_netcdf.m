%EXPORT_UNDERWAY_TO_NETCDF Exports a merged 30-s nav/bathy/ocl NetCDF file
%
%   version 1.0 - 20230119 - Povl Abrahamsen, DY158 - initial version
%   version 1.1 - 20241213 - Povl Abrahamsen, post-SD033 - deal with 
%       missing ocl or bathy datasets: warn, but do not crash!
%   version 1.2 - 20241218 - Povl Abrahamsen, post-SD033 - use clean ocl 
%       data if available

set_underway_params

%% load navigation data

nav_ave_30s=load(fullfile('..',[cruisename,'_nav',...
    nav_sensor_sets(nav_sensor_set_best).file_add,'_30s_ave.mat']));

%% create our file and a time dimension/variable

fname=fullfile('..',[cruisename,'_underway.nc']);

if exist(fname,'file')
    delete(fname);
end

nccreate(fname,'time','Dimensions',{'time',inf});

%% write general metadata

% We follow the CF conventions version 1.10:
% http://cfconventions.org/Data/cf-conventions/cf-conventions-1.10/cf-conventions.html
ncwriteatt(fname,'/','Conventions','CF-1.10'); 

metadata_fieldnames=fieldnames(cruise_netcdf_metadata);
for n=1:length(metadata_fieldnames)
    ncwriteatt(fname,'/',metadata_fieldnames{n},...
        cruise_netcdf_metadata.(metadata_fieldnames{n}));
end

yearbase=datevec(nav_ave_30s.time(1));
yearbase=yearbase(1);
datenumbase=datenum(yearbase,1,0);

ncwriteatt(fname,'/','data_time_origin',datevec(datenumbase+1)); % for compatibility with mstar

%% write navigation data

ncwriteatt(fname,'time','units',sprintf('days since %s',...
    datestr(datenumbase,'yyyy-mm-dd HH:MM:SS')));
ncwriteatt(fname,'time','standard_name','time');
ncwrite(fname,'time',nav_ave_30s.time-datenumbase);

nccreate(fname,'latitude','Dimensions',{'time'});
ncwriteatt(fname,'latitude','units','degree_north');
ncwriteatt(fname,'latitude','long_name','latitude');
ncwriteatt(fname,'latitude','standard_name','latitude');
ncwrite(fname,'latitude',nav_ave_30s.latitude);

nccreate(fname,'longitude','Dimensions',{'time'});
ncwriteatt(fname,'longitude','units','degree_east');
ncwriteatt(fname,'longitude','long_name','longitude');
ncwriteatt(fname,'longitude','standard_name','longitude');
ncwrite(fname,'longitude',nav_ave_30s.longitude);

nccreate(fname,'cog','Dimensions',{'time'});
ncwriteatt(fname,'cog','units','degree');
ncwriteatt(fname,'cog','long_name','course over ground');
ncwriteatt(fname,'cog','standard_name','platform_course');
ncwrite(fname,'cog',nav_ave_30s.cog);

nccreate(fname,'sog','Dimensions',{'time'});
ncwriteatt(fname,'sog','units','m s-1');
ncwriteatt(fname,'sog','long_name','speed over ground');
ncwriteatt(fname,'sog','standard_name','platform_speed_wrt_ground');
ncwrite(fname,'sog',nav_ave_30s.sog);

nccreate(fname,'heading','Dimensions',{'time'});
ncwriteatt(fname,'heading','units','degree');
ncwriteatt(fname,'heading','long_name','heading');
ncwriteatt(fname,'heading','standard_name','platform_orientation');
ncwrite(fname,'heading',nav_ave_30s.heading);

nccreate(fname,'distrun','Dimensions',{'time'});
ncwriteatt(fname,'distrun','units','km');
ncwriteatt(fname,'distrun','long_name','distance run');
ncwrite(fname,'distrun',nav_ave_30s.distrun);

%% load ocl data

have_ocl=false;
if exist(fullfile('..',[cruisename,'_ocl_30s_ave_clean.mat']),'file')
  ocl_ave_30s=load(fullfile('..',[cruisename,'_ocl_30s_ave_clean.mat']));
  have_ocl=true;
elseif exist(fullfile('..',[cruisename,'_ocl_30s_ave.mat']),'file')
  ocl_ave_30s=load(fullfile('..',[cruisename,'_ocl_30s_ave.mat']));
  have_ocl=true;
end

%% write ocl data

if have_ocl
  ocl_sensor_fieldnames=fieldnames(ocl_sensors);
  for n=1:length(ocl_sensor_fieldnames)
    for o=1:length(ocl_sensors.(ocl_sensor_fieldnames{n}))
      sensor_info=ocl_sensors.(ocl_sensor_fieldnames{n}){o};
      nccreate(fname,sensor_info{3},'Dimensions',{'time'});
      if length(sensor_info)>3 && ~isempty(sensor_info{4})
        ncwriteatt(fname,sensor_info{3},'units',sensor_info{4});
      end
      if length(sensor_info)>4 && ~isempty(sensor_info{5})
        ncwriteatt(fname,sensor_info{3},'long_name',sensor_info{5});
      end
      if length(sensor_info)>5 && ~isempty(sensor_info{6})
        ncwriteatt(fname,sensor_info{3},'standard_name',sensor_info{6});
      end
      ncwrite(fname,sensor_info{3},ocl_ave_30s.(sensor_info{3}));
    end
  end

  for n=1:length(ocl_true_wind_names)
    nccreate(fname,ocl_true_wind_names{n}{1},'Dimensions',{'time'});
    ncwriteatt(fname,ocl_true_wind_names{n}{1},'units','m s-1');
    ncwriteatt(fname,ocl_true_wind_names{n}{1},'long_name','absolute wind speed');
    ncwriteatt(fname,ocl_true_wind_names{n}{1},'standard_name','wind_speed');
    ncwrite(fname,ocl_true_wind_names{n}{1},ocl_ave_30s.(ocl_true_wind_names{n}{1}));

    nccreate(fname,ocl_true_wind_names{n}{2},'Dimensions',{'time'});
    ncwriteatt(fname,ocl_true_wind_names{n}{2},'units','degree');
    ncwriteatt(fname,ocl_true_wind_names{n}{2},'long_name','absolute wind direction');
    ncwriteatt(fname,ocl_true_wind_names{n}{2},'standard_name','wind_from_direction');
    ncwrite(fname,ocl_true_wind_names{n}{2},ocl_ave_30s.(ocl_true_wind_names{n}{2}));

    nccreate(fname,ocl_true_wind_names{n}{3},'Dimensions',{'time'});
    ncwriteatt(fname,ocl_true_wind_names{n}{3},'units','m s-1');
    ncwriteatt(fname,ocl_true_wind_names{n}{3},'long_name','eastward component of wind');
    ncwriteatt(fname,ocl_true_wind_names{n}{3},'standard_name','eastward_wind');
    ncwrite(fname,ocl_true_wind_names{n}{3},ocl_ave_30s.(ocl_true_wind_names{n}{4}));

    nccreate(fname,ocl_true_wind_names{n}{4},'Dimensions',{'time'});
    ncwriteatt(fname,ocl_true_wind_names{n}{4},'units','m s-1');
    ncwriteatt(fname,ocl_true_wind_names{n}{4},'long_name','northward component of wind');
    ncwriteatt(fname,ocl_true_wind_names{n}{4},'standard_name','northward_wind');
    ncwrite(fname,ocl_true_wind_names{n}{4},ocl_ave_30s.(ocl_true_wind_names{n}{4}));
  end
else
  warning('No ocl file for cruise %s',cruisename);
end

%% load bathymetry data

if exist(fullfile('..',[cruisename,'_bathy_30s_ave.mat']),'file')
  bathy_ave_30s=load(fullfile('..',[cruisename,'_bathy_30s_ave.mat']));

%% write bathymetry data

  for n=1:length(bathy_sensor_sets)
    bathy_var_name=[bathy_sensor_sets(n).set_name,'_depth'];
    if ~isfield(bathy_ave_30s,bathy_var_name)
        continue;
    end
    nccreate(fname,bathy_var_name,'Dimensions',{'time'});
    ncwriteatt(fname,bathy_var_name,'units','m');
    ncwriteatt(fname,bathy_var_name,'long_name',[bathy_sensor_sets(n).set_name_long,' depth']);
    ncwriteatt(fname,bathy_var_name,'standard_name','sea_floor_depth_below_sea_surface');
    ncwrite(fname,bathy_var_name,bathy_ave_30s.(bathy_var_name));

    if bathy_sensor_sets(n).depth_is_uncorrected
        ncwriteatt(fname,bathy_var_name,'comment','Corrected using Carter, D. J. T., 1980. Echo-Sounding Correction Tables, 3rd edition, Hydrographic Department, Taunton, UK');

        bathy_var_name=[bathy_sensor_sets(n).set_name,'_depth_uncorr'];
        nccreate(fname,bathy_var_name,'Dimensions',{'time'});
        ncwriteatt(fname,bathy_var_name,'units','m');
        ncwriteatt(fname,bathy_var_name,'long_name',[bathy_sensor_sets(n).set_name_long,' depth (uncorrected)']);
        ncwriteatt(fname,bathy_var_name,'standard_name','sea_floor_depth_below_sea_surface');
        ncwriteatt(fname,bathy_var_name,'comment','Computed assuming a constant speed of sound of 1500 m s-1.');        
        ncwrite(fname,bathy_var_name,bathy_ave_30s.(bathy_var_name));
    end
  end
else
  warning('No bathy file for cruise %s',cruisename);
end

%% write a time stamp

ncwriteatt(fname,'/','date_file_updated',datevec(now)); % for compatibility with mstar
ncwriteatt(fname,'/','time_convention',...
    ['date_file_updated and data_time_origin are 6-element vectors, as ',...
     'commonly used in matlab date handling: [yyyy mo dd hh mm ss]']);
