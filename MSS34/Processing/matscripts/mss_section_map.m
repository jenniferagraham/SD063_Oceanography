%close all; clear all;


if ispc % ellie you should be able to run it using mac=0 you may need to adjust some of the paths
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
    disk = ['L:\work\scientific_work_areas\']; %
    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    mssdataP = [disk,'oceanography\MSS34\DATA\'];
    figpath = [disk,'oceanography\MSS34\Processing\Figures\'];
    gridpath= [disk,'gis\bathymetry_grids\'];
    addpath([disk,'oceanography\matlabF\']) % theta_sdiag function
    addpath([disk,'oceanography\matlabF\m_map\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter and plot_sk_cd_section functions
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\' % directory with multibeam bathymetry
    bedmachineF = [disk, 'oceanography\CTD\plot_transects\BedMachine-v5_crop.nc'];

   cfile = [disk,'gis\Greenland_coastlines_2017\bas_greenland_coastlines.gpkg']; % coastline file 

elseif ismac
    slash='/';
    disk = ['/Volumes/legwork/scientific_work_areas/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    mssdataP = [disk,'oceanography/MSS34/DATA/'];
    figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
    gridpath= [disk,'gis/bathymetry_grids/'];
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    addpath([disk,'oceanography/CTD/plot_transects/']) % create a similar one for MSS
    bedmachineF = [disk, 'oceanography/CTD/plot_transects/BedMachine-v5_crop.nc'];
    addpath ([disk,'oceanography/MSS34/']); % directory with multibeam bathymetry    
     cfile = [disk,'/gis/Greenland_coastlines_2017/bas_greenland_coastlines.gpkg'];

end
debug=1; 
cruise='SD063';

% Params for map plot (condensed from plot_sd063_ctd_section func)
m=1;
xvar='dist';
levels={};
grdfile='';
plottype='pcolor';
make_chartlet=false;
station_labels=false;

%% Create parameter object 
% Use sdaSectionParamsMSS?
mssparams = sdaSectionParamsMSS('3minner');
nMSS = 1:length(mssparams.castlist); % array with station IDs

% %% load mss eventlog (Laura's version)
% mssLog = importMSSlogbook4matlab(msslogbook); % use =1 means event action 'inWater'
% %VariableNames = ['Time', 'Latitude_dd', 'Longitude_dd', 'DepthEA640_m', 'MSSstation', 'EventNumber', 'MSScast', 'TargetDepth_m', 'Comment', 'Use'];
% indxRow = find(mssLog.Use==1); % inWater rows only
% % create work table
% msslogLon = mssLog.Longitude_dd(indxRow);
% msslogLat = mssLog.Latitude_dd(indxRow);
% mssLogMSScast = mssLog.MSScast(indxRow);
% 
%% Adapt plot_sk_ctd_section() function in CTD code to plot map

% preallocate size of arrays for each variable
temparray = zeros(1,length(nMSS))*NaN; % NaN array with no. columns equal to number of casts

section.lat   = temparray;
section.lon   = temparray;

for ii=1:length(nMSS)
    cast = mssparams.castlist(ii);

    section.lat(ii) = mss.lat; %logLat(find(mssLogMSScast == cast));
    section.lon(ii) = mss.lon; %logLon(find(mssLogMSScast == cast));
end

%% Import datasets for map visualisation
 load mb_all_20250512.mat
% Read BedMachine bedrock data (netcdf)
bedmachine.z = ncread(bedmachineF, 'z'); % z = depth
y = ncread(bedmachineF, 'y');
x = ncread(bedmachineF, 'x');
[bedmachine.y, bedmachine.x] = meshgrid(y,x);

if debug==0
% Read GIANT 3M bathymetry (tiff)
%bathy = Tiff([gridpath,'bathy_3miipugut_10m_utm25N.tif'],'r'); % Creates a TIF object
[tif, R] = readgeoraster([gridpath,'bathy_3miipugut_10m_utm25N.tif']); % read TIF and spatial reference
%tif = imread([gridpath,'bathy_3miipugut_10m_utm25N.tif']); % shows a black box
%geoshow(tif,R)

% Read Greenland coastline (gpkg)
% Read the GeoPackage file into a geospatial table
coastline = readgeotable(cfile);
end
%% regional map as in the section plots produced for CTD LC
subplot(2,5,1) 
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
        % m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6); % all SD063 data
        %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5); % all erabus data from SD041
        %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);% all data from skagerak 
        % plot MSS 
        m_plot(section.lon,section.lat,...
               'ro','markersize',10,'linewidth',2); % if data from these stations
        % add a graticule
        m_grid;

% map close to the stations 
 subplot(2,5,2:3) % bottom right - map
    % set our projection to UTM zone 25 north
    m_proj('utm','lon',[-31 -30],'lat',[68 68.40],'zone',25,'hem',0,'ell','wgs84');
  
    m_pcolor(bedmachine.x-50,bedmachine.y-50,bedmachine.z);
    hold on;
    pcolor(mb.x-mb.cellsize./2,mb.y-mb.cellsize./2,mb.z);
    shading flat;
    clim([-1200 0]);
    colormap(gca,flipud(cmocean('deep')))
    
    % add a coastline
    %m_usercoast('greenland_coast.mat','color','k');
    % m_usercoast('greenland_coast.mat','patch',[.8 .8 .8],'edgecolor','k');

    % plot all CTDs
   % m_plot(vertcat(sd_ctds.lon),vertcat(sd_ctds.lat),'+','color',sdcolor,'markersize',6);
    %m_plot(vertcat(er_ctds.lon),vertcat(er_ctds.lat),'+','color',ercolor,'markersize',5);
    %m_plot(vertcat(sk_ctds.lon),vertcat(sk_ctds.lat),'+','color',skcolor,'markersize',4);
   
    % plot MSS 
     m_plot(section.lon,section.lat,'r+-','linewidth',2);
    % if sectionlength<10 % circle short sections
    %     m_plot(mean(vertcat(sd_ctds(ind).lon)),mean(vertcat(sd_ctds(ind).lat)),...
    %         'ro','markersize',20,'linewidth',2);
    % end
    
    % add a graticule
    m_grid;
    % add ruler to the map
    
    %title(P.sectionname);
   % figname=sprintf('_mss_section_%s.png',strcat(sectionfilenames{m},fignameappend));
%% Use m_map to plot locations of casts
% Common bounding box for all sections (zoomed to fjord)
% Read a shapefile with Sorgenfri area in m_map?
% Easier to Define it from the MSS section lat and long arrays

% set our projection to UTM zone 25 north
%m_proj('utm','lon',[min(section.lon) max(section.lon)],'lat',[min(section.lat) max(section.lat)],'zone',25,'hem',0,'ell','wgs84');
m_proj('utm','lon',[-33.4 -28],'lat',[66.8 68.53],'zone',25,'hem',0,'ell','wgs84'); %'lon',[-34 -28],'lat',[66 68.7]

pcolor(bedmachine.x, bedmachine.y, bedmachine.z);
hold on;
shading flat;
clim([-1200 0]);
colormap(gca,flipud(cmocean('deep')))

% add a coastline
% m_usercoast('greenland_coast.mat','color','k');
% m_usercoast('greenland_coast.mat','patch',[.8 .8 .8],'edgecolor','k');

%% Rosie's code

global MAP_PROJECTION MAP_VAR_LIST MAP_COORDS
map_projection_backup=MAP_PROJECTION;
map_var_list_backup=MAP_VAR_LIST;
map_coords_backup=MAP_COORDS;

m_proj('mercator','lon',[min(section.lon),max(section.lon)],'lat',[min(section.lat),max(section.lat)]);
[x,y]=m_ll2xy(section.lon,section.lat,'clip','off');
section_dirs=atan2(diff(y),diff(x));

%%
if axistype == 'dist' % cumulative distance?
    plot_x = m_lldist(section.lon,section.lat);
    plot_x = [0;cumsum(plot_x)]; %/1000;
    plot_end_dist=plot_x(end);

elseif axistype == 'meandist' % distance along mean line through stations
    section_params=polyfit(x,y,1);
    a=section_params(1);
    b=section_params(2);
    a2=-1/a;
    b2=y+x/a;
    %perpendicular to section
    x1=(b2-b)./(a-a2);
    y1=a*x1+b;
    if any(diff(x1)<0)
        warning('Negative projected distance between adjacent stations!');
    end
    % section_err=sqrt((x1-x).^2+(y1-y).^2);
    section_dirs(:)=atan(a);

    % find the coast:
    load greenland_coast.mat
    [coast_x,coast_y]=m_ll2xy(ncst(1:(k(1)-1),1),ncst(1:(k(1)-1),2),'clip','off');
    [x_int_1,y_int_1]=intersections(coast_x,coast_y,x1(1:2)*[1 5;0 -4],y1(1:2)*[1 5;0 -4]);
    [x_int_2,y_int_2]=intersections(coast_x,coast_y,x1(end-1:end)*[0 -4;1 5],y1(end-1:end)*[0 -4;1 5]);

    [lon1,lat1]=m_xy2ll([x_int_1,x1,x_int_2],[y_int_1,y1,y_int_2]);
    plot_x = m_lldist(lon1,lat1);
    plot_x = [0;cumsum(plot_x)]; %/1000;
    plot_end_dist=plot_x(end);
    plot_x=plot_x(2:end-1);

elseif axistype == 'lon'
    plot_x=lon;
    plot_end_dist=plot_x(end);

elseif axistype == 'lat'
    plot_x=lat;
    plot_end_dist=plot_x(end);

elseif axistype == 'date'
    plot_x=[ctds.date];
    plot_end_dist=plot_x(end);
end

%% Code from plot_sd063_ctd_section function
% figure;
% hold on;
% 
% m_proj('utm','lon',[-33.4 -28],'lat',[66.8 68.53],'zone',25,'hem',0,'ell','wgs84'); %'lon',[-34 -28],'lat',[66 68.7]
% 
% buffer_m=750;
% dlon=[min(section.lon) max(section.lon)]+[-1 1].*buffer_m./1852./60./cos(mean(section.lat).*pi./180);
% dlat=[min(section.lat) max(section.lon)]+[-1 1].*buffer_m./1852./60;
% [dx,dy]=m_ll2xy(dlon,dlat);
% axis([dx dy]);
% m_regrid;
% 
% % Read KANG-GLAC bathymetry
% load mb_all_20250512.mat
% 
% xind=find(mb.x>=dx(1),1):find(mb.x<=dx(2),1,'last');
% yind=find(mb.y>=dy(1),1):find(mb.y<=dy(2),1,'last');
% pcolor(mb.x(xind),mb.y(yind),-mb.z(yind,xind));
% 
% shading flat;
% m_plot(lon,lat,'k+');
% 
% clim([0 500]);
% colormap((cmocean('deep')))
% m_usercoast('greenland_coast.mat','color','k');
% fprintf(1,'longitudes: %.4f %.4f\n',dlon);
% fprintf(1,'latitudes: %.4f %.4f\n',dlat);
% 

%% to add map 
% add TS plot with all station in the section in one color and the rest of
% the data collected on a different color. 

%f=figure;
%figPOS = [63 126 436 560];
%set(f,'Position',figPOS)

%subplot(3,2,1)
%imshow(bedmachine.z)
%hold on
% geoplot(coastline)
