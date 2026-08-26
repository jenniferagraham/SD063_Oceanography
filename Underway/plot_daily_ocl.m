function plot_daily_ocl(daynumber,yy,load_from_caller)
%PLOT_DAILY_OCL Plot daily underway data from RVDAS
%
%   PLOT_DAILY_OCL (daynumber, year, load_from_caller)
%
%   Plots daily underway (ocl = "oceanlogger") data:
%     - water flow, temperature, salinity, fluorometer, transmissometer
%     - air temperature, humidity, pressure, radiation (TIR/PAR)
%     - relative wind direction/speed
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%   The third parameter specifies whether to load data from the calling
%   function or from disk. If omitted, data will be loaded from disk.
%
%   version 0.1 - 20120331 - Paul Holland, JR165 - initial version?
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - adapted for RVDAS, 
%     generalised for use on different ships using parameters specified in 
%     SET_UNDERWAY_PARAMETERS

if nargin<2
    dt_now = datetime('now'); 
    yy = mod(year(dt_now), 100);        
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

for n=1:length(ocl_tables)
    if nargin>2 && load_from_caller
        data=evalin('caller',ocl_tables{n});
        eval([ocl_tables{n},'=data;']);
    elseif exist(fullfile('..','ocl',ocl_tables{n},...
            [ocl_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'_clean.mat']),'file')
        load(fullfile('..','ocl',ocl_tables{n},...
            [ocl_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'_clean.mat']));
    else
        load(fullfile('..','ocl',ocl_tables{n},...
            [ocl_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat']));
    end
end

%%
figure('name',[' OCL flow, temp, sal, fluo, trans ',num2str(daynumber,'%03d')])
orient tall

f1ax=subplot(5,1,1);
colors=get(gca,'ColorOrder');
hold on;
for q=1:length(ocl_sensors.ocl_flow)
    plot_ocl_field(ocl_sensors.ocl_flow{q});
end
ylabel('Flow (L/min)');

f1ax(2)=subplot(5,1,2);
hold on;
for q=1:length(ocl_sensors.ocl_water_temp)
    plot_ocl_field(ocl_sensors.ocl_water_temp{q});
end
ylabel('Water temperature (^oC)');
legend

f1ax(3)=subplot(5,1,3);
hold on;
for q=1:length(ocl_sensors.ocl_water_sal)
    plot_ocl_field(ocl_sensors.ocl_water_sal{q});
end
ylabel('Salinity (psu)');
legend

f1ax(4)=subplot(5,1,4);
hold on;
for q=1:length(ocl_sensors.ocl_water_fluor)
    plot_ocl_field(ocl_sensors.ocl_water_fluor{q});
end
ylabel('Fluorometer (\mug/l)');

f1ax(5)=subplot(5,1,5);
hold on;
for q=1:length(ocl_sensors.ocl_water_trans)
    plot_ocl_field(ocl_sensors.ocl_water_trans{q});
end
ylabel('Transmissometer (%)');

xlabel('Time');
linkaxes(f1ax,'x');

%%
figure('name',[' OCL air temp, humid, press, rad ',num2str(daynumber,'%03d')])
orient tall

f2ax=subplot(5,1,1);
hold on;
for q=1:length(ocl_sensors.ocl_air_temp)
    plot_ocl_field(ocl_sensors.ocl_air_temp{q});
end
ylabel('Air temperature (^oC)');
legend;

f2ax(2)=subplot(5,1,2);
hold on;
for q=1:length(ocl_sensors.ocl_air_rel_hum)
    plot_ocl_field(ocl_sensors.ocl_air_rel_hum{q});
end
ylabel('Rel. humidity (%)');
legend;

f2ax(3)=subplot(5,1,3);
hold on;
for q=1:length(ocl_sensors.ocl_air_pressure)
    plot_ocl_field(ocl_sensors.ocl_air_pressure{q});
end
ylabel('Air pressure (hPa)');
legend;

f2ax(4)=subplot(5,1,4:5);
yyaxis left
hold on;
for q=1:length(ocl_sensors.ocl_rad_tir)
    plot_ocl_field(ocl_sensors.ocl_rad_tir{q});
end
ylim([0 max(ylim)]);
ylabel('TIR (W/m^2)');
yyaxis right
hold on;
for q=1:length(ocl_sensors.ocl_rad_par)
    plot_ocl_field(ocl_sensors.ocl_rad_par{q});
end
ylabel('PAR (\mumol m^{-2} s^{-1})');
ylim([0 max(ylim)]);
legend;

xlabel('Time');
linkaxes(f2ax,'x');

%%
figure('name',[' OCL wind ',num2str(daynumber,'%03d')])
orient tall

f3ax=subplot(2,1,1);
hold on;
for q=1:length(ocl_sensors.ocl_wind_rel_speed)
    plot_ocl_field(ocl_sensors.ocl_wind_rel_speed{q});
end
ylabel('Wind speed (m/s)');

f3ax(2)=subplot(2,1,2);
hold on;
for q=1:length(ocl_sensors.ocl_wind_rel_dir)
    h=plot_ocl_field(ocl_sensors.ocl_wind_rel_dir{q});
    set(h,'ydata',mod(get(h,'ydata')+180,360)-180);
end
legend;
ylabel('Wind direction relative (^o)');
set(gca,'ylim',[-180 180],'ytick',-180:45:180);

xlabel('Time');
linkaxes(f3ax,'x');

end


function h=plot_ocl_field(ocl_info,varargin)

thetable=evalin('caller',ocl_info{1});
x=datetime(thetable.time, 'ConvertFrom', 'datenum');
y=thetable.(ocl_info{2});
if length(ocl_info)>6 && ~isempty(ocl_info{7})
    y=feval(ocl_info{7},y);
end
h=plot(x,y,varargin{:});
if length(ocl_info)>4 && ~isempty(ocl_info{5})
    set(h,'DisplayName',ocl_info{5});
else
    set(h,'DisplayName',ocl_info{3});
end
if length(ocl_info)>3 && ~isempty(ocl_info{4})
    ylabel(ocl_info{4});
end

end

