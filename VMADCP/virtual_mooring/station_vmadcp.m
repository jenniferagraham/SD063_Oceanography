%
% code to make a virtual mooring from the SDA VMADCP data
%
% Paul Holland SD063 10/8/26
%

%close all
clear all

%
% choose location
%
tdrive=input('What letter is your temp drive, e.g., T or P?\n','s');
tidefile=sprintf('%s:/SD063/Gr1kmTM/data/Gr1kmTM_v1.nc',...
    upper(tdrive));
addpath(sprintf('%s:/SD063/TMD3.0',upper(tdrive)))

addpath('L:\work\scientific_work_areas\oceanography\CTD\plot_transects')

sitenames={'repeat_3micefront','repeat_3micefrontsouthyoyoonly', ...
           'repeat_3mwestsill','repeat_3msillnorthpeak','repeat_3meastsill', ...
           'repeat_3mmouth','repeat_3mbeak', ...
          };

sitenames={'repeat_3micefrontsouthyoyoonly'};

absplotscal=0.05;
anmplotscal=0.05;

% +++++++++++++++++++++++++++++++++
% start main loop over repeat sites
% +++++++++++++++++++++++++++++++++

for s=1:length(sitenames)

sitename=sitenames{s}
    
P=sdaSectionParams(sitename);
stations=P.sectionlist;

% ---------
% read data
% ---------

directory='L:/system/adcp_teledyne_ocean_surveyor/acquisition/uhdas/data/SD063_part2/proc/';

SADCPos150bb.u=load(strcat(directory,'os150bb/contour/allbins_u.mat'));
SADCPos150bb.v=load(strcat(directory,'os150bb/contour/allbins_v.mat'));
SADCPos150bb.w=load(strcat(directory,'os150bb/contour/allbins_w.mat'));
SADCPos150bb.depth=load(strcat(directory,'os150bb/contour/allbins_depth.mat'));
SADCPos150bb.other=load(strcat(directory,'os150bb/contour/allbins_other.mat'));

SADCPos150bb.theU=SADCPos150bb.u.U+repmat(SADCPos150bb.u.U_SHIP,[size(SADCPos150bb.u.U,1),1]);
SADCPos150bb.theV=SADCPos150bb.v.V+repmat(SADCPos150bb.v.V_SHIP,[size(SADCPos150bb.u.U,1),1]);
SADCPos150bb.theLON=SADCPos150bb.other.LON_END-360;
SADCPos150bb.theLAT=SADCPos150bb.other.LAT_END;
SADCPos150bb.theDEPTH=SADCPos150bb.depth.DEPTH;
SADCPos150bb.theTIME=SADCPos150bb.other.DAYS+datenum(2026,1,1,0,0,0);

vmadcp.datenum=SADCPos150bb.theTIME;
vmadcp.datetime=datetime(SADCPos150bb.theTIME,'ConvertFrom','datenum');
vmadcp.lat=SADCPos150bb.theLAT;
vmadcp.lon=SADCPos150bb.theLON;
vmadcp.depth=SADCPos150bb.theDEPTH;
vmadcp.u=SADCPos150bb.theU;
vmadcp.v=SADCPos150bb.theV;

% -------------------------------------
% select times of interesting CTD casts
% -------------------------------------

load('L:\work\scientific_work_areas\oceanography\CTD\BASproc\SD063_ctd');

nc=length(ctds);
ctd.number=zeros(nc,1);
ctd.starttime=datetime(zeros(nc,1),0,0);
ctd.startnum=zeros(nc,1);
ctd.tidephase=zeros(nc,1);
for c=1:nc
  ctd.number(c)=ctds(c).station;
  ctd.starttime(c)=datetime(ctds(c).gtime);
  ctd.startnum(c)=datenum(ctds(c).gtime);
  ctd.tidephase(c)=ctds(c).tide_phase_fraction;
end

ni=length(stations);
ind=zeros(size(stations));
for c=1:ni
  ind(c)=find(ctd.number==stations(c));
end
ctd.number=ctd.number(ind);
ctd.starttime=ctd.starttime(ind);
ctd.startnum=ctd.startnum(ind);
ctd.tidephase=ctd.tidephase(ind);

ctd.tidephasequadrant=zeros(nc,1);
valid=find((ctd.tidephase<0.125)|(ctd.tidephase>=0.875));
ctd.tidephasequadrant(valid)=1;
valid=find((ctd.tidephase>=0.125)&(ctd.tidephase<0.375));
ctd.tidephasequadrant(valid)=2;
valid=find((ctd.tidephase>=0.375)&(ctd.tidephase<0.625));
ctd.tidephasequadrant(valid)=3;
valid=find((ctd.tidephase>=0.625)&(ctd.tidephase<0.875));
ctd.tidephasequadrant(valid)=4;

% ---------------------------
% snip out relevant ADCP data
% ---------------------------

ctd.depth=-vmadcp.depth(:,1);

disp('WARNING: selecting 20 minutes of data from the cast start time')
disp('- you should probably revisit time selection')
windowminutes=20;

ctd.endtime=ctd.starttime+minutes(windowminutes);
ctd.endnum=zeros(size(ctd.startnum));
for c=1:ni
  ctd.endnum(c)=addtodate(ctd.startnum(c),windowminutes,'minute');
end

ctd.u=zeros(size(vmadcp.depth,1),length(ctd.number));
ctd.v=zeros(size(vmadcp.depth,1),length(ctd.number));
for c=1:ni
  valid=find((vmadcp.datenum>=ctd.startnum(c))&(vmadcp.datenum<=ctd.endnum(c)));
  if isempty(valid)
     disp(strcat('WARNING: no data found for cast:',num2str(ctd.number(c))))
     ctd.u(:,c)=NaN;
     ctd.v(:,c)=NaN;
  else
    ctd.u(:,c)=nanmean(vmadcp.u(:,valid),2);
    ctd.v(:,c)=nanmean(vmadcp.v(:,valid),2);
  end
end

ctd.u=ctd.u';
ctd.v=ctd.v';

%
% make vertical means
% 

depthcutoff=75;

valid=find(ctd.depth>=-depthcutoff);
ctd.utopmean=nanmean(ctd.u(:,valid),2);
ctd.vtopmean=nanmean(ctd.v(:,valid),2);

valid=find(ctd.depth<-depthcutoff);
ctd.ubotmean=nanmean(ctd.u(:,valid),2);
ctd.vbotmean=nanmean(ctd.v(:,valid),2);

% ----------------------
% get tidal height model
% ----------------------

tide.times=datetime('jul 25, 2026'):minutes(1):datetime('aug 29, 2026');
%tide.times=datetime('aug 7, 2026'):hours(1):datetime('aug 9, 2026');

tide.height=tmd_predict(tidefile,68.2796,-30.7665,tide.times);

ctd.tideheight=tmd_predict(tidefile,68.2796,-30.7665,ctd.starttime);

% ------------------------------------
% plot hovmoller plots and time series
% ------------------------------------

%
% build hovmoller arrays 
% one cell larger for pcolor
% twice as wide to cope with intermittent data by inserting NaN columns
%

ntimes=2*size(ctd.u,1)+1;
ndepths=size(ctd.u,2)+1;
template=NaN*zeros(ntimes,ndepths);
plottime=datetime(template,0,0);
plotu=template;
plotv=template;

plotdepth=template;
for t=1:ntimes
  plotdepth(t,1:128)=ctd.depth;
end
depthbinsize=plotdepth(1,1)-plotdepth(1,2);
plotdepth(:,end)=plotdepth(:,end-1)-depthbinsize;

for c=1:ni
  plottime(2*c-1,:)=ctd.starttime(c);
  plottime(2*c  ,:)=ctd.endtime(c);
  plottime(2*c-1,:)=ctd.starttime(c);
  plotu(2*c-1,1:128)=ctd.u(c,:);
  plotv(2*c-1,1:128)=ctd.v(c,:);
end
plottime(end,:)=plottime(end-1,:)+minutes(windowminutes);

%
% plot the figure
%
 
figure(1)
clf

colormap(jet)

subplot(3,1,1)

plot(tide.times,tide.height)
grid on
hold on
xlim([ctd.starttime(1) ctd.endtime(end)])
ylabel('height (m)')
ylim([-1.5 1.5])

plot([ctd.starttime(1) ctd.endtime(end)],[0 0],'k')

yyaxis right
plot(ctd.starttime+minutes(windowminutes/2),ctd.utopmean,'r*-')
plot(ctd.starttime+minutes(windowminutes/2),ctd.vtopmean,'g*-')
ylabel('upper velocity (m/s)')
title(strcat('U red mean:',num2str(nanmean(ctd.utopmean)),...
             '; V green mean:',num2str(nanmean(ctd.vtopmean))))
ylim([-0.05 0.05])

subplot(3,1,2)
pcolor(plottime,plotdepth,plotu)
shading flat
grid on
caxis(0.2*[-1,1])
xlim([ctd.starttime(1) ctd.endtime(end)])
ylim([-250 0])
colorbar('location','south')
title('U')

subplot(3,1,3)
pcolor(plottime,plotdepth,plotv)
shading flat
grid on
caxis(0.2*[-1,1])
xlim([ctd.starttime(1) ctd.endtime(end)])
ylim([-250 0])
colorbar('location','south')
title('V')

%
% print
%

figname=strcat('timeseries_',sitename,'.png');
%print('-dpng','-r200',figname);
exportgraphics(gcf,figname,'Resolution',300)


% -----------------
% make vector plots
% -----------------

figure(2)
clf

% %
% % make colour based on height of tide / time of station
% %
% 
% ncolours=100;
% cmap=jet(ncolours);
% 
% tiderange=max(abs(max(ctd.tideheight)),abs(min(ctd.tideheight)));
% tidestep=2*tiderange/(ncolours-1);
% tidebounds=[-tiderange:tidestep:tiderange];
% 
% timestep=(max(ctd.starttime)-min(ctd.starttime))/(ncolours-1);
% timebounds=[min(ctd.starttime):timestep:max(ctd.starttime)];
% 
% nc=length(ctd.number);
% cnumbertide=zeros(nc,1);
% cnumbertime=zeros(nc,1);
% for c=1:nc
%   [junk,ind]=min(ctd.tideheight(c)>tidebounds);
%   cnumbertide(c)=ind;
%   [junk,ind]=min(ctd.starttime(c)>timebounds);
%   cnumbertime(c)=ind;
% end

%
% make colour based on idealised tide phase
%

ncolours=100;
cmap=jet(ncolours);

tidestep=1/(ncolours-1);
tidebounds=[0:tidestep:1];

nc=length(ctd.number);
cnumbertide=zeros(nc,1);
for c=1:nc
  [junk,ind]=min(ctd.tidephase(c)>tidebounds);
  cnumbertide(c)=ind;
end

%
% plot upper velocities
%

subplot(2,2,1)
title('upper velocities - absolute')

hold on
for c=1:nc
  quiver(0,0,ctd.utopmean(c),ctd.vtopmean(c),...
            'Color',cmap(cnumbertide(c),:),'AutoScale','off','LineWidth',2)
end
axis equal
grid on
box on

% for c=1:nc
%     plot(ctd.utopmean(c),ctd.vtopmean(c),'o','Color',cmap(cnumbertide(c),:))
% end
set(gca,'XTick',[-absplotscal:absplotscal/2:absplotscal],...
        'YTick',[-absplotscal:absplotscal/2:absplotscal])
xlim([-absplotscal absplotscal])
ylim([-absplotscal absplotscal])

%
% plot upper anomalies
%

subplot(2,2,2)
title('upper velocities - anomalies')

utopmeanmean=nanmean(ctd.utopmean);
vtopmeanmean=nanmean(ctd.vtopmean);

hold on
for c=1:nc
    quiver(0,0,ctd.utopmean(c)-utopmeanmean,ctd.vtopmean(c)-vtopmeanmean,...
               'Color',cmap(cnumbertide(c),:),'AutoScale','off','LineWidth',2)
end
quiver(0,0,utopmeanmean,vtopmeanmean,'Color','k','LineWidth',2)
axis equal
grid on
box on

% for c=1:nc
%     plot(ctd.utopmean(c)-utopmeanmean,ctd.vtopmean(c)-vtopmeanmean,'o','Color',cmap(cnumbertide(c),:))
% end

plot(utopmeanmean,vtopmeanmean,'k')
set(gca,'XTick',[-anmplotscal:anmplotscal/2:anmplotscal],...
        'YTick',[-anmplotscal:anmplotscal/2:anmplotscal])
xlim([-anmplotscal anmplotscal])
ylim([-anmplotscal anmplotscal])

%
% plot lower velocities
%

subplot(2,2,3)
title('lower velocities - absolute')

hold on
for c=1:nc
    quiver(0,0,ctd.ubotmean(c),ctd.vbotmean(c),...
               'Color',cmap(cnumbertide(c),:),'AutoScale','off','LineWidth',2)
end
axis equal
grid on
box on

% for c=1:nc
%     plot(ctd.ubotmean(c),ctd.vbotmean(c),'o','Color',cmap(cnumbertide(c),:))
% end
set(gca,'XTick',[-absplotscal:absplotscal/2:absplotscal],...
        'YTick',[-absplotscal:absplotscal/2:absplotscal])
xlim([-absplotscal absplotscal])
ylim([-absplotscal absplotscal])

colormap(cmap)
cb=colorbar('south');
clim([0 1])
xlabel(cb,'idealised tide phase (0-1)')

%
% plot lower anomalies
%

subplot(2,2,4)
title('lower velocities - anomalies')

ubotmeanmean=nanmean(ctd.ubotmean);
vbotmeanmean=nanmean(ctd.vbotmean);

hold on
for c=1:nc
    quiver(0,0,ctd.ubotmean(c)-ubotmeanmean,ctd.vbotmean(c)-vbotmeanmean,...
               'Color',cmap(cnumbertide(c),:),'AutoScale','off','LineWidth',2)
end
quiver(0,0,ubotmeanmean,vbotmeanmean,'Color','k','LineWidth',2)
axis equal
grid on
box on

% for c=1:nc
%     plot(ctd.ubotmean(c)-ubotmeanmean,ctd.vbotmean(c)-vbotmeanmean,'o','Color',cmap(cnumbertide(c),:))
% end

plot(ubotmeanmean,vbotmeanmean,'k')
set(gca,'XTick',[-anmplotscal:anmplotscal:anmplotscal],...
        'YTick',[-anmplotscal:anmplotscal:anmplotscal])
xlim([-anmplotscal anmplotscal])
ylim([-anmplotscal anmplotscal])

%
% print
%

figname=strcat('vector_',sitename,'.png');
exportgraphics(gcf,figname,'Resolution',300)

% +++++++++++++++++++++++++++++++
% end main loop over repeat sites
% +++++++++++++++++++++++++++++++

end
