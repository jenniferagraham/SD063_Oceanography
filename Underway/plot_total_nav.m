function plot_total_nav

%PLOT_TOTAL_NAV Plot concatenated navigation file
%
%   Plots concatenated navigation file. Not generalised.
%
%   version 1.0 - 20140425 - Jesse Cusack, JR299 - initial version "plot_seatex_all"
%   version 1.1 - 20220818 - Povl Abrahamsen, SD020 - adapted for SDA RVDAS

load ../nav/seapathpos_ingga/seapathpos_ingga_all.mat

N = 100;

seapathpos_ingga=cutstruct(seapathpos_ingga,1:N:length(seapathpos_ingga.latitude));

figure;
m_proj('mercator','lon',minmax(seapathpos_ingga.longitude(:)')+[-2 2],...
    'lat',minmax(seapathpos_ingga.latitude(:)')+[-2 2]);
m_plot(seapathpos_ingga.longitude,seapathpos_ingga.latitude,'r--');
hold on;
m_gshhs_i('color','k');
m_gebco2022_contour([-2000 -2000],'c-');
m_gebco2022_contour([-4000 -4000],'b-');
% m_plot(seapathpos_ingga.longitude,seapathpos_ingga.latitude,'r--', 'linewidth', 2);
m_grid;
xlabel Longitude
ylabel Latitude

% legend(gca,{'cruise track','coast','2000m','4000m'},'location','eastoutside')

