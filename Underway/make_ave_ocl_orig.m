set_underway_params

%% load data

for q=1:length(ocl_tables)
    load(fullfile('..','ocl',ocl_tables{q},[ocl_tables{q},'_all.mat']));
end

%% set up new structure

ocl_ave_1s=struct('time',floor(surfmet_gpxsm.time(1)):(1/3600/24):...
    ceil(surfmet_gpxsm.time(end))-(1/3600/24));
% nav_ave_1s.longitude=nan(size(nav_ave_1s.time));
% nav_ave_1s.latitude=nan(size(nav_ave_1s.time));
% nav_ave_1s.ve=nan(size(nav_ave_1s.time));
% nav_ave_1s.vn=nan(size(nav_ave_1s.time));
% nav_ave_1s.sog=nan(size(nav_ave_1s.time));
% nav_ave_1s.cog=nan(size(nav_ave_1s.time));
% nav_ave_1s.distrun=nan(size(nav_ave_1s.time));
% nav_ave_1s.heading=nan(size(nav_ave_1s.time));

%% map Surfmet data onto 1-s bins

surfmet_data=interp1(surfmet_gpxsm.time',[surfmet_gpxsm.time,...
    surfmet_gpxsm.flow1,...
    surfmet_gpxsm.tempdk,...
    surfmet_gpxsm.fluo,...
    surfmet_gpxsm.trans,...
    surfmet_gpxsm.windspeed,...
    surfmet_gpxsm.winddirection,...
    surfmet_gpxsm.airtemperature,...
    surfmet_gpxsm.humidity,...
    surfmet_gpxsm.airpressure,...
    surfmet_gpxsm.parport,...
    surfmet_gpxsm.parstarboard,...
    surfmet_gpxsm.tirport,...
    surfmet_gpxsm.tirstarboard,...
    ],ocl_ave_1s.time,'nearest');

% lat_temp=surfmet_data(:,3);
% lon_temp=surfmet_data(:,2);
% first_ind=find(~isnan(lat_temp),1);
% lat_temp(1:first_ind)=lat_temp(first_ind);
% lon_temp(1:first_ind)=lon_temp(first_ind);
% distrun_temp=[0;cumsum(sw_dist(lat_temp,lon_temp,'km'))];

tsg_flow_mask=fillmissing(surfmet_data(:,2),'linear')<0.75;

    % remove anything that has been interpolated
surfmet_ind=find(abs(surfmet_data(:,1)-ocl_ave_1s.time')>.5/3600/24); 
surfmet_data(surfmet_ind,:)=nan;
ocl_ave_1s.flow=surfmet_data(:,2)';
ocl_ave_1s.temp_dropkeel=surfmet_data(:,3)';
ocl_ave_1s.fluor=16.2*(surfmet_data(:,4)'-0.060);
ocl_ave_1s.trans=100*(surfmet_data(:,5)'-0.004)./(4.700-0.004);
ocl_ave_1s.windspeed_rel=surfmet_data(:,6)';
ocl_ave_1s.winddir_rel=surfmet_data(:,7)';
ocl_ave_1s.airtemp=surfmet_data(:,8)';
ocl_ave_1s.humidity=surfmet_data(:,9)';
ocl_ave_1s.airpressure=surfmet_data(:,10)';
ocl_ave_1s.parport=surfmet_data(:,11)'.*10./8.937; % sn 28561 7/9/2022;
ocl_ave_1s.parstarboard=surfmet_data(:,12)'.*10./9.944; % sn 28558 7/9/2022;
ocl_ave_1s.tirport=surfmet_data(:,13)'.*10./11.81; % sn 161658 6/4/2021
ocl_ave_1s.tirstarboard=surfmet_data(:,14)'.*10./10.09; % sn 962276 18/8/2021

clear surfmet_data surfmet_ind

%% map SBE45 data onto 1-s bins

sbe45_data=interp1(sbe45_nanan.time',[sbe45_nanan.time,...
    sbe45_nanan.housingwatertemperature,...
    sbe45_nanan.conductivity,...
    sbe45_nanan.salinity,...
    sbe45_nanan.soundvelocity,...
    sbe45_nanan.remotewatertemperature],ocl_ave_1s.time,'nearest');

    % remove anything that has been interpolated
sbe45_ind=find(abs(sbe45_data(:,1)-ocl_ave_1s.time')>.5/3600/24); 
sbe45_data(sbe45_ind,:)=nan;
ocl_ave_1s.temp_cell=sbe45_data(:,2)';
ocl_ave_1s.cond=sbe45_data(:,3)';
ocl_ave_1s.salin=sbe45_data(:,4)';
ocl_ave_1s.svel=sbe45_data(:,5)';
ocl_ave_1s.temp_pumproom=sbe45_data(:,6)';

clear sbe45_data sbe45_ind


ocl_ave_1s.fluor(tsg_flow_mask)=nan;
ocl_ave_1s.trans(tsg_flow_mask)=nan;
ocl_ave_1s.temp_cell(tsg_flow_mask)=nan;
ocl_ave_1s.cond(tsg_flow_mask)=nan;
ocl_ave_1s.salin(tsg_flow_mask)=nan;
ocl_ave_1s.svel(tsg_flow_mask)=nan;

save(fullfile('..',[cruisename,'_ocl_1s_ave.mat']),'-struct','ocl_ave_1s');

%% average 1-s data into 30-s averages

ocl_vars=fieldnames(ocl_ave_1s);
n30s=length(ocl_ave_1s.time)/30;

% simple averaging of most variables
for n=1:length(ocl_vars)
    ocl_ave_30s.(ocl_vars{n})=nanmean(reshape(ocl_ave_1s.(ocl_vars{n}),30,n30s));
end

% vector averaging for relative wind
[wind_rel_v_1s,wind_rel_u_1s]=pol2cart(ocl_ave_1s.winddir_rel.*pi./180,...
    ocl_ave_1s.windspeed_rel);
[ocl_ave_30s.winddir_rel,ocl_ave_30s.windspeed_rel]=cart2pol(...
    mean(reshape(wind_rel_v_1s,30,n30s)),mean(reshape(wind_rel_u_1s,30,n30s)));
ocl_ave_30s.winddir_rel=mod(ocl_ave_30s.winddir_rel.*180./pi,360);

% calculate true wind
nav_ave_30s=load(fullfile('..',[cruisename,'_nav',...
    nav_sensor_sets(nav_sensor_set_best).file_add,'_30s_ave.mat']));

[wind_rel_v,wind_rel_u]=pol2cart((ocl_ave_30s.winddir_rel+nav_ave_30s.heading+180).*pi./180,...
    ocl_ave_30s.windspeed_rel); % vector for which way the wind is blowing TO
ocl_ave_30s.wind_u_abs=wind_rel_u+nav_ave_30s.ve;
ocl_ave_30s.wind_v_abs=wind_rel_v+nav_ave_30s.vn;
[ocl_ave_30s.winddir_abs,ocl_ave_30s.windspeed_abs]=cart2pol(ocl_ave_30s.wind_v_abs,ocl_ave_30s.wind_u_abs);
ocl_ave_30s.winddir_abs=mod(ocl_ave_30s.winddir_abs.*180./pi+180,360); % direction the wind is blowing FROM

% figure;
% ax=subplot(5,1,1);
% plot(ocl_ave_30s.time,ocl_ave_30s.windspeed_rel,'k-');
% ylabel('Wind speed rel (m/s)')
% ax=subplot(5,1,2);
% plot(ocl_ave_30s.time,mod(ocl_ave_30s.winddir_rel+180,360)-180,'k-');
% hold on;
% plot(ocl_ave_1s.time,mod(ocl_ave_1s.winddir_rel+180,360)-180,'r-');
% set(gca,'ylim',[-180 180],'ytick',-180:45:180);
% ylabel('Wind dir rel (^o) - FROM')
% ax(2)=subplot(5,1,3);
% plot(nav_ave_30s.time,nav_ave_30s.heading,'k-',nav_ave_30s.time,nav_ave_30s.cog,'m');
% set(gca,'ylim',[0 360],'ytick',0:45:360);
% ylabel('Heading (^o)');
% ax(3)=subplot(5,1,4);
% plot(nav_ave_30s.time,nav_ave_30s.ve,'m',ocl_ave_30s.time,wind_rel_u,'r',...
%     ocl_ave_30s.time,ocl_ave_30s.wind_u_abs,'g');
% ylabel('u (m/s)');
% ax(4)=subplot(5,1,5);
% plot(nav_ave_30s.time,nav_ave_30s.vn,'m',ocl_ave_30s.time,wind_rel_v,'r',...
%     ocl_ave_30s.time,ocl_ave_30s.wind_v_abs,'g');
% ylabel('v (m/s)');
% linkaxes(ax,'x');

clear wind_rel_* ocl_vars n30s n

save(fullfile('..',[cruisename,'_ocl_30s_ave.mat']),'-struct','ocl_ave_30s');

%% plots

figure('name',[' OCL flow, temp, sal, fluo, trans'])
orient tall

f1ax=subplot(5,1,1);
plot(ocl_ave_30s.time,ocl_ave_30s.flow,'k-');
ylabel('Flow (L/min)');

f1ax(2)=subplot(5,1,2);
plot(ocl_ave_30s.time,ocl_ave_30s.temp_dropkeel,'k-');
ylabel('Water temperature (^oC)');
hold on;
plot(ocl_ave_30s.time,ocl_ave_30s.temp_pumproom,'c-');
plot(ocl_ave_30s.time,ocl_ave_30s.temp_cell,'m-');

f1ax(3)=subplot(5,1,3);
plot(ocl_ave_30s.time,ocl_ave_30s.salin,'k-');
ylabel('Salinity (psu)');

f1ax(4)=subplot(5,1,4);
plot(ocl_ave_30s.time,ocl_ave_30s.fluor,'k-'); % s/n WSCHL-1526 30/3/2022
ylabel('Fluorometer (\mug/l)');

f1ax(5)=subplot(5,1,5);
plot(ocl_ave_30s.time,ocl_ave_30s.trans,'k-'); % s/n CST-1852PR 23/3/2021
ylabel('Transmissometer (%)');

datetick;
set(f1ax(1:4),'xlim',xlim(f1ax(5)),'xtick',get(f1ax(5),'xtick'),'xticklabel','');
linkaxes(f1ax,'x');

%%
figure('name',[' OCL air temp, humid, press, rad'])
orient tall

f2ax=subplot(5,1,1);
plot(ocl_ave_30s.time,ocl_ave_30s.airtemp,'k-');
ylabel('Air temperature (^oC)');

f2ax(2)=subplot(5,1,2);
plot(ocl_ave_30s.time,ocl_ave_30s.humidity,'k-');
ylabel('Rel. humidity (%)');

f2ax(3)=subplot(5,1,3);
plot(ocl_ave_30s.time,ocl_ave_30s.airpressure,'k-');
ylabel('Air pressure (hPa)');

f2ax(4)=subplot(5,1,4:5);
plot(ocl_ave_30s.time,ocl_ave_30s.parport,'r-'); % sn 28561 7/9/2022
hold on;
plot(ocl_ave_30s.time,ocl_ave_30s.parstarboard,'g-'); % sn 28558 7/9/2022
plot(ocl_ave_30s.time,ocl_ave_30s.tirport,'r--'); % sn 161658 6/4/2021
plot(ocl_ave_30s.time,ocl_ave_30s.tirstarboard,'g--'); % sn 962276 18/8/2021
ylabel('Radiation (W/m^2)');

datetick('x');
set(f2ax(1:3),'xlim',xlim(f2ax(4)),'xtick',get(f2ax(4),'xtick'),'xticklabel','');
linkaxes(f2ax,'x');

%%
figure('name',[' OCL wind '])
orient tall

f3ax=subplot(3,1,1);
plot(ocl_ave_30s.time,ocl_ave_30s.windspeed_abs,'k-');
ylabel('Wind speed (m/s)');

f3ax(2)=subplot(3,1,2);
plot(ocl_ave_30s.time,ocl_ave_30s.winddir_abs,'k-');
ylabel('Wind direction absolute (^o)');
set(gca,'ylim',[0 360],'ytick',0:45:360);

f3ax(3)=subplot(3,1,3);
plot(ocl_ave_30s.time,ocl_ave_30s.wind_u_abs,'k-');
hold on;
plot(ocl_ave_30s.time,ocl_ave_30s.wind_v_abs,'r-');
ylabel('Wind u (black) & v (red) (m/s)')

%datetick('x');
set(f3ax(1:2),'xlim',xlim(f3ax(3)),'xtick',get(f3ax(3),'xtick'),'xticklabel','');
linkaxes(f3ax,'x');
