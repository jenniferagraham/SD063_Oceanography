function load_daily_nav(daynumber,yy)
%LOAD_DAILY_NAV Extract daily navigation data from RVDAS
%
%   LOAD_DAILY_NAV (daynumber, year)
%
%   Extracts daily navigation data from RVDAS for each instrument
%   and writes out data in Matlab format.
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   version 0.1 - 20120331 - Paul Holland, JR165 - initial version?
%   version 1.0 - 20220818 - Povl Abrahamsen, SD020 - adapted for RVDAS 
%   version 1.1 - 20230109 - Povl Abrahamsen, DY158 - generalised for use on
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

clear(nav_tables{:});

if ~exist(fullfile('..','nav'),'dir')
    mkdir(fullfile('..','nav'));
end

thedate=datetime(yy,1,daynumber);

for n=1:length(nav_tables)
    tic
    if ~exist(fullfile('..','nav',nav_tables{n}),'dir')
        mkdir(fullfile('..','nav',nav_tables{n}));
    end
    if isfield(rtables.server_info,'view')
      data=rvdas_listit(rtables,thedate,thedate+1,...
        strcat(rtables.server_info.view,'_',nav_tables{n}),'*',nav_convert_positions);
    else
      data=rvdas_listit(rtables,thedate,thedate+1,...
        nav_tables{n},'*',nav_convert_positions);
    end
    eval([nav_tables{n},'=data;']);
    save(fullfile('..','nav',nav_tables{n},...
        strcat(nav_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat')),nav_tables{n});
    toc
end

plot_daily_nav(daynumber,yy,true)
