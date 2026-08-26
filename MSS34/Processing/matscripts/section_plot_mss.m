%Script to plot MSS sections
%
%Created 3.8.2026 by Laura C & Ellie Fisher
% uses functions sdaSectionParamsMSS, lldistkm,
close all;
clear all; clc
FZ=12;
set(0, 'DefaultAxesFontSize', FZ);
includemap=0;
%% Create parameter object
% ready choices
sectionName= '3msill_towyo'; % works well (does not exist anymore in the ParamsMSS- name change?)
%sectionName= '3minner_towyo'; %  acros fjord at the ice front (towyo, one cast per station) 
%sectionName= '3minner_mss';     % across fjord at the ice front (multiple casts per stations)
%sectionName= '3mtransect_mss'; % along fjord transect inner to the sill (mulstiple casts per station)
%sectionName= '3mtransect_inner_mss';
P = sdaSectionParamsMSS(sectionName);
% '3minner_towyo', 1 cast per station
% '3minner' , three casts per station
% 'all3m'  all casts - probably good for TS plot but not so much as a section plot
% '3mtransectinner' only in the inner part of the fjord (three casts per station)
% '3mtransectfront-sill' only in the inner part of the fjord (three casts per station)


%% define paths
cruise='SD063';

if ispc
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'

    disk = ['L:\work\scientific_work_areas\']; %
    ctddata = [disk,'oceanography\CTD\BASproc\'];

    msslogbook = [disk,'oceanography\MSS34\MSS_logbook_4matlab.csv'];
    mssdataP = [disk,'oceanography\MSS34\DATA\'];
    figpath = [disk,'oceanography\MSS34\Processing\Figures\'];
    gridpath= [disk,'\gis\bathymetry_grids\'];
    addpath([disk,'oceanography\matlabF\']) % theta_sdiag function
    addpath([disk,'oceanography\matlabF\m_map\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter function
else
    slash='/';
    disk = ['/Volumes/leg/work/scientific_work_areas/'];
    ctddata = [disk,'oceanography/CTD/BASproc/'];
    mssdataP = [disk,'oceanography/MSS34/DATA/'];
    figpath = [disk,'oceanography/MSS34/Processing/Figures/'];
    msslogbook = [disk,'oceanography/MSS34/MSS_logbook_4matlab.csv']; % Laura C created a new logbook easier for matlab use
    gridpath= [disk,'gis/bathymetry_grids/'];
    addpath([disk,'oceanography/matlabF/']) % theta_sdiag function
    addpath([disk,'oceanography/matlabF/m_map/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'oceanography/CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    bathyfile = ['/Volumes/leg/work/scientific_work_areas/oceanography/CTD/plot_transects/','mb_all_20250512.mat'];
    % addpath([disk,'oceanography/CTD/plot_transects/']) % create a similar one for MSS
end

%% load all mss data
load([mssdataP,cruise,'_mss.mat']);
allmss=[msss.station];
for n=1:length(allmss)
    if n==1;
        mssasal  = gsw_SA_from_SP(msss(n).data.sal,msss(n).data.press,msss(n).data.lat,msss(n).data.lon);
        mssct    = gsw_CT_from_t(msss(n).data.sal,msss(n).data.temp,msss(n).data.press);
    else
        mssct    = [mssct; gsw_CT_from_t(msss(n).data.sal,msss(n).data.temp,msss(n).data.press)];
        mssasal  = [mssasal; gsw_SA_from_SP(msss(n).data.sal,msss(n).data.press,msss(n).data.lat,msss(n).data.lon)];
    end
end
%% load all ctd data
load([ctddata,cruise,'_ctd.mat']);
for n=1:length(ctds)
    ctds(n).asal=gsw_SA_from_SP(ctds(n).salin,ctds(n).press,ctds(n).lon,ctds(n).lat);
    ctds(n).ct=gsw_CT_from_t(ctds(n).asal,ctds(n).temp,ctds(n).press);
end
sd_ctds=ctds;
allstations=[sd_ctds.station];

%% create a nan structure
nCast         = length(P.castlist);
section.press = nan(1000,nCast);
section.T     = nan(1000,nCast);
section.S     = nan(1000,nCast);
section.km    = nan(1000,nCast);
section.lat   = nan(1000,nCast);
section.lon   = nan(1000,nCast);
section.eps   = nan(1000,nCast);
section.sigt  = nan(1000,nCast);
%% loop and put data onto section structure
nstn  = P.stationlist;
minD=5; % cut the profiles at 5m
repeated = unique(nstn);
%if length(repeated)==length(nstn) % this is one cast per station
    for ii=1:length(P.castlist) % select range of casts for this section
        % load this cast data
        cast = P.castlist(ii);
        mssname= [cruise,sprintf('_mss_%03d_struct.mat',cast)];
        load ([mssdataP,mssname]); % loads data, sensors

        tmpPress = [mss.data.press];
        % cut the profiles at 5m
        minDidx = find([tmpPress-minD] == min(abs(tmpPress-minD)));
        clear tmpPress
        % keep the cast data for the desire depth range
        castPress = [mss.data.press(minDidx:end)];
        castT     = [mss.data.temp(minDidx:end)];
        castS     = [mss.data.sal(minDidx:end)];
        castEPS   = [mss.data.epsilon(minDidx:end)];   % in fasteps I do not think it is so good.
        castsigt  = [mss.data.sig_t(minDidx:end)];
        castlat   = mss.lat;
        castlon   = mss.lon;
        % absolute salinity and conservative temperature
        castasal  =[mss.data.asal(minDidx:end)];%gsw_SA_from_SP(castS,castPress,castlat,castlon);
        castct    =[mss.data.ct(minDidx:end)];%gsw_CT_from_t(castasal,castT,castPress);
        % calculate distance from the first station (left to right)
        if ii==1
            lat1 = castlat;
            lon1 = castlon;
        end
        % distance
        
        [d1km, d2km] = lldistkm([lat1 lon1],[castlat castlon]); % distance from the
        castdistll = d1km; %distance in km related to the first station
        plot_x(ii)=d1km; 
        plot_lon(ii) = castlon; 
        plot_lat(ii) = castlat; 
         if ii == length(P.castlist)
             plot_end_dist = castdistll;
             
         end
        % put cast data onto a section type matrix
        %rownumber(ii) = size(castEPS,1); % run once to determine the maximum
        rownumber= size(castEPS,1);
        % number of rows in the matrix\
        section.press(minD:rownumber+minD-1,ii)   = castPress;
        section.T(minD:rownumber+minD-1,ii)       = castT;
        section.S(minD:rownumber+minD-1,ii)       = castS;
        section.eps(minD:rownumber+minD-1,ii)     = castEPS;
        section.km(minD:rownumber+minD-1,ii)      = castdistll;
        section.lat(minD:rownumber+minD-1,ii)     = castlat;
        section.lon(minD:rownumber+minD-1,ii)     = castlon;
        section.sigt(minD:rownumber+minD-1,ii)    = castsigt;
    end
% else % must averaged all the casts at those stations
%     % working here must average cast with the same station number
%     nn=0; count=0;
%     for ii=1:length(P.stationlist)
%         if ii>nn % only go in if it is a new station
%             mymss = nstn(ii);
%             idx = find(nstn==mymss); % number of casts in this station
%             nn=idx(end);
%             count=count+1; % count the  number of stations in the section
%             castlist = P.castlist(idx); % cast numbers in this section
%             % create the temporal variable
%             tmpcasts.Press = nan(1000,length(castlist));
%             tmpcasts.T = nan(1000,length(castlist));
%             tmpcasts.EPS = nan(1000,length(castlist));
%             tmpcasts.sigt = nan(1000,length(castlist));
%             tmpcasts.asal = nan(1000,length(castlist));
%             tmpcasts.ct = nan(1000,length(castlist));
%             for ri=1:length(castlist) % looping cast
%                 mssname= [cruise,sprintf('_mss_%03d_struct.mat',castlist(ri))];
% 
%                 load ([mssdataP,mssname]); % loads data, sensors
% 
%                 tmpPress = [mss.data.press];
%                 % keep the cut casts
%                 dindx = find(tmpPress>minD);
%                 minDidx = find([tmpPress-minD] == min(abs(tmpPress-minD)));
%                 rownumber= size(tmpPress(dindx),1);
%                 clear tmpPress
%                 % keep the cast data for the desire depth range
%                 tmpcasts.Press(minD:rownumber+minD-1,ri)  = [mss.data.press(dindx)];
%                 tmpcasts.T(minD:rownumber+minD-1,ri)      = [mss.data.temp(dindx)];
%                 tmpcasts.S(minD:rownumber+minD-1,ri)      = [mss.data.sal(dindx)];
%                 tmpcasts.EPS(minD:rownumber+minD-1,ri)    = [mss.data.epsilon(dindx)];   % in fasteps I do not think it is so good.
%                 tmpcasts.sigt (minD:rownumber+minD-1,ri)  = [mss.data.sig_t(dindx)];
%                 tmpcastlat = mss.lat;
%                 tmpcastlon = mss.lon;
%                 tmpcast.asal(minD:rownumber+minD-1,ri) = [mss.data.asal(dindx)];%gsw_SA_from_SP(tmpcasts.S,tmpcasts.Press,tmpcastlat,tmpcastlon);
%                 tmpcast.ct(minD:rownumber+minD-1,ri)   = [mss.data.ct(dindx)];%gsw_CT_from_t(tmpcast.asal,tmpcasts.T,tmpcasts.Press);
%                 % calculate distance from the first station (left to right)
%                 if ii==1
%                     lat1 = castlat;
%                     lon1 = castlon;
%                 end
%                 % average the casts within the station
% 
% 
%             end
%             % keep the cast data for the desire depth range
%             castPress = [mss.data.press(minDidx:end)];
%             castT     = [mss.data.temp(minDidx:end)];
%             castS     = [mss.data.sal(minDidx:end)];
%             castEPS   = [mss.data.epsilon(minDidx:end)];   % in fasteps I do not think it is so good.
%             castsigt  = [mss.data.sig_t(minDidx:end)];
%             % add the lat-lon value for each cast
%             castidx = find(mssLogMSScast==cast);
%             castlat = msslogLat(castidx); % using inwater -probe would have gone straight down
%             castlon = msslogLon(castidx); % using inwater
%             % add absolute salinity and conservative temperature
%             castasal =gsw_SA_from_SP(castS,castPress,castlat,castlon);
%             castct   =gsw_CT_from_t(castasal,castT,castPress);
% 
%             % put the average cast data onto a section type matrix
%             [d1km, d2km] = lldistkm([lat1 lon1],[castlat castlon]); % distance from the
%             castdistll = d1km; %distance in km related to the first station
%             rownumber= size(castEPS,1);
%             % number of rows in the matrix\
%             section.press(minD:rownumber+minD-1,ii)   = castPress;
%             section.T(minD:rownumber+minD-1,ii)       = castT;
%             section.S(minD:rownumber+minD-1,ii)       = castS;
%             section.eps(minD:rownumber+minD-1,ii)  = castEPS;
%             section.km(minD:rownumber+minD-1,ii)   = castdistll;
%             section.lat(minD:rownumber+minD-1,ii)  = castlat;
%             section.lon(minD:rownumber+minD-1,ii)  = castlon;
%             section.sigt(minD:rownumber+minD-1,ii)  = castsigt;
%         end % end cast loop
% 
%     end % if
%end

%% in case there are cast repeated 
    [uniqueSTN ind]= unique(P.stationlist);

%% load bathymetry
load(bathyfile) % KANG-GLAC bathy file

%% crete the polygon mapping the bathemetry using our kANG-GLAC bathy file
% extract the maximum depth at the section to plot as a line on each panel
crs = projcrs(32625);   % WGS84 / UTM zone 25N the projecton of the bathyfile
[xe,yn] = projfwd(crs,plot_lat,plot_lon); % get the lat and on in xestern ynorthen - converts from WGS84 to  (UTM zone 25N)

xe = xe(:);
yn = yn(:);
bx = mb.x(:); % x estern of bathy file 
by = mb.y(:); % y northern of bathy file 
bz = mb.z(:); % depth 

bot_z = nan(size(xe));

for in = 1:length(xe)
    % Closest x coordinate
    [~,ix] = min(abs(bx - xe(in)));
    % Closest y coordinate
    [~,iy] = min(abs(by - yn(in)));
    % Corresponding bathymetry
    bot_z(in) = mb.z(iy,ix);
end
% Bathymetry polygon
x_bath = [plot_x(:); flipud(plot_x(:))];
%z_bath = [bot_z(:); zeros(size(bot_z(:)))];
maxy = P.maxy;
if isfield(P,'maxy')
    y_bottom = -P.maxy; % if this exist 
else
    y_bottom = min(bot_z)-200;   % bottom of current plot and made a thicker, bot_z is negative 
end
    z_bath = [bot_z(:);repmat(y_bottom,length(bot_z),1)];
%% Temporary
% to add map
% add TS plot with all station in the section in one color and the rest of
% the data collected on a different color.
f=figure;
stntriangles = zeros(size(section.km)); 
stntriangles(:)=-10; % albritary number 
if includemap==1; figPOS = [11 183 831 561]; else; figPOS = [63 126 436 560];end
set(f,'Position',figPOS)

if includemap==1; subplot(3,5,3:5);else; subplot(3,1,1); end

title (['MSS ',P.sectionname])
pcolor(section.km,section.press,section.T)
shading flat
set(gca,'YDir','reverse')
h=colorbar; h.Label.String = 'Temperature (^\circC)';
xlabel('Distance (km)')
ylabel('Pressure (dbar)')
cmocean('thermal')
caxis([P.tcaxis(1),P.tcaxis(2)])
ylim ([-10 P.maxy ])
%ylim ([-10 -(round(min(bot_z)))-50])
hold on ;
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')
plot(section.km,stntriangles,'vk','markerfacecolor','k')
text(section.km(10,ind), stntriangles(10,ind), string(P.stationlist(ind)),  'HorizontalAlignment','center',  'VerticalAlignment','bottom')

% add the seafloor 
hold on 
patch(x_bath, -z_bath, [0.7 0.7 0.7],'EdgeColor','none');


if includemap==0; subplot(3,1,2); else; subplot(3,5,8:10);end

pcolor(section.km,section.press,section.S)
shading flat
set(gca,'YDir','reverse')
h=colorbar; h.Label.String = 'Salinity (PSU)';
caxis([P.scaxis(1),P.scaxis(2)])
xlabel('Distance (km)')
ylabel('Pressure (dbar)')
ylim ([-10 P.maxy ])
%ylim ([-10 -(min(bot_z)-50])

cmocean('haline')
hold on
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')
% add station position 
plot(section.km,stntriangles,'vk','markerfacecolor','k')
text(section.km(10,ind), stntriangles(10,ind), string(P.stationlist(ind)),  'HorizontalAlignment','center',  'VerticalAlignment','bottom')
% add the seafloor 
hold on 
patch(x_bath, -z_bath, [0.7 0.7 0.7],'EdgeColor','none');

%
if includemap==1; subplot(3,5,13:15); else; subplot(3,1,3); end

pcolor(section.km,section.press,section.eps)
shading flat
hold on
plot([0 3],[10 10],'-k','linewidth',2);% what is usually removed due to deploying from a ship
set(gca,'YDir','reverse')
h=colorbar;
h.Label.String = 'log_{10}(\epsilon)';
xlabel('Distance (km)')
ylabel('Pressure (dbar)')
shading flat
ylim ([-10 P.maxy])
%ylim ([-10 -(round(min(bot_z)))-50])
caxis([P.epscaxis(1),P.epscaxis(2)])
% add density countour
contour(section.km,section.press,section.sigt,P.clevels,'k','ShowText','on')
plot(section.km,stntriangles,'vk','markerfacecolor','k')
text(section.km(10,ind), stntriangles(10,ind), string(P.stationlist(ind)),'HorizontalAlignment','center','VerticalAlignment','bottom')

%add the seafloor 
hold on 
patch(x_bath, -z_bath, [0.7 0.7 0.7],'EdgeColor','none');

%
if includemap==0
exportgraphics(gcf,[figpath,cruise,'_MSS_',sectionName,'.png'],'Resolution',300)
end
if includemap==1
    %load all ctd

    % T-S plot (will add density later)
    % Create grid for sigma0 contours
    Tmin=min([min(mssct) min(vertcat(sd_ctds(allstations).ct))]);
    Tmax=max([max(mssct) max(vertcat(sd_ctds(allstations).ct))]);
    Smin=min([min(mssasal) min(vertcat(sd_ctds(allstations).asal))]); 
    Smax=max([max(mssasal) max(vertcat(sd_ctds(allstations).asal))]);
    [Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
    sigma0 = gsw_sigma0(Sg,Tg);

    subplot(2,5,6:7) % top right - t/s
    % plot all the mss data
    plot(mssasal,mssct,'.','markersize',2,'color',[0.1 0.1 0.1]); hold on 

    %plot all the ctd data
    plot(vertcat(sd_ctds(allstations).asal),vertcat(sd_ctds(allstations).ct),'.','markersize',2,'color',[0.6 0.6 0.6]);

    % plot the section data
    scatter(section.S(:),section.T(:),10,section.eps(:),'fill'); caxis([P.epscaxis(1),P.epscaxis(2)])
    hold on
    contour(Sg,Tg,sigma0,'k','ShowText','on', 'HandleVisibility','off')
    box on

    % add the water masses LC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % I follow Rudels 2001 for all the definition, but I have made modifications to the density.
    % Reduce it because on the shelf watermasses seem lighter
    mysig0AWmin = 27.3; % adjusted from below 27.7 is Surface PW above it Arctic Atlantic Water
    mysig0PW    = 26.5;      % adjusted from 27.7 to create an intermediate water mass between PW and AAW
    mysig0AWmax = 29;   % adjusted from 27.97 above that likely Polar intermediate water
    % Mark the density contour at water masses boundaries
    %[C,h] = contour(si,thetai,dens,[mysig0AWmin mysig0AWmin],'k', 'LineWidth', 2); % denser is AW and less dense MAW
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

    %% Map for section location
    %subplot(2,5,1) % region - map
    %addmap_regional(section.lat,section.lon);
    subplot(2,5,1:2) % focus - map
    addmap_focus(section.lat,section.lon);
    m_text(plot_lon(ind), plot_lat(ind), string(P.stationlist(ind)),  'HorizontalAlignment','center',  'VerticalAlignment','bottom')

    exportgraphics(gcf,[figpath,cruise,'_MSS_',sectionName,'_withmap.png'],'Resolution',300)

end




