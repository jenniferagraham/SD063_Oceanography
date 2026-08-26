function load_daily_ocl(daynumber,yy)
%LOAD_DAILY_OCL Extract daily underway data from RVDAS
%
%   LOAD_DAILY_OCL (daynumber, year)
%
%   Extracts daily underway (ocl = "oceanlogger") data from RVDAS for each 
%   instrument and writes out data in Matlab format.
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   version 0.1 - 20120331 - Paul Holland, JR165 - initial version?
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - adapted for RVDAS, 
%     generalised for use on different ships using parameters specified in 
%     SET_UNDERWAY_PARAMETERS

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

disp("If first time running check with your local friendly data manager if you have the correct fluorometer conversion. " + ...
    "\nCurrent calibration is set at: ")
ocl_sensors.ocl_water_fluor{1}{7}

load(fullfile('..',['rtables_',cruisename,'.mat']));

clear(ocl_tables{:});

if ~exist(fullfile('..','ocl'),'dir')
    mkdir(fullfile('..','ocl'));
end

thedate=datetime(yy,1,daynumber);
for n=1:length(ocl_tables)
    if ~exist(fullfile('..','ocl',ocl_tables{n}),'dir')
        mkdir(fullfile('..','ocl',ocl_tables{n}));
    end
    if isfield(rtables.server_info,'view')
      data=rvdas_listit(rtables,thedate,thedate+1,...
        strcat(rtables.server_info.view,'_',ocl_tables{n}),'*',false);
    else
      data=rvdas_listit(rtables,thedate,thedate+1,...
        ocl_tables{n},'*',false);
    end
    % add in chlorophyll calibration (from chlorophyll counts to
    % chlorophyll A fluoressence
    if n == 8
        data.chlorophyll_conc = (data.chlorophyll-53).*0.0190; 
    % add in calculation of transmittance from beam attenuation coefficient
    elseif n == 9
        data.transmittance = exp(-data.calculatedbeam.*0.25).*100; 
    end

    eval([ocl_tables{n},'=data;']);
    
    save(fullfile('..','ocl',ocl_tables{n},...
        strcat(ocl_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat')),ocl_tables{n});
end

plot_daily_ocl(daynumber,yy,true)
