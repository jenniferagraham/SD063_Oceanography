

%% Define paths

% path on leg drive to Vessel-mounted ADCP data as processed by University
% Hawaii
sadcp_input_dir='/Volumes/leg/system/adcp_teledyne_ocean_surveyor/acquisition/uhdas/data/SD063_part2/proc/os75nb/contour';
% path on leg within scientific_work_areas where the postprocessing of
% LADCP data happens; the file name needs to be 'SDA_sadcp.mat' and is
% within a folder called 'converted_input'
sadcp_output_dir='/Volumes/leg/work/scientific_work_areas/oceanography/LADCP/Postprocessing_LDEO_IX_15beta/converted_input/';

%% loadsadcp.m expects the following variables

other=load(fullfile(sadcp_input_dir,'allbins_other.mat'));
% tim_sadcp(t) - Julian Days
tim_sadcp=other.TIME;
tim_sadcp=juliandate(tim_sadcp);
% lat_sadcp(t) - Degrees N
lat_sadcp=other.LAT;
% lon_sadcp(t) - Degrees E
lon_sadcp=other.LON;           
% u_sadcp(z,t) - m/s
u_sadcp=load(fullfile(sadcp_input_dir,'allbins_u.mat'));
u_sadcp=u_sadcp.U;
% v_sadcp(z,t) - m/s
v_sadcp=load(fullfile(sadcp_input_dir,'allbins_v.mat'));
v_sadcp=v_sadcp.V;
% z_sadcp(z,1) - Meter (Positive Depth) 
z_sadcp=load(fullfile(sadcp_input_dir,'allbins_depth.mat'));
z_sadcp=z_sadcp.DEPTH(:, 1);


save(fullfile(sadcp_output_dir, 'SDA_sadcp.mat'), 'tim_sadcp', ...
    'lat_sadcp', 'lon_sadcp', 'u_sadcp', 'v_sadcp', 'z_sadcp')

