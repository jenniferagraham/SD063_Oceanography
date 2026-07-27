%% created by Laura C (SAMS) uses an updated of Povl's original plot sd sections that were used for the cruise report 
%% modified by CTD team SD 063
clear all
clc
%% add paths for GSW and where to save figures 

here=pwd;
if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    figPb   = [disk,'\CTD\plot_transects\Figures\'];
    ctddata = [disk,'CTD\BASproc\'];
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
%set(0, 'DefaultTextFontWeight', 'bold');
%% define the sections
% sectionlists={[20,16,12,7,57,8,85:88,90,89,3],...
%     17:25,... % Inner Kang
%     [61:63,59,66,67,58,9:15,81,82,26],... % Outer Kang
%     [79,71,80,5,73,72,78,76,77,7],... % Mooring section
%     [27,31,35,36,39,34,42],[43:46],[53:56],... % Along fjords
%     [33:-1:29],[37:41],[47,46,48,49],[50,53,51,52]}; % Across fjords
% sectionnames={'Trough','Inner Kang', 'Outer Kang','Mooring section',...
%     '3-miippugut','Kivioq main','Kivioq east',...
%     '3-miippugut across mid','3-miippugut across outer','Kivioq across','Kivioq east across'};
% sectionfilenames={'trough','kang_inner','kang_outer','mooring',...
%     '3miippugut','kivioq','kivioq_east',...
%     '3miippugut_cross_mid','3miippugut_cross_outer','kivioq_cross','kivioq_east_cross'};


sectionlists={[5,6,7,8,9],... % S section - mooring towards Kang trough
    [13, 11,10],... % Melange Trough entrance  along section 
    [14, 15, 16, 17, 18],... % Melange Trough North
    [19, 20, 21]}; % Magic Trough 
sectionnames={'S-mooring section','Melange Trough along', 'Melange Trough entrance',...
    'Magic Trough'};
sectionfilenames={'Ssection','melangetroughalong','melangetroughentrance',...
    'magictrough'};


maxy=1000; % depth 
% definition of colours you may need to fix 
    ercolor = [.5 1 1]; % bright blue
    skcolor2025 = [.5 .5 1]; % purple
    sdcolor = [.5 .5 .5]; % grey
    %sdcolor2026 = [1 .5 .5]; % grey
    seccolor= [1 .0 .0]; % red
%% load CTDs


    cruise='SD063';
    load([ctddata,cruise,'_ctd.mat']);
    
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
thefig=figure; thefig.WindowState = 'maximized'; set(thefig,'Visible','off')
thefig.Position(3)=thefig.Position(4).*16./9; % change the aspect ratio
%%
for m=1:length(sectionlists)
clf
grid_options={'sdatrack'}; % use default bathymetry as bottom CTD 
fjord=0;
% specifics for each section, depth, caxis, etc
        vcaxis = [-0.2 0.2];
        tcaxis  = [-2 14];
        scaxis  = [27 35.5];
        mLON = [-33.4 -28]; % related to map projections
        mLAT = [67.4 69]; % related to map projections
    if  m==1 % 'S-mooring section'
        maxy=1000;
        tcaxis = [-2 5];
        scaxis = [30 35.5];
        vcaxis = [-0.5 0.5];
        mLON   = [-33.4 -30]; % related to map projections
        mLAT   = [66.8 69]; % related to map projections
    elseif m==2 % 'Melange Trough along'
        maxy=700;
        vcaxis = [-0.2 0.2];
        tcaxis = [-2 3];
        scaxis = [29 35];
        mLON   = [-33.4 -30]; % related to map projections
        mLAT   = [67.4 69]; % related to map projections
    elseif m==3 % 'Melange Trough entrance'
        maxy=700;
        vcaxis = [-0.5 0.5];
        tcaxis = [-2 3];
        scaxis = [29 35];
        mLON   = [-33.4 -30]; % related to map projections
        mLAT   = [67.4 69]; % related to map projections
    elseif m==4 % 'Magic Trough'
        maxy=400;
        vcaxis = [-0.4 0.4];
        tcaxis = [-2 3];
        scaxis = [29 35];
        mLON   = [-33.4 -30]; % related to map projections
        mLAT   = [67.2 69]; % related to map projections
    elseif m==5 || m==8 || m==9 % mippugut
        fjord=1;
        mLON   = [-31 -30]; % related to map projections
        mLAT   = [68 68.5]; % related to map projections
        vcaxis = [-0.3 0.3]; 
        tcaxis = [-2 1]; 
        scaxis = [26.5 34.5];
        if m==5; maxy=500; elseif m==8; maxy=200; elseif m==9; maxy=500; end
    elseif  m==7 || m==11
       maxy=450; 
       mLON   = [-29.8 -28.5]; % related to map projections
       mLAT   = [68 68.5]; % related to map projections
       vcaxis = [-0.4 0.4]; 
       tcaxis = [-2 2.5]; 
       scaxis = [29 33];
    elseif m==6 || m==10 %kivioq    
        fjord=1;
       if m==6; maxy=250; elseif m==10; maxy=150; end 
       grid_options={'grdfile','kivioq_proc_20m_interp.grd'};
       mLON   = [-29.8 -28.5]; % related to map projections
       mLAT   = [68 68.5]; % related to map projections
       vcaxis = [-0.3 0.3]; 
       tcaxis = [-2 1]; 
       scaxis = [26.5 34.5];
    end

  
    % conservative temperature
    subplot(3,5,3:5);
    plot_sk_ctd_section(sectionlists{m},ctds,'ct','xvar','dist','type','pcolor_interp',...
        'station_labels','true',grid_options{:});
   % plot_sda_ctd_section(sectionlists{m},ctds,'ct','xvar','dist','type','pcolor_interp',...
   %     'station_labels','true',grid_options{:});

    ylim([0 maxy]);
    clim([tcaxis]);
    cmocean('thermal')
    ylabel('Depth (m)');
    hcb=colorbar;
    hcb.Label.String= 'CT (\circC)'; %'\Theta (^oC)';
    sectionlength=max(xlim);
    
    % absolute salinity
    subplot(3,5,8:10);
    plot_sk_ctd_section(sectionlists{m},ctds,'asal','xvar','dist','type','pcolor_interp',...
        grid_options{:});
    ylim([0 maxy]);
    clim([scaxis]);
    cmocean('haline')
    ylabel('Depth (m)');
    hcb=colorbar;
    hcb.Label.String='SA (‰)';
    
    % ocean currents
    subplot(3,5,13:15);
    plot_sk_ctd_section(sectionlists{m},ctds,'ladcp_perp','xvar','dist',...
        'type','pcolor_interp','chartlet',false,grid_options{:});
    ylim([0 maxy]);
    clim([vcaxis]);
    xlabel('Distance (km)');
    ylabel('Depth (m)');
    cmocean('balance')
    hcb=colorbar;
    hcb.Label.String={'LADCP current'; 'across section (m/s)'};
    
    % T-S plot (will add density later)
    subplot(2,5,6:7) % top right - t/s
    allstations=[sd_ctds.station];
    ind=zeros(size(sectionlists{m}));
    for n=1:length(sectionlists{m})
        try
            ind(n)=find(allstations==sectionlists{m}(n));
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
    
    % Map for section location
    if fjord==1
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
        m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6);
        %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5);
        %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);
        % m_plot(vertcat(er_ctds(ind).lon),vertcat(er_ctds(ind).lat),'r+-','linewidth',2); % if using zoom in map
        m_plot(mean(vertcat(sd_ctds(ind).lon)),mean(vertcat(sd_ctds(ind).lat)),...
            'ro','markersize',10,'linewidth',2); % if using zoomed out map
        % add a graticule
        m_grid;
     end

    subplot(2,5,1:2) % bottom right - map
    % set our projection to UTM zone 25 north
    m_proj('utm','lon',mLON,'lat',mLAT,'zone',25,'hem',0,'ell','wgs84');
  
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
    m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6);
    %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5);
    %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);
    m_plot(vertcat(sd_ctds(ind).lon),vertcat(sd_ctds(ind).lat),'r+-','linewidth',2);
    % if sectionlength<10 % circle short sections
    %     m_plot(mean(vertcat(sd_ctds(ind).lon)),mean(vertcat(sd_ctds(ind).lat)),...
    %         'ro','markersize',20,'linewidth',2);
    % end
    
    % add a graticule
    m_grid;
    % add ruler to the map
    
    title(sectionnames{m});
     figname=sprintf('_ctd_section_%s.png',sectionfilenames{m});
%    print(thefig,'-dpng','-r200',figname);
    exportgraphics(gcf,[figPb,cruise,figname],'Resolution',300)
end
