%% created by Laura C (SAMS) uses an updated of Povl's original plot sd sections that were used for the cruise report 
%% modified by CTD team SD 063
clear all; 
close all;
clc
%% add paths for GSW and where to save figures 

here=pwd;
if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    figPb   = [disk,'\CTD\plot_transects\Figures\'];
    ctddata = [disk,'CTD\BASproc\'];
    ctddata_old = [disk,'\Notes\PreviousDataProcessing\KANGGLAC_CTD_data\'];
    gridpath= 'L:\work\scientific_work_areas\gis\bathymetry_grids\';

    addpath([disk,'matlabF\']) % theta_sdiag function
    addpath([disk,'matlabF\m_map\'])
    addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    FZ=12;
elseif ismac
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    figPb   = [disk,'CTD/plot_transects/Figures/'];
    ctddata = [disk,'CTD/BASproc/'];
    addpath([disk,'matlabF/']) % theta_sdiag function
    addpath([disk,'matlabF/m_map/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])

    FZ=12;
end
set(0, 'DefaultAxesFontSize', FZ);

sectionfilenames={'Ssection','Ssectionwarm',...
    'melangetroughentrance','melangetroughalong','melangetroughnorth',...
    'magictrough','kgtrough-1','kgtrough-2',...
    'deception_trough','deceptionloop-1','deceptionloop-2',...
    'kangglac_deceptionloop','kangglac_alongtrough','kangglac_kgtrough','kangglac_flado',...
    'skag_kgtrough-1','skag_kgtrough-2',...
    '3mtransect','3micefronttowyo','3mhead','3mdoubletrough','3msill','3mthroat','3mmouthsection',...
    '3mbeak-1','3mbeak-2','3mbeaksouth-1','3mbeaksouth-2','3macrosssill-1','3macrosssill-2','3macrosssillsouthdogleg' ...
    };

%sectionfilenames={'kangglac_kgtrough'};
%sectionfilenames={'skag_kgtrough-1','skag_kgtrough-2'};
%sectionfilenames={'kgtrough-1','kgtrough-2','kgtrough-3'};
%sectionfilenames={'kangglac_kgtroughouter'};

%sectionfilenames={'melangetroughalong-1','melangetroughalong-2'};
sectionfilenames={'kgtrough-3'};

%cruise='SD041';
%cruise='SK2514';
cruise='SD063';

if strcmp(cruise,'SD063')
   load([ctddata,cruise,'_ctd.mat']);
elseif strcmp(cruise,'SK2514')
   load([ctddata_old,cruise,'_edited_ctd.mat']);
elseif strcmp(cruise,'SD041')
   load([ctddata_old,cruise,'_edited_ctd.mat']);
else
   error("no section lists for that cruise, sorry!")
end

anomalyplot=0;
%anomalyplot=1;

maxy=1000; % depth 
% definition of colours you may need to fix 
ercolor = [.5 1 1]; % bright blue
skcolor2025 = [.5 .5 1]; % purple
sdcolor = [.5 .5 .5]; % grey
%sdcolor2026 = [1 .5 .5]; % grey
seccolor= [1 .0 .0]; % red

% load CTDs
% load([ctddata,cruise,'_ctd.mat']);
for n=1:length(ctds)
    ctds(n).asal=gsw_SA_from_SP(ctds(n).salin,ctds(n).press,ctds(n).lon,ctds(n).lat);
    ctds(n).ct=gsw_CT_from_t(ctds(n).asal,ctds(n).temp,ctds(n).press);
end
sd_ctds=ctds;

%% load bathymetry
load mb_all_20250512.mat
bedmachine.z = ncread('BedMachine-v5_crop.nc', 'z');
y = ncread('BedMachine-v5_crop.nc', 'y');
x = ncread('BedMachine-v5_crop.nc', 'x');
[bedmachine.y, bedmachine.x] = meshgrid(y,x);
% [bedmachine.x,bedmachine.y,bedmachine.z]=load_grd('BedMachine-v5_crop.nc');
% gdalwarp -t_srs EPSG:32625 -te 455485.319 7375979.375 655685.319 7658379.375 -tr 100 100 BedMachineGreenland-v5_bed.tif BedMachine-v5_crop.nc
% ncrename -v Band1,z BedMachine-v5_crop.nc
%Aattempt to read bathymetric Read the GeoTIFF
% [A,R] = readgeoraster([gridpath,'bathy_KG_0005d.tif']);
% % Create grids of UTM coordinates
% [X,Y] = worldGrid(R);
% % Convert UTM (x,y) to lat/lon
% [lat,lon] = projinv(R.ProjectedCRS,X,Y);

opts = detectImportOptions("CruiseTrackDepth.csv", 'delimiter', ',');
CruiseTrack=readtable('CruiseTrackDepth.csv',opts);
CruiseTrack.time = datetime(CruiseTrack.time, ...
    'InputFormat', 'yyyy-MM-dd HH:mm:ssXXX', 'TimeZone', 'UTC');
CruiseTrack.depth_EM124_m_ = str2double(CruiseTrack.depth_EM124_m_);

%% plot the sections
thefig=figure; thefig.WindowState = 'maximized'; set(thefig,'Visible','on')
thefig.Position(3)=thefig.Position(4).*16./9; % change the aspect ratio
%%
for m=1:length(sectionfilenames)
clf
% use SDA track from Underway. Still tricky with interpolation.
%grid_options={'sdatrack'}; % use default bathymetry as bottom CTD 
% switch to using bottle depths:
grid_options={'botdepth'};
% specifics for each section, depth, caxis, etc
    P = sdaSectionParams(sectionfilenames{m});
  
    % conservative temperature
    subplot(3,5,3:5);

    if (anomalyplot==0)
        % this snippet plots absolute fields
        plot_sk_ctd_section(P.sectionlist,ctds,'ct','xvar','dist','type','pcolor_interp',...
           'levels',[-2.0:0.5:7],'station_labels','true',grid_options{:});
        clim([P.tcaxis]);
        cmocean('thermal')
        fignameappend='';
    else
        % this snippet plots anomalies (beware reference cast is hard wired)
        plot_sk_ctd_section(P.sectionlist,ctds,'ct_anom','xvar','dist','type','pcolor_interp',...
            'levels',[-1.0:0.5:1.0],'station_labels','true',grid_options{:});    
        clim([-1 1]);
        cmocean('balance')
        fignameappend='_anom';
    end

    ylim([0 P.maxy]);
    ylabel('Depth (m)');
    hcb=colorbar;
    hcb.Label.String= 'CT (\circC)'; %'\Theta (^oC)';
    sectionlength=max(xlim);
    
    % absolute salinity
    subplot(3,5,8:10);

    if (anomalyplot==0)
        % this snippet plots absolute fields
        plot_sk_ctd_section(P.sectionlist,ctds,'asal','xvar','dist','type','pcolor_interp',...
            'levels',[33:0.5:34.5 34.6:0.1:35.6],grid_options{:});
        clim([P.scaxis]);
        cmocean('haline')
    else
        % this snippet plots anomalies (beware reference cast is hard wired)
        plot_sk_ctd_section(P.sectionlist,ctds,'asal_anom','xvar','dist','type','pcolor_interp',...
            'levels',[-1.0:0.5:1.0],'station_labels','true',grid_options{:});
        clim([-0.5 0.5]);
        cmocean('balance')
        fignameappend='_anom';
    end

    ylim([0 P.maxy]);
    ylabel('Depth (m)');
    hcb=colorbar;
    hcb.Label.String='SA (‰)';
    
    % ocean currents
    subplot(3,5,13:15);
    plot_sk_ctd_section(P.sectionlist,ctds,'ladcp_perp','xvar','dist',...
        'type','pcolor_interp','chartlet',false,grid_options{:});
    ylim([0 P.maxy]);
    clim([P.vcaxis]);
    xlabel('Distance (km)');
    ylabel('Depth (m)');
    cmocean('balance')
    hcb=colorbar;
    hcb.Label.String={'LADCP current'; 'across section (m/s)'};
    
    % % Oxygen concentrations 
    % ax2=subplot(3,5,13:15);
    % % % 'oxygen_umol_kg'
    % plot_sk_ctd_section(P.sectionlist,ctds,'oxygen_umol_kg','xvar','dist',...
    %     'type','pcolor_interp','levels',[],'station_labels','true',grid_options{:});
    % ylim([0 P.maxy]);
    % clim([320 370]);
    % xlabel('Distance (km)');
    % ylabel('Depth (m)');
    % colormap(ax2,'jet')
    % hcb=colorbar;
    % hcb.Label.String={'Oxygen'; 'umol kg^{-1}'};
    % sectionlength=max(xlim);
 
    % T-S plot (will add density later)
    subplot(2,5,6:7) % top right - t/s
    allstations=[sd_ctds.station];
    ind=zeros(size(P.sectionlist));
    for n=1:length(P.sectionlist)
        try
            ind(n)=find(allstations==P.sectionlist(n));
        catch
            error('Cannot find %s station %d',cruise,stns(n));
        end
    end
    
    plot(vertcat(sd_ctds.asal),vertcat(sd_ctds.ct),'.','markersize',2,'color',sdcolor);
    hold on;
    % plot(vertcat(er_ctds.asal),vertcat(er_ctds.ct),'.','markersize',2,'color',ercolor);
    % plot(vertcat(sk_ctds.asal),vertcat(sk_ctds.ct),'.','markersize',2,'color',skcolor); 
    plot(vertcat(sd_ctds(ind).asal),vertcat(sd_ctds(ind).ct),'r.','markersize',2);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add density contours 
    thetaTS=[-2:0.2:10];
    s=[24:0.5:36];

    smin=min(s)-0.01.*min(s);
    smax=max(s)+0.01.*max(s);
    thetamin=min(thetaTS)-0.1*max(thetaTS);
    thetamax=max(thetaTS)+0.1*max(thetaTS);
    xdim=round((smax-smin)./0.1+1);
    ydim=round((thetamax-thetamin)+1);
    dens=zeros(ydim,xdim);
    thetai=((1:ydim)-1)*1+thetamin;
    si=((1:xdim)-1)*0.1+smin;
    for j=1:ydim
        for i=1:xdim
            dens(j,i)=gsw_sigma0(si(i),thetai(j)); % LC modified potential density anomaly
        end
    end
    [c,h]=contour(si,thetai,dens,[20:1:28],'k');
    clabel(c,h,'LabelSpacing',90);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    xlim([28 35.5]);
    ylim([-2 5]);
    xlabel('S_A (‰)');
    ylabel('CT \circC');%ylabel('\Theta (^oC)');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add the water masses LC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % I follow Rudels 2001 for all the definition, but I have made modifications to the density.
    % Reduce it because on the shelf watermasses seem lighter
    mysig0AWmin = 27.3; % adjusted from below 27.7 is Surface PW above it Arctic Atlantic Water
    mysig0PW    = 26.5;      % adjusted from 27.7 to create an intermediate water mass between PW and AAW
    mysig0AWmax = 29;   % adjusted from 27.97 above that likely Polar intermediate water
    % Mark the density contour at water masses boundaries
    [C,h] = contour(si,thetai,dens,[mysig0AWmin mysig0AWmin],'k', 'LineWidth', 2); % denser is AW and less dense MAW
    clabel(c,h,'LabelSpacing',90);
    [C,h] = contour(si,thetai,dens,[mysig0PW mysig0PW],'color',[0.1 0.1 0.1], 'LineWidth', 2); % less dense is PW
    clabel(c,h,'LabelSpacing',90);
    [C,h] = contour(si,thetai,dens,[mysig0AWmax mysig0AWmax],'color',[0.6 0.6 0.6], 'LineWidth', 2); % less dense is PW
    clabel(c,h,'LabelSpacing',90);
     % plot water masses
     PWt1    = [-1.1];  PWs1 = [32]; %
     AWt1    = [2.5];  AWs1 = [34.8]; %
     AWit1   = [-1.5];  AWis1 = [33.5]; % based on CTD16 this is AW modified by ice (sits exactly along the gade line) 
     msize=20;
     plot(AWs1, AWt1,'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
     plot(PWs1 , PWt1, 'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
     plot(AWis1 , AWit1, 'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
     text (AWs1+0.3, AWt1,'AW','FontSize',FZ)
        text (AWis1-0.4,AWit1-0.4,'MAW','FontSize',FZ-1)
        text (PWs1-0.5, PWt1+.8,'PW','FontSize',FZ)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Map for section location
    if P.fjord==1
        subplot(2,5,1) % region - map
        % set our projection to UTM zone 25 north
        m_proj('utm','lon',[-34 -28],'lat',[66 68.7],'zone',25,'hem',0,'ell','wgs84');

        pcolor(bedmachine.x-50,bedmachine.y-50,bedmachine.z);
        hold on;
        pcolor(mb.x-mb.cellsize./2,mb.y-mb.cellsize./2,mb.z);
        shading flat;
        clim([-1000 0]);
        colormap(gca,flipud(cmocean('deep')))

        % add a coastline
        %m_usercoast('greenland_coast.mat','color','k');
        % m_usercoast('greenland_coast.mat','patch',[.8 .8 .8],'edgecolor','k');

        % plot all CTDs
        m_plot(mean(vertcat(sd_ctds(ind).lon)),mean(vertcat(sd_ctds(ind).lat)),...
            'ro','markersize',10,'linewidth',2); % if using zoomed out map
        m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6);
        %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5);
        %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);
        % m_plot(vertcat(er_ctds(ind).lon),vertcat(er_ctds(ind).lat),'r+-','linewidth',2); % if using zoom in map
        % add a graticule
        m_grid;
     end

    subplot(2,5,1:2) % bottom right - map
    % set our projection to UTM zone 25 north
    m_proj('utm','lon',P.mLON,'lat',P.mLAT,'zone',25,'hem',0,'ell','wgs84');
  
    pcolor(bedmachine.x-50,bedmachine.y-50,bedmachine.z);
    hold on;
    pcolor(mb.x-mb.cellsize./2,mb.y-mb.cellsize./2,mb.z);
    shading flat;
    clim([-1200 0]);
    colormap(gca,flipud(cmocean('deep')))
    
    % add a coastline
    %m_usercoast('greenland_coast.mat','color','k');
    % m_usercoast('greenland_coast.mat','patch',[.8 .8 .8],'edgecolor','k');

    % plot all CTDs
    m_plot(vertcat(sd_ctds(ind).lon),vertcat(sd_ctds(ind).lat),'r+-','linewidth',2);
    m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6);
    %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5);
    %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);
    % if sectionlength<10 % circle short sections
    %     m_plot(mean(vertcat(sd_ctds(ind).lon)),mean(vertcat(sd_ctds(ind).lat)),...
    %         'ro','markersize',20,'linewidth',2);
    % end
    
    % add a graticule
    m_grid;
    % add ruler to the map
    
    title(P.sectionname);
    figname=sprintf('_ctd_section_%s.png',strcat(sectionfilenames{m},fignameappend));
%    print(thefig,'-dpng','-r200',figname);
    exportgraphics(gcf,[figPb,cruise,figname],'Resolution',300)
end
