function plot_daily_bathy(daynumber,yy,load_from_caller)
%PLOT_DAILY_BATHY Plot daily echo sounder data from RVDAS
%
%   PLOT_DAILY_BATHY (daynumber, year, load_from_caller)
%
%   Plots daily echo sounder data, with corrections as required from Carter
%   tables.
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%   The third parameter specifies whether to load data from the calling
%   function or from disk. If omitted, data will be loaded from disk.
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

if nargin<2
    dt_now = datetime('now'); 
    yy = year(dt_now);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end

    if jday_now<120 && daynumber>240
        yy=yy-1;
    end
end

set_underway_params

for n=1:length(bathy_tables)
    if nargin>2 && load_from_caller
        try
            data=evalin('caller',bathy_tables{n});
            eval([bathy_tables{n},'=data;']);
        end
    else
        filename_clean=fullfile('..','bathy',bathy_tables{n},...
                [bathy_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'_clean.mat']);
        filename_orig=fullfile('..','bathy',bathy_tables{n},...
                [bathy_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat']);
        if exist(filename_clean,'file')
            load(filename_clean);
        elseif exist(filename_orig,'file')
            load(filename_orig);
        end
    end
end

%%
figure
h=[];
labels={};
hold on;

for n=1:length(bathy_sensor_sets)
    if exist(bathy_sensor_sets(n).bathy_table,'var')
        data=eval(bathy_sensor_sets(n).bathy_table);
        labelsuffix='';
        if ~isempty(bathy_sensor_sets(n).depth_below_surface_field)
            if isfield(data,[bathy_sensor_sets(n).depth_below_surface_field,'_clean'])
                bathy_data=data.([bathy_sensor_sets(n).depth_below_surface_field,'_clean']);
                labelsuffix = ' (cleaned)';
            else
                bathy_data=data.(bathy_sensor_sets(n).depth_below_surface_field);
            end
        else
            if isfield(data,[bathy_sensor_sets(n).depth_below_transducer_field,'_clean'])
                bathy_data=data.([bathy_sensor_sets(n).depth_below_transducer_field,'_clean']);
                labelsuffix = ' (cleaned)';
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
        h2=plot(datetime(data.time_jday, 'ConvertFrom','datenum'),bathy_data,'-'); %,'LineWidth',2);
        h=[h,h2];
        labels{end+1}=[bathy_sensor_sets(n).set_name_long,labelsuffix];
    else
        fprintf(1,'No data for table %s\n',bathy_sensor_sets(n).bathy_table);
    end
end
hold on

xlabel('time');
legend(h,labels{:});

