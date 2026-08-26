%PLOT_AVE_OCL Plot averaged underway data

%   version 1.0 - 20240813 - Povl Abrahamsen, SD041 - separated from
%       MAKE_AVE_OCL, fixed plotting multiple wind sensors

%% load data
set_underway_params

% Define the file paths
cleaned_file = fullfile('..', [cruisename, '_ocl_30s_ave_clean.mat']);
original_file = fullfile('..', [cruisename, '_ocl_30s_ave.mat']);

% Check if the cleaned file exists
if exist(cleaned_file, 'file') == 2
    ocl_ave_30s = load(cleaned_file); % Load cleaned data
    disp('Using cleaned ocl_30s_ave file');
else
    ocl_ave_30s = load(original_file); % Load original data
    disp('Using original ocl_30s_ave file, with no cleaning applied');
end
%ocl_ave_30s=load(fullfile('..',[cruisename,'_ocl_30s_ave_clean.mat'])); %uses cleaned data


%% plot water graphs

figure('name',[' OCL flow, temp, sal, fluo, trans'])
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

datetick('x','dd mmm');
if (median(diff(get(gca,'xtick')))==7)
    set(gca,'XMinorTick',6); % add daily ticks between weekly labels
end
set(f1ax(1:4),'xlim',xlim(f1ax(5)),'xtick',get(f1ax(5),'xtick'),'xticklabel','');
linkaxes(f1ax,'x');


%% plot air graphs

figure('name',[' OCL air temp, humid, press, rad'])
orient tall

f2ax=subplot(5,1,1);
for q=1:length(ocl_sensors.ocl_air_temp)
    plot_ocl_field(ocl_sensors.ocl_air_temp{q});
end
ylabel('Air temperature (^oC)');

f2ax(2)=subplot(5,1,2);
hold on;
for q=1:length(ocl_sensors.ocl_air_rel_hum)
    plot_ocl_field(ocl_sensors.ocl_air_rel_hum{q});
end
ylabel('Rel. humidity (%)');

f2ax(3)=subplot(5,1,3);
hold on;
for q=1:length(ocl_sensors.ocl_air_pressure)
    plot_ocl_field(ocl_sensors.ocl_air_pressure{q});
end
ylabel('Air pressure (hPa)');

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

datetick('x','dd mmm');
if (median(diff(get(gca,'xtick')))==7)
    set(gca,'XMinorTick',6); % add daily ticks between weekly labels
end
set(f2ax(1:3),'xlim',xlim(f2ax(4)),'xtick',get(f2ax(4),'xtick'),'xticklabel','');
linkaxes(f2ax,'x');

%% plot wind graphs

figure('name',[' OCL wind '])
orient tall

f3ax=subplot(4,1,1);
hold on;
for n=1:length(ocl_true_wind_names)
    plot(ocl_ave_30s.time,ocl_ave_30s.(ocl_true_wind_names{n}{1}));
end
ylabel('Wind speed (knots)');

f3ax(2)=subplot(4,1,2);
hold on;
for n=1:length(ocl_true_wind_names)
    plot(ocl_ave_30s.time,ocl_ave_30s.(ocl_true_wind_names{n}{2}));
end
ylabel('Wind direction absolute (^o)');
set(gca,'ylim',[0 360],'ytick',0:45:360);

clear h
f3ax(3)=subplot(4,1,3);
hold on;
for n=1:length(ocl_true_wind_names)
    h(n)=plot(ocl_ave_30s.time,ocl_ave_30s.(ocl_true_wind_names{n}{3}));
end
ylabel('Wind u (knots)')
if length(ocl_true_wind_names)>1
    wind_names=cell(size(ocl_true_wind_names));
    for n=1:length(ocl_true_wind_names)
        wind_name_components=strsplit(ocl_true_wind_names{n}{1},'_');
        wind_names{n}=wind_name_components{end};
    end
    legend(h,wind_names{:});
end

f3ax(4)=subplot(4,1,4);
hold on;
for n=1:length(ocl_true_wind_names)
    plot(ocl_ave_30s.time,ocl_ave_30s.(ocl_true_wind_names{n}{4}));
end
ylabel('Wind v (knots)')

datetick('x','dd mmm');
if (median(diff(get(gca,'xtick')))==7)
    set(gca,'XMinorTick',6); % add daily ticks between weekly labels
end
set(f3ax(1:3),'xlim',xlim(f3ax(4)),'xtick',get(f3ax(4),'xtick'),'xticklabel','');
linkaxes(f3ax,'x');

figure;
WindRose(ocl_ave_30s.(ocl_true_wind_names{n}{1}),ocl_ave_30s.(ocl_true_wind_names{n}{2}))
function h=plot_ocl_field(ocl_info,varargin)

x=evalin('caller','ocl_ave_30s.time');
y=evalin('caller',['ocl_ave_30s.',ocl_info{3}]);
h=plot(x,y,varargin{:});
if length(ocl_info)>4 && ~isempty(ocl_info{5})
    set(h,'DisplayName',ocl_info{5});
else
    set(h,'DisplayName',ocl_info{3});
end

end