function plot_sk2514_ctd_section(stns,ctds,variable,varargin)

% PLOT_SD041_CTD_SECTION (stns,ctdsstructure,variable,[property_name,property_value])
% by Povl Abrahamsen (August 2024)
% plots a basic CTD section from a cruise (with casts in a Matlab file
% named "[cruise]_ctd.mat", variable name "ctds" containing an array of
% Matlab structures with the data.
%
% variable is the Matlab variable to plot in the section.
%
% a variety of additional properties can be specified afterwards:
% "xvar": which variable to use for the x axis. can be:
%   - dist: distance in km between stations (using the cumulative distance
%     between each pair of stations.
%   - meandist: a linear regression is made through the whole section, and
%     station positions projected onto this line. This results in the
%     cumulative distance being closer to the overall distance along the
%     section, especially if there are many wiggles in the station
%     positions.
%   - lon / lat: longitude or latitude, respectively.
%   - date: date as a Matlab date number.
% "type" / "plottype": what kind of plot to use. can be:
%   - pcolor: pseudocolor plot, using midpoints between the stations as the
%     boundary between boxes. if "levels" are specified, contours are
%     superimposed in black.
%   - pcolor_interp: data are bilinearly interpolated onto a regular grid,
%     then plotted with pcolor. if "levels" are specified, contours are
%     superimposed in black.
%   - contour: contour lines
%   - contourf: filled contour lines
% "levels: levels to display in contour or contourf plots, or on top of
%     pcolor plots.
% "grdfile": grid file to use for bathymetry. can be:
%   - botdepth: use CTD bottom depths rather than gridded bathymetry
%   - gebco: use GEBCO2014 bathymetry (needs the GEBCO2014 grid on your
%     computer - and you will need to update this script with the path to 
%     the file)
%   - otherwise: specify the name of a GMT-formatted NetCDF grid file, and
%     it will be used for the bathymetry!
% LC- modification 05/2026 
% "ctdstructure" %lc 05/2026
%   - added the variable into the function - do not need to re-load it
% Commented out LADCP variable (skagerak did not have one)
cruise='SD063';
m=1;
xvar='dist';
levels={};
grdfile='';
plottype='pcolor';
make_chartlet=false;
station_labels=false;
while length(varargin)>m
    if length(varargin)==m
        levels=varargin{m};
        break;
    end
    switch(lower(varargin{m}))
        case 'levels'
            levels=varargin{m+1};
        case 'xvar'
            xvar=lower(varargin{m+1});
        case 'grdfile'
            grdfile=varargin{m+1};
        case {'type','plottype'}
            plottype=varargin{m+1};
        case {'chartlet','make_chartlet'}
            make_chartlet=varargin{m+1};
        case {'station_labels'}
            station_labels=varargin{m+1};
        otherwise
            warning('Unknown option %s',varargin{m});
    end
    m=m+2;
end


allstations=[ctds.station];
ind=zeros(size(stns));
for n=1:length(stns)
    try
        ind(n)=find(allstations==stns(n));
    catch
        error('Cannot find %s station %d',cruise,stns(n));
    end
end
ctds=ctds(ind);

if ~isfield(ctds(1),variable) && ~ismember(variable,{'gamma_n','ladcp_perp','ct','asal'})
    error('Cannot find variable %s in cruise %s',variable,cruise);
end

%now calculate gamma_n
maxP = 6250;
dp=nanmedian(diff(ctds(1).press));
start_off=dp-1; % start offset for pressure bins

temp=nan(ceil(maxP/dp),length(stns));
salin=temp;
press=temp;
ladcp_u=temp;
ladcp_v=temp;
newvar=temp;

for n=1:length(stns)
    dest_ind=[1:length(ctds(n).press)]+round((ctds(n).press(1)-start_off)/dp);
    press(dest_ind,n)=ctds(n).press;
    temp(dest_ind,n)=ctds(n).temp;
    salin(dest_ind,n)=ctds(n).salin;
    % ladcp_u(dest_ind,n)=ctds(n).ladcp_u;
    % ladcp_v(dest_ind,n)=ctds(n).ladcp_v;
    if ~ismember(variable,{'temp','salin','ct','asal','press','gamma_n','ladcp_u','ladcp_v','ladcp_perp'})
        newvar(dest_ind,n)=ctds(n).(variable);
    end
end

press=nanmedian(press,2);
lastind=find(~isnan(press),1,'last');
newpress=(press(lastind)+dp):dp:maxP;
if isnan(press(1))
    press(find(~isnan(press),1):-1:1)=press(find(~isnan(press),1))-[0:dp:dp*(find(~isnan(press),1)-1)];
end
press=repmat([press(1:lastind);newpress'],1,length(ctds));
temp=[temp(1:lastind,:);nan(length(press)-lastind,length(ctds))];
salin=[salin(1:lastind,:);nan(length(press)-lastind,length(ctds))];
ladcp_u=[ladcp_u(1:lastind,:);nan(length(press)-lastind,length(ctds))];
ladcp_v=[ladcp_v(1:lastind,:);nan(length(press)-lastind,length(ctds))];
if ~ismember(variable,{'temp','salin','ct','asal','press','gamma_n','ladcp_u','ladcp_v','ladcp_perp'})
    newvar=[newvar(1:lastind,:);nan(length(press)-lastind,length(ctds))];
end

lat=[ctds.lat];
lon=[ctds.lon];

global MAP_PROJECTION MAP_VAR_LIST MAP_COORDS
map_projection_backup=MAP_PROJECTION;
map_var_list_backup=MAP_VAR_LIST;
map_coords_backup=MAP_COORDS;
m_proj('mercator','lon',max(lon, [], 'omitnan'),'lat',max(lat, [], 'omitnan'));
[x,y]=m_ll2xy(lon,lat,'clip','off');
section_dirs=atan2(diff(y),diff(x));

switch (lower(xvar))
    case 'dist'
        plot_x = m_lldist(lon,lat);
        plot_x = [0;cumsum(plot_x)]; %/1000;
        plot_end_dist=plot_x(end);
    case 'meandist' % distance along mean line through stations
        
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
    case 'lon'
        plot_x=lon;
        plot_end_dist=plot_x(end);
    case 'lat'
        plot_x=lat;
        plot_end_dist=plot_x(end);
    case 'date'
        plot_x=[ctds.date];
        plot_end_dist=plot_x(end);
end


switch(variable)
    case 'ladcp_perp'
        [ladcp_dir,ladcp_spd]=cart2pol(ladcp_v,ladcp_u);
        nseg=length(lat)-1;
        section_dir_avg=mean(section_dirs([1,1:nseg;1:nseg,nseg]));
        [plot_var,~]=pol2cart(ladcp_dir+repmat(section_dir_avg,size(press,1),1),ladcp_spd);
    case 'gamma_n'
        plot_var=gamma_n(salin,temp,press,lon,lat);
    case 'asal'
        plot_var=gsw_SA_from_SP(salin,press,lon,lat);
    case 'ct'
        plot_var=gsw_CT_from_t(gsw_SA_from_SP(salin,press,lon,lat),temp,press);
    case {'temp','salin','press','ladcp_u','ladcp_v'}
        plot_var=eval(variable);
    otherwise
        plot_var=newvar;
end


switch plottype
    case 'pcolor'
        plot_x=plot_x(:)';
        mid_x=[(plot_x(1)-plot_x(2))./2,(plot_x(1:end-1)+plot_x(2:end))./2,(3*plot_x(end)-plot_x(end-1))./2];
        pcolor(mid_x,press(:,[1:end,end]),plot_var(:,[1:end,end]));
        shading flat;
        hold on;
        if ~isempty(levels)
            [c,h]=contour(plot_x,press(:,1),plot_var,levels,'k');
            clabel(c,h);
        end
    case 'pcolor_interp'
%         if strcmp(variable,'gamma_n')
%             %extend temperature and salinity, recalculate gamma_n
%             for n=1:length(stns)
%                 lastind=find(~isnan(plot_var(:,n)),1,'last');
%                 temp((lastind+1):end,n)=temp(lastind,n);
%                 salin((lastind+1):end,n)=salin(lastind,n);
%             end
%             plot_var=gamma_n(salin,temp,press,lon,lat);
%         else
            % for n=1:length(stns)
            %     lastind=find(~isnan(plot_var(:,n)),1,'last');
            %     plot_var((lastind+1):end,n)=plot_var(lastind,n);
            % end
%         end
        plot_dist=linspace(plot_x(1),plot_x(end),500);
        if strcmp(variable,'ladcp_perp')
            segment_x=[plot_x-1e-9;plot_x+1e-9]';
            segment_no=[1,1:nseg,1:nseg,nseg];
            [segment_x,segment_ind]=sort(segment_x);
            segment_no=segment_no(segment_ind);
            segment_interp=interp1(segment_x,segment_no,plot_dist,'nearest');
            section_dirs_interp=section_dirs(segment_interp);
            for n=1:length(stns)
                lastind=find(~isnan(ladcp_u(:,n)),1,'last');
                ladcp_u((lastind+1):end,n)=ladcp_u(lastind,n);
                ladcp_v((lastind+1):end,n)=ladcp_v(lastind,n);
            end
            ladcp_u_interp=griddata(repmat(plot_x(:)',size(press,1),1),press,ladcp_u,plot_dist,press(:,1));
            ladcp_v_interp=griddata(repmat(plot_x(:)',size(press,1),1),press,ladcp_v,plot_dist,press(:,1));
            [ladcp_dir_interp,ladcp_spd_interp]=cart2pol(ladcp_v_interp,ladcp_u_interp);
            [plot_var_interp,~]=pol2cart(ladcp_dir_interp+repmat(section_dirs_interp,size(press,1),1),ladcp_spd_interp);
        else
            for n=1:length(stns)
                lastind=find(~isnan(plot_var(:,n)),1,'last');
                plot_var((lastind+1):end,n)=plot_var(lastind,n);
            end
            plot_var_interp=griddata(repmat(plot_x(:)',size(press,1),1),press,plot_var,plot_dist,press(:,1));
        end
        pcolor(plot_dist-median(diff(plot_dist))./2,press(:,1),plot_var_interp);
        shading flat;
        hold on;
        if ~isempty(levels)
            [c,h]=contour(plot_x,press(:,1),plot_var,levels,'k');
            clabel(c,h);
        end
    case 'contour'
        contour(plot_x,press(:,1),plot_var,levels);
    case 'contourf'
        contourf(plot_x,press(:,1),plot_var,levels);
    otherwise
        error('Unknown plot type %s',plottype);
end
hold on;

for n=1:length(stns)
    plot(plot_x(n).*[1,1],ctds(n).press([1,end]),'k');
end
if station_labels
    text(plot_x,zeros(size(plot_x)),int2str(stns(:)),'horizontalalignment','center','verticalalignment','bottom');
end

if strcmpi(xvar,'date')
    datetick('x','keeplimits');
end


% set our projection to UTM zone 25 north
m_proj('utm','lon',[-33.4 -28],'lat',[66.8 68.53],'zone',25,'hem',0,'ell','wgs84');

% bot_dist=linspace(plot_x(1)-diff(plot_x([1,2])),...
%     plot_x(end)+diff(plot_x([end-1,end])),500);
bot_dist=linspace(0,plot_end_dist,500);
bot_lon=interp1(plot_x,lon,bot_dist,'linear','extrap');
bot_lat=interp1(plot_x,lat,bot_dist,'linear','extrap');

if ~isempty(grdfile)
    [mb.lon,mb.lat,mb.z]=load_grd(grdfile);
    bot_depth=interp2(mb.lon,mb.lat,-mb.z,bot_lon,bot_lat,'linear');
else
    load mb_all_20250512.mat
    [bot_x,bot_y]=m_ll2xy(bot_lon,bot_lat,'clip','off');
    bot_depth=interp2(mb.x,mb.y,-mb.z,bot_x,bot_y,'linear');
end
bot_ind=[1,find(~isnan(bot_depth),1):find(~isnan(bot_depth),1,'last'),length(bot_depth)];
bot_dist=bot_dist(bot_ind);
% bot_x=bot_x(bot_ind);
% bot_y=bot_y(bot_ind);
% bot_lon=bot_lon(bot_ind);
bot_lat=bot_lat(bot_ind);
bot_depth=bot_depth(bot_ind);
bot_depth([1,end])=0;
%bot_press=sw_pres(bot_depth,bot_lat);
bot_press=gsw_p_from_z(-bot_depth,bot_lat);% laura update to new GSW name 05/2026 (z must be negative)
bot_press_filled=fillmissing(bot_press,'linear');
bot_press_fills=bot_press_filled;
bot_press_fills(~isnan(bot_press))=nan;

patch(bot_dist([1:end,end,1,1]),[bot_press_filled,maxP,maxP,bot_press(1)],'k');
plot(bot_dist,bot_press_fills,'r--');

% xlim(plot_x([1,end]));
xlim(bot_dist([1,end]));
set(gca,'ydir','reverse');
% ylim([0 200]);


if make_chartlet
    figure;
    hold on;

    buffer_m=750;
    dlon=minmax(lon)+[-1 1].*buffer_m./1852./60./cos(mean(lat).*pi./180);
    dlat=minmax(lat)+[-1 1].*buffer_m./1852./60;
    [dx,dy]=m_ll2xy(dlon,dlat);
    axis([dx dy]);
    m_regrid;

    if isempty(grdfile)
        xind=find(mb.x>=dx(1),1):find(mb.x<=dx(2),1,'last');
        yind=find(mb.y>=dy(1),1):find(mb.y<=dy(2),1,'last');
        pcolor(mb.x(xind),mb.y(yind),-mb.z(yind,xind));
    else
        xind=find(mb.lon>=dlon(1),1):find(mb.lon<=dlon(2),1,'last');
        yind=find(mb.lat>=dlat(1),1):find(mb.lat<=dlat(2),1,'last');
        m_pcolor(mb.lon(xind),mb.lat(yind),-mb.z(yind,xind));
    end
    shading flat;
    m_plot(lon,lat,'k+');

    clim([0 500]);
    colormap((cmocean('deep')))
    m_usercoast('greenland_coast.mat','color','k');
    fprintf(1,'longitudes: %.4f %.4f\n',dlon);
    fprintf(1,'latitudes: %.4f %.4f\n',dlat);
    
end

MAP_PROJECTION=map_projection_backup;
MAP_VAR_LIST=map_var_list_backup;
MAP_COORDS=map_coords_backup;
