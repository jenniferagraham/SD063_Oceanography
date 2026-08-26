%PLOT_AVE_BATHY Plot 30-s averaged bathymetry data files
%
%   version 1.0 - 20240813 - Povl Abrahamsen, SD041 - separated from MAKE_AVE_BATHY

set_underway_params

bathy_ave_30s=load(fullfile('..',[cruisename,'_bathy_30s_ave.mat']));

figure;
h=[];
labels={};
hold on;

for n=1:length(bathy_sensor_sets)
    if ~isfield(bathy_ave_30s,[bathy_sensor_sets(n).set_name,'_depth'])
        continue;
    end
    h2=plot(datetime(bathy_ave_30s.time, 'ConvertFrom', 'datenum'),bathy_ave_30s.([bathy_sensor_sets(n).set_name,'_depth']),'-');
    h=[h,h2];
    labels{end+1}=[bathy_sensor_sets(n).set_name_long,' depth'];
    if bathy_sensor_sets(n).depth_is_uncorrected
        labels{end}=[labels{end},' (corrected)'];
        h2=plot(datetime(bathy_ave_30s.time, 'ConvertFrom', 'datenum'), bathy_ave_30s.([bathy_sensor_sets(n).set_name,'_depth_uncorr']),'--');
        h=[h,h2];
        labels{end+1}=[bathy_sensor_sets(n).set_name_long,' depth (uncorrected)'];
    end
end

legend(h,labels);
set(gca,'ydir','reverse')
if (median(diff(get(gca,'xtick')))==7)
    set(gca,'XMinorTick',6); % add daily ticks between weekly labels
end
