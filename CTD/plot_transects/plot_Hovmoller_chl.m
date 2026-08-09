%Hovmoller plots

close all; clear all;
cruise='SD063';


%% add paths
if ispc
addpath('../../matlabF/')

disk = ['L:\work\scientific_work_areas\oceanography\'];
Tdisk = ['P:\SD063\']; % JG T-drive
%Tdisk = ['T:\SD063\'];
ctddata = [disk,'CTD\BASproc\'];
 figP = [disk,'Figures\BIO\Hovmoller\'];

elseif ismac
    disk = '/Volumes/legwork/scientific_work_areas/oceanography/';
    addpath('/Volumes/legwork/scientific_work_areas/oceanography/matlabF/')

    Tdisk = ['/Volumes/Scratch/SD063/']; % JG T-drive
    ctddata = [disk,'CTD/BASproc/'];
    figP = [disk,'CTD/plot_transects/Figures/BIO/hovmoller/'];
end

%% load the data 
load([ctddata,cruise,'_ctd.mat']);
varname1='fluor_ug_l'; varunit1 = 'ug_l'; varcaxis1 = [0 1];
varname2='oxygen_umol_kg';varunit2 = 'umol_kg';varcaxis2 = [300 360];

%%
%Option to zoom axes in on the ice front section yoyo:

%sectionfilename='repeat_3m_icefront'; yoyo_zoom=1;
sectionfilename ='repeat_3msillpeak';yoyo_zoom=0;
%sectionfilename ='repeat_3msilln'; yoyo_zoom=0;
%%
%figure;
if yoyo_zoom
figure('Position', [100, 100, 800, 600])
else
 figure('Position', [10, 100, 1250, 600])
end

P = sdaSectionParams(sectionfilename);

ncasts = length(P.sectionlist);

blueScale = abyss(3);
orangeScale = autumn(ncasts);
grey  = [0.55 0.55 0.55];

grid=NaN(ncasts,3500);

ctd_time=NaT(1,ncasts);
myVAR1=NaN(size(grid,2),ncasts);
myVAR2=NaN(size(grid,2),ncasts);
pressS=NaN(size(grid,2),ncasts);


for ii=1:ncasts
    ctd_time(ii)=datetime(ctds(P.sectionlist(ii)).gtime);
    eval(['myVAR1(:,',num2str(ii),')=ctds(P.sectionlist(',num2str(ii),')).',varname1,';']);
    eval(['myVAR2(:,',num2str(ii),')=ctds(P.sectionlist(',num2str(ii),')).',varname2,';']);
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
%grid on
box on
hold on

% tidal day markers
xline(datenum(datetime(2026,7,15)+days(0:40)), 'k--')

% set limits in datenum
xlim([datenum(t(1)), datenum(t(end))])
datetick('x','dd-mmm HH:MM','keeplimits')


%Make array the length of tidal time, and the depth of pressure:
t30=t(1):minutes(30):t(end);
myVAR_array=NaN(size(myVAR1,1),length(t30));
press_array=repmat(pressS(:,1),1,length(t30));
x_t30 = datenum(t30);
%Now search for nearest time to match the time of the CTD profile, for each
%profile:
closestTime=NaT(size(ctd_time));
for ii=1:ncasts
    [~, idx] = min(abs(t30 - ctd_time(ii)));
    closestTime(ii) = t30(idx);
    myVAR_array(:,idx)=myVAR1(:,ii);
    myVAR_array(:,idx-1)=myVAR1(:,ii);
end

%or do with adding start time and end time:
%interval in minutes:
ctd_time_interval=30;
ctd_time_start= ctd_time - minutes(ctd_time_interval);
ctd_time_end=ctd_time + minutes(ctd_time_interval);

x_start=datenum(ctd_time_start);
x_end=datenum(ctd_time_end);

x_interval=NaN(1,2*ncasts);
myVAR1_padded=NaN(size(myVAR1,1),2*ncasts);

for ii=1:ncasts
    x_interval(1,2*ii-1)=x_start(ii);
    x_interval(1,2*ii)=x_end(ii);
    myVAR1_padded(:,2*ii-1)=myVAR1(:,ii);
end

%ax2=subplot(3,1,1)
axes(ha(1))
pcolor(x_interval, pressS(:,1), myVAR1_padded);
shading flat
set(gca,'YDir','reverse')
ax = gca;
ax.XTick = x_t30;
if strcmp(varname1,'fluor_ug_l'); ax.YLim = [0 100]; end;
datetick('x','dd-mmm HH:MM','keepticks');
ha(1).XTickLabel = {};
ha(1).XTick={}

xtickangle(45)
%xlabel('Time');
ylabel('Depth (m)');
cmocean('algae')
hcb=colorbar;
caxis(varcaxis1);
hcb.Label.String= strrep(varname1,'_',' '); 
hcb.Location='northoutside';
title(P.sectionname)

%Now plot anomolies
%Calculate average from 10 casts at every pressure level:
% Mean profile over all casts
myVAR1_mean = mean(myVAR1, 2, 'omitnan');
myVAR1_std = std(myVAR1,0,2,'omitnan');

 % Anomaly
myVAR1_anom = myVAR1 - myVAR1_mean;
myVAR1_padded_anom = myVAR1_padded - myVAR1_mean;
%%%%%%%%%% will not include in bio %%%%%%%%%%%%%%%
% Rosie - finding the max standard deviation of the mean temp. It's at
% depth 125m for this case.
%figure; plot(CTemp_mean,pressS(:,1)); set(gca,'YDir','reverse')
%hold on
%plot(CTemp_std,pressS(:,1)); set(gca,'YDir','reverse')

% %Extract temps at this depth for each cast:
% % chosen_press=125.0;
% % press_bin_size=2.0;
% % binID=round(chosen_press/press_bin_size);
% % chosen_myVAR1=myVAR1(binID,:);
% % 
% % axes(ha(3))
% % yyaxis right
% % plot(x,chosen_myVAR1,'r*');
% % ylabel([strrep(varname1,'_',' '),' anomoly at 125 m']);
% % ylim([-0.8  0.0])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure;
%axes(2)=subplot(3,1,2)
axes(ha(2))
pcolor(x_interval, pressS(:,1), myVAR1_padded_anom)
shading flat
set(gca,'YDir','reverse')
ax = gca;
ax.XTick = x_t30;
if strcmp(varname1,'fluor_ug_l'); ax.YLim = [0 100]; end;
xticks(x)
xticklabels(datestr(ctd_time,'dd-mmm HH:MM'))
xtickangle(45)

ha(2).XTickLabel = {};
%xlabel('Time');
ylabel('Depth (m)');
cmocean('balance');
hcb=colorbar;
cmax = max(abs(myVAR1_anom(:)), [], 'omitnan');
clim([-cmax cmax]);
caxis([-0.5 0.5]);
hcb.Label.String= strrep(varunit1,'_','/'); 
hcb.Location='northoutside'
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
     figname = sprintf('_Hovmoller_%s_anomolies_%s_full.png', varname1, sectionfilename);
 else
     figname = sprintf('_Hovmoller_%s_anomolies_%s_.png', varname1,sectionfilename);
 end
   
exportgraphics(gcf, [figP, cruise, figname], 'Resolution', 300)
