clear

% Load variables
load('..\ctd_cals.m','-mat','ctd_files')
load('..\uw_cals.m','-mat','uw_files')
load('..\bottle_cals.m','-mat','bottle_files')

ctd_time = calculate_time(ctd_files.time_ctd);
bott_time = calculate_time(bottle_files.time);
temp_time = calculate_time(uw_files.time_temp);
salt_time = calculate_time(uw_files.time_salt);

% Extract variables
x_1 = uw_files.temp_1;
y_1 = ctd_files.temp_ctd - uw_files.temp_1;
y_1(y_1>-0.1)=nan;
x_2 = uw_files.temp_2;
y_2 = ctd_files.temp_ctd - uw_files.temp_2;
y_2(y_2>-0.15)=nan;

%% check temperature residuals against CTD temperature
figure;
[p_1, fit_1, valid_idx_1, residual_1] = plot_calibration(x_1,y_1, 1, 10);
[p_2, fit_2, valid_idx_2, residual_2] = plot_calibration(x_2,y_2, 27, 30);

ylabel("Temperature Difference (CTD-Und) (^{\circ}C)")
xlabel("Underway Temperature (^{\circ}C)")
title("UCSW Temperature Calibration")
legend("CTD - UCSW_1", "calibration UCSW_1", "CTD - UCSW_2", "calibration UCSW_2")
text_box = sprintf(['Slope 1: %.2f\nIntercept 1: %.2f\n' ...
    'Slope 2: %.2f\nIntercept 2: %.2f\n'], p_1(1), p_1(2), p_2(1), p_2(2));
annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', text_box, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');

%% check calibration against time
figure;
cm = colormap(wesMap('MoonriseSuzy'));

x = temp_time(temp_time>datetime(2025,2,20));
y = uw_files.temp_1(temp_time>datetime(2025,2,20));

valid_idx = ~isnan(y);
x_clean = x(valid_idx);
y_clean = y(valid_idx);

scatter(x_clean, y_clean.*p_1(1) + p_1(2), 40, cm(35, :), "pentagram")
hold on
scatter(ctd_time, y_1, 8, cm(35, :), 'filled')

y = uw_files.temp_2(temp_time>datetime(2025,2,20));
valid_idx = ~isnan(y);
x_clean = x(valid_idx);
y_clean = y(valid_idx);

scatter(x_clean, y_clean.*p_1(1) + p_1(2), 40, cm(110, :), "pentagram")
scatter(ctd_time, y_2, 8, cm(110, :), 'filled')

ylabel("Temperature Difference (CTD-Und) (^{\circ}C)")
xlabel("Time")
title("UCSW Temperature Calibration")
legend("UCSW_1 calibration","CTD - UCSW_1","UCSW_2 calibration","CTD - UCSW_2")

%% plot residual

cm = colormap(wesMap('MoonriseSam'));

figure;
scatter(x, residual_1(1:end-1), 20, cm(100, :), 'filled')
hold on
scatter(x, residual_2, 20, cm(30, :), 'filled')

ylim([-0.15 0.15])
ylabel("Residual")
xlabel("Time")
title("UCSW Temperature Calibration")
legend("UCSW_1 residual", "UCSW_2 residual")

yline(0,'--', 'LineWidth',2,'HandleVisibility', 'off');

%% calibrate the temperature

load(fullfile("..","sd046_ocl_30s_ave.mat"), "time", "temp1", "temp2")

cm = colormap(flipud(wesMap('Isle')));

x = datetime(time, "ConvertFrom", "datenum");
y_1 = temp1;
y_2 = temp2;

figure;
subplot(2,1,1)
temp1_cal = data_calibration(x, y_1, cm, 10, p_1);
title("UCSW_1 Temperature Calibrated")
ylim([-2 8])
legend("UCSW_1 calibrated", "UCSW_1 uncalibrated")


subplot(2,1,2)
temp2_cal = data_calibration(x, y_2, cm, 70, p_2);
title("UCSW_2 Temperature Calibrated")
ylim([-2 8])
xlabel("Time")
legend("UCSW_2 calibrated", "UCSW_2 uncalibrated")

function y_cal = data_calibration(x, y, cm, cm_val, p)

    valid_idx = ~isnan(y);
    x_clean = x(valid_idx);
    y_clean = y(valid_idx);
    y_cal = y_clean + (y_clean.*p(1) + p(2));
    
    scatter(x_clean, y_cal, 2, cm(cm_val, :), 'filled')
    hold on
    scatter(x_clean, y_clean, 2, cm(cm_val+35, :), "filled")

    ylabel("UCSW Temperature (^{\circ}C)")
end

function [p, y_fit, valid_idx, residual] = plot_calibration(x,y,c_1, c_2)

    % Remove NaN values
    valid_idx = ~isnan(x) & ~isnan(y);
    x_clean = x(valid_idx);
    y_clean = y(valid_idx);
    
    % Perform linear regression
    p = polyfit(x_clean, y_clean, 1); % Linear fit
    y_fit = polyval(p, x_clean);
    
    cm = colormap(wesMap('MoonriseSuzy'));
    
    % Plot scatter
    scatter(x_clean, y_clean, 10, cm(c_1, :), 'filled')
    hold on
    plot(x_clean, y_fit, 'Color', cm(c_2, :), 'LineWidth', 1) 
    
    for i = 1:length(x_clean)
        plot([x_clean(i), x_clean(i)], [y_clean(i), y_fit(i)], 'Color', cm(c_2,:), 'HandleVisibility', 'off') % Red dashed lines
    end

    p

    residual = y_clean - y_fit;
end

function time = calculate_time(jday)
    jday = floor(jday);
    remaining_time = jday - jday;
    time = datetime(2025,1,jday) + days(remaining_time);
end
