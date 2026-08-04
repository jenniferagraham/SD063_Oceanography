%Hovmoller plots

close all; clear all;
addpath('../../matlabF/')

disk = ['L:\work\scientific_work_areas\oceanography\'];
Tdisk = ['P:\SD063\']; % JG T-drive
%Tdisk = ['T:\SD063\'];
ctddata = [disk,'CTD\BASproc\'];
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%Option to zoom axes in on the ice front section yoyo:
yoyo_zoom=1;

%figure;
if yoyo_zoom
figure('Position', [100, 100, 800, 600])
else
 figure('Position', [10, 100, 1250, 600])
end

sectionfilename='repeat_3m_icefront'; % repeat_3msill[n or peak]
P = sdaSectionParams(sectionfilename);

ncasts = length(P.sectionlist);

blueScale = abyss(3);
orangeScale = autumn(ncasts);
grey  = [0.55 0.55 0.55];

grid=NaN(ncasts,3500);

ctd_time=NaT(1,ncasts);
CTempS=NaN(size(grid,2),ncasts);
asalinS=NaN(size(grid,2),ncasts);
pressS=NaN(size(grid,2),ncasts);


for ii=1:ncasts
    ctd_time(ii)=datetime(ctds(P.sectionlist(ii)).gtime);
    CTempS(:,ii)=ctds(P.sectionlist(ii)).Ctemp;
    asalinS(:,ii)=ctds(P.sectionlist(ii)).asalin;
    pressS(:,ii)=ctds(P.sectionlist(ii)).press;
end

x = 1:ncasts;
x = datenum(ctd_time);

ha=tight_subplot(3,1,[0.015 0.01], [0.11 0.05], [0.08 0.05]);


%figure;
%subplot(3,1,3)
axes(ha(3))
%plot tidal cycle:
addpath(fullfile(Tdisk,'TMD3.0')) 

yyaxis left

%ax1 = subplot(3,1,3);
t = datetime('15-Jul-2026'):hours(1):datetime('22-Aug-2026');
z = tmd_predict(fullfile(Tdisk,'Gr1kmTM/data/Gr1kmTM_v1.nc'),68.2796,-30.7665,t);
plot(datenum(t), z);
ylabel('tide height (m)')
%take derivative of z:
lowering_tide_prediction=-diff(z)/datenum(t(2)-t(1));
time_at_deriv=t(:)+(t(2)-t(1))/2;
plot(datenum(time_at_deriv(1:end-1)), lowering_tide_prediction);
ylabel('lowering tide prediction (m/h)')
grid on
box on
hold on

% tidal day markers
xline(datenum(datetime(2026,7,15)+days(0:40)), 'k--')

% set limits in datenum
xlim([datenum(t(1)), datenum(t(end))])
datetick('x','dd-mmm HH:MM','keeplimits')


%Make array the length of tidal time, and the depth of pressure:
t30=t(1):minutes(30):t(end);
CTemp_array=NaN(size(CTempS,1),length(t30));
press_array=repmat(pressS(:,1),1,length(t30));
x_t30 = datenum(t30);
%Now search for nearest time to match the time of the CTD profile, for each
%profile:
closestTime=NaT(size(ctd_time));
for ii=1:ncasts
    [~, idx] = min(abs(t30 - ctd_time(ii)));
    closestTime(ii) = t30(idx)
    CTemp_array(:,idx)=CTempS(:,ii);
    CTemp_array(:,idx-1)=CTempS(:,ii);
end

%or do with adding start time and end time:
%interval in minutes:
ctd_time_interval=30;
ctd_time_start= ctd_time - minutes(ctd_time_interval);
ctd_time_end=ctd_time + minutes(ctd_time_interval);

x_start=datenum(ctd_time_start);
x_end=datenum(ctd_time_end);

x_interval=NaN(1,2*ncasts);
CTempS_padded=NaN(size(CTempS,1),2*ncasts);

for ii=1:ncasts 
 x_interval(1,2*ii-1)=x_start(ii);
 x_interval(1,2*ii)=x_end(ii);
CTempS_padded(:,2*ii-1)=CTempS(:,ii);
end

%ax2=subplot(3,1,1)
axes(ha(1))
%pcolor(x, pressS(:,1), CTempS)
pcolor(x_interval, pressS(:,1), CTempS_padded);
%pcolor(x_t30, press_array, CTemp_array);
shading flat
set(gca,'YDir','reverse')
ax = gca;
ax.XTick = x_t30;

datetick('x','dd-mmm HH:MM','keepticks');
ha(1).XTickLabel = {};
ha(1).XTick={}

xtickangle(45)
%xlabel('Time');
ylabel('Depth (m)');
    cmocean('thermal')
hcb=colorbar;
caxis([-1.5 1.5]);
hcb.Label.String= 'CT (\circC)'; 
hcb.Location='west'
title(P.sectionname)

%Now plot anomolies
%Calculate average from 10 casts at every pressure level:
% Mean profile over all casts
CTemp_mean = mean(CTempS, 2, 'omitnan');
CTemp_std = std(CTempS,0,2,'omitnan');

% Rosie - finding the max standard deviation of the mean temp. It's at
% depth 125m for this case.
%figure; plot(CTemp_mean,pressS(:,1)); set(gca,'YDir','reverse')
%hold on
%plot(CTemp_std,pressS(:,1)); set(gca,'YDir','reverse')

% Temperature anomaly
CTemp_anom = CTempS - CTemp_mean;
CTemp_padded_anom = CTempS_padded - CTemp_mean;


%Extract temps at this depth for each cast:
chosen_press=125.0;
press_bin_size=2.0;
binID=round(chosen_press/press_bin_size);
chosen_CTemp=CTempS(binID,:);

axes(ha(3))
yyaxis right
plot(x,chosen_CTemp,'r*');
ylabel('CT anomoly at 125 m');
ylim([-0.8  0.0])

%figure;
%axes(2)=subplot(3,1,2)
axes(ha(2))
%pcolor(x, pressS(:,1), CTemp_anom)
pcolor(x_interval, pressS(:,1), CTemp_padded_anom)
shading flat
set(gca,'YDir','reverse')

xticks(x)
xticklabels(datestr(ctd_time,'dd-mmm HH:MM'))
xtickangle(45)

ha(2).XTickLabel = {};
%xlabel('Time');
ylabel('Depth (m)');
cmocean('balance');
hcb=colorbar;
cmax = max(abs(CTemp_anom(:)), [], 'omitnan');
clim([-cmax cmax]);
caxis([-1.0 1.0]);
hcb.Label.String= 'CT (\circC)'; 
hcb.Location='west'
%title(P.sectionname);

linkaxes(findall(gcf,'Type','axes'),'x');
%linkaxes([ha],'x')

% Put ticks at every CTD cast time
ha(3).XTick = x;
datetick(ha(3),'x','dd-mmm HH:MM','keepticks');
xtickangle(ha(3),45);
ha(3).FontSize=8;


for n=1:3
    %subplot(3,1,n)
    axes(ha(n))
    % Set x limits to CTD cast time range

    if yoyo_zoom
    xlim([datenum(ctd_time_start(4)-minutes(60)) datenum(ctd_time_end(end)+minutes(60))]);
    else
    xlim([datenum(ctd_time_start(1)-minutes(500)) datenum(ctd_time_end(end)+minutes(60))]);
    end
end

 set(gcf, 'Color', 'w')

 if yoyo_zoom
name = sprintf('_Hovmoller_anomolies_%s_full.png', sectionfilename);
 else
     name = sprintf('_Hovmoller_anomolies_%s.png', sectionfilename);
 end
   
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
