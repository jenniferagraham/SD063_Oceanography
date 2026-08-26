function load_daily_bathy(daynumber,yy)
%LOAD_DAILY_BATHY Extract daily echo sounder data from RVDAS
%
%   LOAD_DAILY_BATHY (daynumber, year)
%
%   Extracts daily echo sounder data from RVDAS for each instrument
%   and writes out data in Matlab format.
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   version 0.1 - 200408 - Mike Meredith, CD160 - initial version?
%   version 0.2 - 200512 - Mike Meredith, JR139
%   version 0.3 - 200601 - Dziga Pozzi-Walker and Deb Shoosmith - changed 
%     'daynumber' to a string variable for filename recognition
%   version 1.0 - 20220817 - Povl Abrahamsen, SD020 - adapted for RVDAS
%   version 1.1 - 20230115 - Povl Abrahamsen, DY158 - generalised for use on
%     different ships using parameters specified in SET_UNDERWAY_PARAMETERS

if nargin<2
    dt_now = datetime('now'); 
    yy = year(dt_now);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end
end

set_underway_params

load(fullfile('..',strcat('rtables_',cruisename,'.mat')));

% bathy_variables_to_load=repmat({{'*'}},size(bathy_tables)); % one option: load all fields

% better option: we don't want to load feet, fathoms, etc. if we have
% old-fashioned NMEA sentences

bathy_variables_to_load=cell(size(bathy_tables));
for n=1:length(bathy_sensor_sets)
    table_ind=strmatch(bathy_sensor_sets(n).bathy_table,bathy_tables);
    if isempty(table_ind)
        error('Table %s needs to be added to bathy_tables.',...
            bathy_sensor_sets(n).bathy_table);
    end
    bathy_variables_to_load{table_ind}=union(bathy_variables_to_load{table_ind},...
        {bathy_sensor_sets(n).depth_below_surface_field,...
        bathy_sensor_sets(n).depth_below_transducer_field,...
        bathy_sensor_sets(n).transducer_offset_field});
end
for n=1:length(bathy_tables)
    m=1;
    while m<=length(bathy_variables_to_load{n})
        if isempty(bathy_variables_to_load{n}{m})
            bathy_variables_to_load{n}(m)=[];
        else
            m=m+1;
        end
    end
end

clear(bathy_tables{:});

if ~exist(fullfile('..','bathy'),'dir')
    mkdir(fullfile('..','bathy'));
end

thedate=datetime(yy,1,daynumber);
for n=1:length(bathy_tables)
    if ~exist(fullfile('..','bathy',bathy_tables{n}),'dir')
        mkdir(fullfile('..','bathy',bathy_tables{n}));
    end
    try
      if isfield(rtables.server_info,'view')
        data=rvdas_listit(rtables,thedate,thedate+1,...
          strcat(rtables.server_info.view,'_',bathy_tables{n}),bathy_variables_to_load{n});
      else
        data=rvdas_listit(rtables,thedate,thedate+1,...
          bathy_tables{n},bathy_variables_to_load{n});
      end
      eval([bathy_tables{n},'=data;']);
      save(fullfile('..','bathy',bathy_tables{n},...
        strcat(bathy_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat')),bathy_tables{n});
    catch
      warning('No data from %s on jday %d',bathy_tables{n},daynumber);
    end
end

plot_daily_bathy(daynumber,yy,true)
