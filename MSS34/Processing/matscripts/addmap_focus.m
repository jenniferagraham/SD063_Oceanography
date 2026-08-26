%close all; clear all;

function addmap_focus(sectionlat,sectionlon)

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
    disk = ['/Volumes/leg/work/scientific_work_areas/'];
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

% focus region map 
    % set our projection to UTM zone 25 north
    m_proj('utm','lon',[-31 -30],'lat',[68 68.40],'zone',25,'hem',0,'ell','wgs84');
  
    m_pcolor(bedmachine.x-50,bedmachine.y-50,bedmachine.z);
    hold on;
    pcolor(mb.x-mb.cellsize./2,mb.y-mb.cellsize./2,mb.z);
    shading flat;
    clim([-1200 0]);
    colormap(gca,flipud(cmocean('deep')))
    
       m_plot(sectionlon,sectionlat,'r+-','linewidth',2);
    m_grid;
