% Plot T-S diagrams for sections coloured by cast or depth? 
%
% Show all CTD casts in same figure for now. 
% Consider producing just sections? Or colour by sections? 
%
% Created 29/7/2026

%% Load paths
% here=pwd;
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
%% Load CTD data
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

nCast = length(ctds);
for n=1:nCast
    ctds(n).asal=gsw_SA_from_SP(ctds(n).salin,ctds(n).press,ctds(n).lon,ctds(n).lat);
    ctds(n).ct=gsw_CT_from_t(ctds(n).asal,ctds(n).temp,ctds(n).press);
end
sd_ctds=ctds;

% Create grid for sigma0 contours
Tmin=-2;
Tmax=10;
Smin=26.5;
Smax=35.6;
[Sg,Tg] = meshgrid(Smin:0.1:Smax,Tmin:0.2:Tmax);
sigma0 = gsw_sigma0(Sg,Tg);

alpha = 0.5;
%% Create figure, shaded by CTD cast
figure
hold on

for i = 1:nCast

    S = ctds(i).asal(:);
    T = ctds(i).ct(:);

    scatter(S,T,12,...
        repmat(i,length(S),1),...
        'filled',...
        'MarkerFaceAlpha',alpha);
end

colormap(flipud(cmocean('thermal')))
cb = colorbar;
cb.Label.String = 'CTD Number';

xlabel('Salinity')
ylabel('Temperature (°C)')
title('T-S Diagram coloured by Cast Number - all so far...')

grid on
box on

xlim([Smin, Smax])
ylim([Tmin, Tmax])

contour(Sg,Tg,sigma0,'k','ShowText','on')

set(gcf,'Position',[100 100 800 600])

exportgraphics(gcf,'SD063_TS_all_ctdnum.png','Resolution',300)

%% Figure coloured by depth? 

figure
hold on

for i = 1:length(ctds)

    S = ctds(i).asal(:);
    T = ctds(i).ct(:);
    P = ctds(i).press;

    scatter(S, T, 12, P, 'filled',...
        'MarkerFaceAlpha',alpha)

end

colormap(cmocean('haline'))
clim([0,800])
cb = colorbar;
cb.Label.String = 'Pressure (db)';

xlabel('Salinity')
ylabel('Temperature (°C)')
title('T-S Diagram coloured by Depth - all so far...')

grid on
box on

xlim([Smin, Smax])
ylim([Tmin, Tmax])

contour(Sg,Tg,sigma0,'k','ShowText','on')

set(gcf,'Position',[100 100 800 600])

exportgraphics(gcf,'SD063_TS_all_ctddepth.png','Resolution',300)
