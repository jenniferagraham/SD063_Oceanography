


stn = 21


%% Load data
% path of LADCP data from CTD station number defined above processed ...
% without using VMADCP data
file_wo_VMADCP=sprintf(['/Volumes/leg/work/scientific_work_areas/' ...
    'oceanography/LADCP/Postprocessing_LDEO_IX_15beta/' ...
    'processed_withVMADCP/%03d/' ...
    'SD063_data_%03d.mat'], stn, stn);
% path of LADCP data from CTD station number defined above processed ...
% using VMADCP data
file_VMADCP=sprintf(['/Volumes/leg/work/scientific_work_areas/' ...
    'oceanography/LADCP/Postprocessing_LDEO_IX_15beta/' ...
    'processed_withVMADCP/%03d_using_VMADCP/' ...
    'SD063_data_%03d.mat'], stn, stn);


ds_wo_VMADCP = load(fullfile(file_wo_VMADCP));
ds_wo_VMADCP = ds_wo_VMADCP.dr;
ds_VMADCP = load(fullfile(file_VMADCP));
ds_VMADCP = ds_VMADCP.dr;

%% Plots

fig = figure(1);
clf
fig.Units = 'centimeters';
fig.Position = [5 5 30 15];   % [left bottom width height]

subplot(1, 4, 1)
plot(ds_wo_VMADCP.u, -ds_wo_VMADCP.z, 'r', 'LineWidth', 1.5,...
    'DisplayName', 'wo using VMADCP')
hold on
plot(ds_VMADCP.u, -ds_VMADCP.z, 'b', 'LineWidth', 1.5,...
    'DisplayName', 'using VMADCP')
hold on
xline(0, 'k--', 'DisplayName', '0 line')
xlabel('u (m/s)', FontSize=12);
ylabel ('Depth (m)', FontSize=12);
annotation('textbox', [0.1 0.94 0.50 0.05], 'String', ...
    sprintf('LADCP data from CTD station %03d', stn), ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontSize',14, 'FontWeight', 'bold');
legend('FontSize', 10, NumColumns = 3, Position=[0.2 0.001 0.2 0.04])

subplot(1, 4, 2)
plot(ds_wo_VMADCP.v, -ds_wo_VMADCP.z, 'r', 'LineWidth', 1.5)
hold on
plot(ds_VMADCP.v, -ds_VMADCP.z, 'b', 'LineWidth', 1.5)
hold on
xline(0, 'k--')
xlabel('v (m/s)', FontSize=12);


subplot(1, 4, 3)
h1 = plot(ds_VMADCP.u-ds_wo_VMADCP.u, -ds_wo_VMADCP.z, 'k',...
     'LineWidth', 1.5);
xlabel('u (m/s)', FontSize=12);
lgd = legend('Location','northoutside');
lgd.Position(1) = lgd.Position(1) + 0.2;

subplot(1, 4, 4)
plot(ds_VMADCP.v-ds_wo_VMADCP.v, -ds_wo_VMADCP.z, 'k',...
    'LineWidth', 1.5);
xlabel('v (m/s)', FontSize=12);

lgd = legend(h1, ...
    {'using VMADCP - without using VMADCP'}, ...
    'Orientation','horizontal', FontSize=10);
lgd.Position = [0.57 0.95 0.3 0.04];  % [left bottom width height]

fname = sprintf(['/Volumes/leg/work/scientific_work_areas/' ...
    'oceanography/LADCP/Plots_check_using_VMADCP/' ...
    'SD063_%03d_LADCP_comparison_using_VMADCP.png'], stn);
exportgraphics(fig, fname, 'Resolution', 300)
