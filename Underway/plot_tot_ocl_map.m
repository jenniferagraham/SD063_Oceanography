function plot_tot_ocl_map(startday, endday, yy)
% PLOT_TOT_OCL_MAP Generates oceanographic parameter maps over a given time period.
%
% This function loads ship navigation data, temperature, salinity, and fluorescence
% data from predefined MAT files. It filters data within the specified date range 
% (startday to endday) and interpolates oceanographic variables to match the ship’s 
% timestamps. The results are plotted as maps with ship tracks overlaid.
%
% Usage:
%   plot_tot_ocl_map(startday, endday, yy)
%
% Inputs:
%   startday - (optional) Julian day of the year to start filtering data
%   endday   - (optional) Julian day of the year to end filtering data
%   yy       - (optional) Year in two-digit format (e.g., 25 for 2025)
%
% If startday, endday, or yy are not provided, the function prompts the user 
% for input and defaults to the first and last available days in the dataset
%
% VERSION 1.0 - Kat Turner SD046 03/2025

    close all;
    clear

    % Load navigation and oceanographic data
    load(fullfile('..', 'nav', 'gnss_kongsberg_seapath_320_port1_ingga', ...
                'gnss_kongsberg_seapath_320_port1_ingga_all.mat'));
    load(fullfile('..', 'ocl', 'thermometer_seabird_sbe38_ucsw1_psbsst1', ...
                'thermometer_seabird_sbe38_ucsw1_psbsst1_all.mat'));
    load(fullfile('..', 'ocl', 'thermosalinograph_seabird_sbe45_ucsw1_psbtsg1', ...
                'thermosalinograph_seabird_sbe45_ucsw1_psbtsg1_all.mat'));
    load(fullfile('..', 'ocl', 'fluorometer_wetlabs_wschl_ucsw1_pwlfluor1', ...
                'fluorometer_wetlabs_wschl_ucsw1_pwlfluor1_all.mat'));
    load(fullfile('..', 'ocl', 'transmissometer_wetlabs_cstar_ucsw1_pwltran1', ...
                'transmissometer_wetlabs_cstar_ucsw1_pwltran1_all.mat'));

    % Assign datasets to variables for clarity
    ship_data = gnss_kongsberg_seapath_320_port1_ingga;
    temp_data = thermometer_seabird_sbe38_ucsw1_psbsst1;
    salt_data = thermosalinograph_seabird_sbe45_ucsw1_psbtsg1;
    fluor_data = fluorometer_wetlabs_wschl_ucsw1_pwlfluor1;
    trans_data = transmissometer_wetlabs_cstar_ucsw1_pwltran1';

    % Convert time from datenum to datetime format for easier handling
    ship_data.time = datetime(ship_data.time, 'ConvertFrom', 'datenum');
    temp_data.time = datetime(temp_data.time, 'ConvertFrom', 'datenum');
    salt_data.time = datetime(salt_data.time, 'ConvertFrom', 'datenum');
    fluor_data.time = datetime(fluor_data.time, 'ConvertFrom', 'datenum');
    trans_data.time = datetime(trans_data.time, 'ConvertFrom', 'datenum');

    % Determine cruise year and Julian day range
    if nargin < 3
        yy = mod(year(datetime('now')), 100);
    end

    jday_start = round(ship_data.time_jday(1));
    jday_end = round(ship_data.time_jday(end));

    if nargin < 2
        fprintf(['Start of the cruise: jday %d.\n' ...
                 'Most recent day: jday %d.\n' ...
                 'Western core box: jday 43-51.\n' ...
                 'A23: jday 51-61.\n' ...
                 ''], jday_start, jday_end);
        startday = input('Input start jday (blank for first day): ');
        endday = input('Input end jday (blank for last day): ');
    end

    if isempty(startday) 
        start_date = datetime(2000+yy,1,jday_start);
    else
        start_date = datetime(2000+yy,1,startday);
    end
        
    if isempty(endday)
        end_date = datetime(2000+yy,1,jday_end+1);
    else
        end_date = datetime(2000+yy,1,endday+1);
    end
    
    % Filter ship data
    valid_idx = (ship_data.time >= start_date) & (ship_data.time <= end_date);
    ship_data = structfun(@(x) x(valid_idx, :), ship_data, 'UniformOutput', false);

    % Interpolate sensor data onto ship timestamps
    temp_interp = interp1(temp_data.time, temp_data.temperature, ship_data.time, 'linear', 'extrap');
    salt_interp = interp1(salt_data.time, salt_data.salinity, ship_data.time, 'linear', 'extrap');
    fluor_interp = interp1(fluor_data.time, fluor_data.chlorophyll_conc, ship_data.time, 'linear', 'extrap');
    trans_interp = interp1(trans_data.time, trans_data.transmittance, ship_data.time, 'linear', 'extrap');

    % Plot data
    plot_over_track(ship_data, temp_interp, 0, 4, 'dense', 'Ocean Temperature at the hull (^{\circ}C)');
    plot_over_track(ship_data, salt_interp, 33.2, 34, '-thermal', 'Salinity from the Uncontaminated Sea Water Lab');
    plot_over_track(ship_data, fluor_interp, 0, 1, 'algae', 'Chlorophyll A fluorescence (mg m^{-3})');
    plot_over_track(ship_data, trans_interp, 90, 100, 'turbid', 'Transmittance (%)');

end

%%%%%%%%%%% PLOTTING FUNCTION %%%%%%%%%%%%%%
function plot_over_track(ship_data, variable, minvar, maxvar, colormap, plot_name)
% PLOT_OVER_TRACK Plots oceanographic data along the ship's track on a map.
%
% This function creates a geographic plot of an oceanographic parameter 
% (e.g., temperature, salinity, fluorescence) along the ship’s track.
%
% Inputs:
%   ship_data - Struct containing ship navigation data (latitude, longitude, time)
%   variable  - Interpolated oceanographic parameter values along the track
%   minvar    - Minimum value for the color scale
%   maxvar    - Maximum value for the color scale
%   colormap  - Colormap name for visualization (e.g., 'dense', '-thermal', 'algae')
%   plot_name - Title of the plot
%
% The function overlays bathymetry contours and plots the ship track as a scatter plot.
%
% Inspired by plot_daily_nav written by Povl Abrahamsen
% VERSION 1.0 - Kat Turner SD046 03/2025

    load(fullfile('..','..','SatelliteImages','A23_BASMAGIC_10032025.mat'))

    
    figure;
    m_proj('mercator', 'lon', minmax(ship_data.longitude(:)') + [-1 1], ...
                        'lat', minmax(ship_data.latitude(:)') + [-1 1]);
    
    hold on;
    m_gshhs_i('patch', 'k');
    m_gebco2022_contour([-500 -500],'Color', [0 0.5 0.7]);
    m_gebco2022_contour([-2000 -2000],'Color', [0 0.7 0.7]);
    m_gebco2022_contour([-4000 -4000],'Color', [0 0.9 0.7]);

    m_patch(A23A_10032025.lon,A23A_10032025.lat,'k')
   
    m_scatter(ship_data.longitude, ship_data.latitude, 20, variable, 'filled');
    
    colorbar;
    cmocean(colormap);
    clim([minvar maxvar]);
    title(plot_name);
    %m_grid('box', 'fancy', 'tickdir', 'out');
    m_grid;
    
     
    % shiplon=-39.257;
    % shiplat=-55.289;
    % 
    % plot(shiplon,shiplat,'r.','MarkerSize',20)

    % Find indices for half-hour intervals
    half_hour_idx = find(mod(minute(ship_data.time), 30) == 0);
    
    % Plot markers at half-hour intervals
    % for i = 1:length(half_hour_idx)
    %     idx = half_hour_idx(i);
    %     m_plot(ship_data.longitude(idx), ship_data.latitude(idx), 'ko', 'MarkerSize', 2, 'MarkerFaceColor', 'k');
    % end
    % Extract unique Julian days and filter every 5th day
    % unique_days = unique(round(ship_data.time_jday));  % Round to nearest day
    % label_days = unique_days(mod(unique_days, 2) == 0); % Keep every 5th day
    % % 
    % % Find indices of corresponding ship track points
    % for i = 1:length(label_days)
    %     idx = find(round(ship_data.time_jday) == label_days(i), 1, 'first'); % Get first occurrence
    %     if ~isempty(idx)
    %         m_text(ship_data.longitude(idx), ship_data.latitude(idx), ...
    %                sprintf('%d', label_days(i)), 'FontSize', 10, 'Color', 'k', 'FontWeight', 'bold');
    %     end
    % end
end

