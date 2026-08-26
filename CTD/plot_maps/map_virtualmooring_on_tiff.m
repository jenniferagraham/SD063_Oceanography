%  uses the tidal cycle from VMADCP virtual mooring data and plots the rosette 
% over the TIFF - we can then see velocities at our yoyo stations with
% syncrony.  
% lc 15-aug-2026
%%
clear all
clc
close all
layer ='top'; %top =  0 to 75m ; bottom 100 m -
alpha=0.6;
mmap=1; % plot the image using m_map, mmap=0; plots using matlab geospatial function 
type='sill'; %sill=0; zoom the map out to get the sill, sill=1; zooms the map on the ice front
anomalies=1; 
isinset=1; % isinset=1 plots one an inset map with a zoom on the glacier front on the same plot as the sill 
figname = ['map_virtualmooring_icefront_',type,'_', layer];
sentinatlname = ['2026-08-14-00_00_2026-08-14-23_59_Sentinel-2_L2A_True_color.TIFF'];
jennycmap = flipud(cmocean('phase',100)); % Jenny's choice of colormap 

%% path and inputs
if ispc
    disk = ['L:\work\scientific_work_areas\'];
    dataPsenti=[disk,'\gis\satellite_imagery\3-miippugut (Ryberg)\'];
    addpath([disk,'oceanography\matlabF\']) % theta_sdiag function
    addpath([disk,'oceanography\matlabF\m_map\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter function
    figP = [disk,'oceanogrpahy\Figures\MAP\'];

elseif ismac
    disk = ['/Volumes/leg/work/scientific_work_areas/'];
    dataPsenti =[disk,'gis/satellite_imagery/3-miippugut (Ryberg)/'];
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    vmadcp_pauldata = [disk, 'oceanography/VMADCP/virtual_mooring/'];
    figP= [disk,'oceanography/CTD/plot_maps/Figures/'];
   % addpath([disk,'oceanography/CTD/plot_transects/']); % 
end
%% get the satellite imaged
flname=[dataPsenti,sentinatlname];
[A,R] = readgeoraster(flname);
[lat_tiff,lon_tiff] = geographicGrid(R);

%% define constants for map and vector sizes 
% when map is over the full sill it is sill
    xxmapS.sill = [-30.99 -30.10];
    yymapS.sill = [ 68.14 68.35];
    yoyolistS.sill = {'repeat_3micefrontnorthyoyoonly', 'repeat_3micefrontsouthyoyoonly', 'repeat_3mwestsill','repeat_3meastsill'};
    lon_vecrefS.sill = xxmapS.sill(1)+0.07;
    lat_vecrefS.sill = yymapS.sill(2)-0.03;
    vecsizeS.sill = 0.2; % % 0.2 m/s reference vector
% if we make a zoom 
   xxmapS.zoom = [-30.88 -30.75];
    yymapS.zoom = [68.272 68.3055];
    yoyolistS.zoom = {'repeat_3micefrontnorthyoyoonly', 'repeat_3micefrontsouthyoyoonly'};
   lon_vecrefS.zoom = xxmapS.zoom(1)+0.02;
    lat_vecrefS.zoom = yymapS.zoom(2)-0.005;
    vecsizeS.zoom = 0.05; % % 0.2 m/s reference vector

%% map area
eval(['xxmap = xxmapS.',type,';'])
eval(['yymap = yymapS.',type,';'])
eval(['yoyolist = yoyolistS.',type,';'])
eval(['lon_vecref = lon_vecrefS.',type,';'])
eval(['lat_vecref = lat_vecrefS.',type,';'])
eval(['vecsize = vecsizeS.',type,';'])
%% plot the tiff image
   f= figure; %set(f,'Position',[],'vissible','on')

if mmap==0
    figure
    g=geoshow(lat_tiff,lon_tiff,A);
    uistack(g,'down');
    % set the axis mannually to prevent autoscaling
    axis manual
    xlim(xxmap)
    ylim(yymap)
    rn=rectangle('Position',[-rx(1) ry(1) rx(1)-rx(2) ry(2)-ry(1)], 'FaceColor','w','edgecolor','k');uistack(rn,'up'); % position (x, y, w, h)
    text(-rx(1)-0.05,ry(1),textboxtit)
else
    % plot with M_Map
    lattiff = lat_tiff(:,1);
    lontiff = lon_tiff(1,:);

    if ~isa(A,'uint8'); A = uint8(255 * mat2gray(A)); end   
    m_proj('mercator','lon', xxmap,'lat',yymap);
    % Plot the TIFF
    m_image(lontiff, lattiff, A);
    % Keep image underneath other map layers
    hold on
    % Coastline
    m_coast('patch',[0.7 0.7 0.7],'edgecolor','k');
    % Grid
    m_grid('box','fancy','tickdir','in');
   % vector legend 
    m_vec(vecsize,lon_vecref, lat_vecref+0.002, 0.1,0,'k','key','10 cm/s','shaftwidth', 0.9, 'headlength', 5, 'headwidth', 5,'facecolor','k','edgecolor','k')

end


%% add vectors to the plot
for ii=1:length(yoyolist)
    load([vmadcp_pauldata,'virtualmooringdata_',yoyolist{ii},'.mat'])
    p = [virtualmooring.lon virtualmooring.lat];       % location of the point
    lon = p(1);
    lat = p(2);
    u = [virtualmooring.utop']; % eastward velocity
    v = [virtualmooring.vtop']; % northward velocity
    tidephase =[virtualmooring.tidephase];
    rgbtriplet = [virtualmooring.tidephasecmaptriplet];
    %all vectors to originate from the same point
    arrowu=lon*ones(size(u));
    arrowv =lat*ones(size(v));
    if anomalies==1
        u = u-virtualmooring.utopmean;
        v=  v-virtualmooring.vtopmean;
    end
    m_plot(lon, lat, 'ok', 'MarkerFaceColor', 'k')
    hold on
    % multiple colours for the arrows
    for in = 1:size(u,2)
        %m_quiver(lon, lat, u(in), v(in), vecsize, 'faceColor', rgbtriplet(in,:),'LineWidth', 1.5,'MaxHeadSize', 0.8);
        m_vec(vecsize,lon, lat, u(in), v(in), 'faceColor', rgbtriplet(in,:),'FaceAlpha',alpha,'edgecolor','none');
    end
end
%% colorbar 
colormap(jet(100))
cb = colorbar;
cb.Label.String = 'Tidal phase (fraction)';
cb.Ticks = 0:0.25:1;
caxis([0 1])
cb.TickLabels = {'0 high tide','0.25 ebb','0.5 low tide','0.75 flood','1 high tide'};    % subsittue with the timeof the stations

%% % Create inset axes in lower-left corner
if isinset==1
    figname = ['map_virtualmooring_',type,'_withicefrontinset_', layer];

    % zoom metrics 
    type='zoom';
  eval(['xxmap = xxmapS.',type,';'])
 eval(['yymap = yymapS.',type,';'])
 eval(['yoyolist = yoyolistS.',type,';'])
 eval(['lon_vecref = lon_vecrefS.',type,';'])
 eval(['lat_vecref = lat_vecrefS.',type,';'])
 eval(['vecsize = vecsizeS.',type,';'])


    ax_inset = axes('Position',[0.1 0.1 0.35 0.35]);
    m_proj('mercator','lon', xxmap,'lat',yymap);

    % Plot the TIFF
    m_image(lontiff, lattiff, A);

    % Keep image underneath other map layers
    hold on

    % Coastline
    m_coast('patch',[0.7 0.7 0.7],'edgecolor','k');
    % Grid
    m_grid('box','fancy','tickdir','in');

    % reference vector
    m_vec(vecsize,lon_vecref, lat_vecref+0.002, 0.01,0,'k','key','1 cm/s','shaftwidth', 0.9, 'headlength', 5, 'headwidth', 5,'facecolor','k','edgecolor','k')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add vectors to the plot
for ii=1:length(yoyolist)
    load([vmadcp_pauldata,'virtualmooringdata_',yoyolist{ii},'.mat'])
    p = [virtualmooring.lon virtualmooring.lat];       % location of the point
    lon = p(1);
    lat = p(2);
    u = [virtualmooring.utop']; % eastward velocity
    v = [virtualmooring.vtop']; % northward velocity
    tidephase =[virtualmooring.tidephase];
    rgbtriplet = [virtualmooring.tidephasecmaptriplet];
    %all vectors to originate from the same point
    arrowu=lon*ones(size(u));
    arrowv =lat*ones(size(v));
    if anomalies==1
        u = u-virtualmooring.utopmean;
        v=  v-virtualmooring.vtopmean;
    end
    m_plot(lon, lat, 'ok', 'MarkerFaceColor', 'k')
    hold on
    % multiple colours for the arrows
    for in = 1:size(u,2)
        %m_quiver(lon, lat, u(in), v(in), vecsize, 'faceColor', rgbtriplet(in,:),'LineWidth', 1.5,'MaxHeadSize', 0.8);
        m_vec(vecsize,lon, lat, u(in), v(in), 'faceColor', rgbtriplet(in,:),'FaceAlpha',alpha,'edgecolor','none');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % debug

%% savefigure

if anomalies==1; 
    figname = [figname,'_anomaly']; 
elseif anomalies==0;  
    figname = [figname,'_mean']; 
end

exportgraphics(gcf, [figP, figname,'.png'], 'Resolution', 300)

