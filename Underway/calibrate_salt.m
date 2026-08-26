clear
close all

% Load variables
load('..\ctd_cals.m','-mat','ctd_files')
load('..\uw_cals.m','-mat','uw_files')
load('..\bottle_cals.m','-mat','bottle_files')

ctd_time = calculate_time(ctd_files.time_ctd);
bott_time = calculate_time(bottle_files.time);
salt_time = calculate_time(uw_files.time_salt);

y = bottle_files.salt_measured - bottle_files.salt_uw;
x = bottle_files.time';

valid_idx = ~isnan(x) & ~isnan(y);
y_clean = y(valid_idx);

int_1_bott = mean(y_clean(bott_time<datetime(2025,3,11)));
int_2_bott = mean(y_clean(bott_time>datetime(2025,3,11)));

cm = colormap(wesMap('Chevalier'));

idx = find(bott_time > datetime(2025,3,11),1,"first");

plot_difference(bott_time, y_clean, cm, int_1_bott, int_2_bott, idx)

ylabel("Salinity Difference (Bottle-Thermosalinograph)")
xlabel("Time")
title("UCSW Salinity Calibration from Bottles")
legend("Bottle - TSG", "calibration < 11 March 2025", "calibration > 11 March 2025")
text_box = sprintf(['Calibration < 11 March 2025: %.3f\n' ...
    'Calibration > 11 March 2025: %.3f\n'], int_1_bott, int_2_bott);
annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', text_box, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');


%% calibrate with CTD next
y_ctd = ctd_files.salt_ctd - uw_files.salt;
x_ctd = ctd_files.time_ctd;
time_ctd = salt_time;

int_1_ctd = mean(y_ctd(time_ctd<datetime(2025,3,10,12,0,0)), "omitnan");
int_2_ctd = mean(y_ctd(time_ctd>datetime(2025,3,10,12,0,0)), "omitnan");

idx_ctd = find(time_ctd == datetime(2025,3,12) ,1, "first");

cm = colormap(wesMap('Budapest'));

plot_difference(time_ctd, y_ctd, cm, int_1_ctd, int_2_ctd, idx_ctd)

ylabel("Salinity Difference (CTD-Thermosalinograph)")
xlabel("Time")
title("UCSW Salinity Calibration from CTD")
legend("CTD - TSG", "calibration < 11 March 2025", "calibration > 11 March 2025")
text_box = sprintf(['Calibration < 11 March 2025: %.3f\n' ...
    'Calibration > 11 March 2025: %.3f\n'], int_1_bott, int_2_bott);
annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', text_box, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');

%% apply calibration
load(fullfile("..","sd046_ocl_30s_ave.mat"), "time","salin")

cm = colormap(flipud(wesMap('ZissouExtreme')));

apply_calibration(datetime(time, "ConvertFrom", "datenum"), salin, cm, int_1_bott, int_2_bott, int_1_ctd, int_2_ctd)


%% plot the figure
function plot_difference(x, y_clean, cm, int_1, int_2, idx)

    figure;
    scatter(x, y_clean, 10, cm(20, :), 'filled')
    hold on
    plot([x(1), x(idx)], [int_1, int_1], 'Color', cm(50,:), "LineWidth", 2)
    plot([x(idx), x(end)], [int_2 int_2], 'Color', cm(100,:), "LineWidth", 2)
    
    for i = 1:length(x)
        if x(i) < datetime(2025,3,12)
            plot([x(i), x(i)], [y_clean(i), int_1], 'Color', cm(70,:), 'HandleVisibility', 'off') 
        else
            plot([x(i), x(i)], [y_clean(i), int_2], 'Color', cm(70,:), 'HandleVisibility', 'off')
        end  
    end
end


function apply_calibration(x, y, cm, cal_1, cal_2, cal_3, cal_4)
    y_cal_bott = zeros(1, length(y));
    y_cal_bott(x<=datetime(2025,3,11)) = y(x<=datetime(2025,3,11)) + cal_1;
    y_cal_bott(x>datetime(2025,3,11)) = y(x>datetime(2025,3,11)) + cal_2;

    y_cal_ctd = zeros(1, length(y));
    y_cal_ctd(x<=datetime(2025,3,11)) = y(x<=datetime(2025,3,11)) + cal_3;
    y_cal_ctd(x>datetime(2025,3,11)) = y(x>datetime(2025,3,11)) + cal_4;
    
    figure;
    scatter(x, y, 1, cm(20, :), 'filled')
    hold on
    scatter(x, y_cal_bott, 1, cm(55, :), "filled")
    scatter(x, y_cal_bott, 1, cm(100, :), "filled")
    
    ylabel("Salinity")
    xlabel("Time")
    title("UCSW Salinity Calibration")
    legend("Salinity", "Salinity calibrated from bottle measurements", "Salinity calibrated from CTD")

end

function time = calculate_time(jday)
    jday = floor(jday);
    remaining_time = jday - jday;
    time = datetime(2025,1,jday) + days(remaining_time);
end
