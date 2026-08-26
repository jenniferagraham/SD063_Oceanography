function [c,h]=m_gebco2022_contour(varargin)
%M_IBCSO Plot IBCSO bathymetry on current map.
%
%  Plots the IBCSO (International Bathymetric Chart of the Southern Ocean)
%  bathymetry grid on your current m_map map using p_color. Resolution is 
%  limited to a maximum of 2000x2000 pixels to avoid ridiculously long
%  plotting times.
%
%  You may have to edit the path to your IBCSO data file in this script, if
%  it is not in the same directory as the script or in your current path. 
%  If you don't already have the data, you can download the file from
%  http://hs.pangaea.de/Maps/bathy/IBCSO_v1/IBCSO_v1_bed_PS71_500m_grd.zip
%  or http://doi.pangaea.de/10.1594/PANGAEA.805734?format=html, if a newer
%  version is available. Choose the NetCDF file, polar stereographic, with
%  true scale at 71 deg. S
%
%  By Povl Abrahamsen, BAS (epab@bas.ac.uk); v. 1.3, Mar 2022

% These structures are initialized by m_proj()

global MAP_PROJECTION MAP_VAR_LIST

% Have to have initialized a map first

if isempty(MAP_PROJECTION),
  disp('No Map Projection initialized - call M_PROJ first!');
  return;
end;

[corner_lon,corner_lat]=m_xy2ll(MAP_VAR_LIST.xlims([1 2 2 1]),...
    MAP_VAR_LIST.ylims([1 1 2 2]));

if MAP_VAR_LIST.longs(2)>=180
    corner_lon=mod(corner_lon,360);
    flip_lon=1;
elseif MAP_VAR_LIST.longs(1)<=-180
    corner_lon=mod(corner_lon,360)-360;
    flip_lon=-1;
else
    corner_lon=mod(corner_lon+180,360)-180;
    flip_lon=0;
end

gebco_file='GEBCO_2022_sub_ice_topo.nc';

full_x=ncread(gebco_file,'lon');
split_point=find(full_x>0,1);
if flip_lon>0
    full_x=[full_x(split_point:end);full_x(1:(split_point-1))+360];
elseif flip_lon<0
    full_x=[full_x(split_point:end)-360;full_x(1:(split_point-1))];
end
full_y=ncread(gebco_file,'lat');

dimension=[length(full_x),length(full_y)];

xstart=find(full_x<=min(corner_lon),1,'last');
if isempty(xstart),xstart=1;end
xend=find(full_x>=max(corner_lon),1,'first');
if isempty(xend),xend=dimension(1);end
ystart=find(full_y<=min(corner_lat),1,'last');
if isempty(ystart),ystart=1;end
yend=find(full_y>=max(corner_lat),1,'first');
if isempty(yend),yend=dimension(2);end

data_x=xstart:xend;
data_y=ystart:yend;
% [data_z,~]=meshgrid(data_x,data_y);

n=1;
xlength=length(data_x);
skip=ceil(xlength./2000); %reduce number of points to avoid ridiculously long plotting times

data_x=data_x(1:skip:end);
data_y=data_y(1:skip:end);
[data_z,~]=meshgrid(data_x,data_y);
if flip_lon
    xlength1=sum(data_x<split_point);
    xlength2=sum(data_x>=split_point);
else
    xlength=length(data_x);
end

ncid=netcdf.open(gebco_file,'NOWRITE');
varid = netcdf.inqVarID(ncid,'elevation');
for m=data_y %ystart:yend
    if flip_lon
      data_z(n,1:xlength1)=netcdf.getVar(ncid,varid,...
        [xstart+split_point-2,m-1],[xlength1,1],[skip,1],'double');
      data_z(n,(xlength1+1):end)=netcdf.getVar(ncid,varid,...
        [mod(xstart+split_point-2,skip),m-1],[xlength2,1],[skip,1],'double');
    else
      data_z(n,:)=netcdf.getVar(ncid,varid,...
        [xstart-1,m-1],[xlength,1],[skip,1],'double');
    end
%     data_z(n,:)=netcdf.getVar(ncid,varid,...
%         (dimension(2)-m)*dimension(1)+xstart-1,xlength,skip,'double');
%     data_z(n,:)=ncread(gebco_file,'z',...
%         (dimension(2)-m)*dimension(1)+xstart,xlength);
    n=n+1;
end
netcdf.close(ncid);

[plot_lon,plot_lat]=meshgrid(full_x(data_x),full_y(data_y));

if MAP_VAR_LIST.longs(2)>=180
    plot_lon=mod(plot_lon,360);
elseif MAP_VAR_LIST.longs(1)<=-180
    plot_lon=mod(plot_lon,360)-360;
end
[plot_x,plot_y]=m_ll2xy(plot_lon,plot_lat,'clip','patch');

data_z(isinf(data_z))=nan;
[c,h]=contour(plot_x,plot_y,data_z,varargin{:});
%shading flat;


