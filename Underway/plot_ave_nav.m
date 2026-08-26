%PLOT_AVE_NAV Plot 30-s averaged navigation data files
%
%   version 1.0 - 20240813 - Povl Abrahamsen, SD041 - separated from MAKE_AVE_NAV

set_underway_params

for q=1:length(nav_sensor_sets)

    nav_ave_30s=load(fullfile('..',[cruisename,'_nav',nav_sensor_sets(q).file_add,'_30s_ave.mat']));

    figure;
    m_proj('mercator','lon',minmax(nav_ave_30s.longitude(:)')+[-2 2],...
        'lat',minmax(nav_ave_30s.latitude(:)')+[-2 2]);

    if diff(nav_ave_30s.time([1 end]))>14
        tick_days=1;
        label_days=7;
        timef='';
    elseif diff(nav_ave_30s.time([1 end]))>7
        tick_days=0.25;
        label_days=1;
        timef='';
    elseif diff(nav_ave_30s.time([1 end]))>2
        tick_days=.25;
        label_days=1;
        timef='HH:MM';
    else
        tick_days=1/24;
        label_days=1;
        timef='HH:MM';
    end

    m_track(nav_ave_30s.longitude,nav_ave_30s.latitude,nav_ave_30s.time,...
        'ticks',60*24*tick_days,'dates',60*24*label_days,...
        'timef',timef,'datef','dd/mm','color','r');

    % m_plot(nav_ave_30s.longitude,nav_ave_30s.latitude,'r--');

    hold on;
    m_gshhs_i('color','k');
    m_gebco2022_contour([-2000 -2000],'c-');
    m_gebco2022_contour([-4000 -4000],'b-');
    m_grid;
    xlabel Longitude
    ylabel Latitude

    title(nav_sensor_sets(q).set_name);

end