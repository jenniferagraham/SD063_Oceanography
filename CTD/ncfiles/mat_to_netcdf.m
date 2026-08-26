%% ============================================================
%  Create NetCDF file from CTD structure
%
%  Input:
%       ctds = 1 x 261 structure array
%
%  Dimensions:
%       station = number of CTD stations
%       sample  = 3500 samples per station/depth bins per station
%
%  Profile variables are stored as:
%       (station, sample/depth)
%
%  Station metadata are stored as:
%       (station)
%
%  Time:
%       cast_time is stored as MATLAB datenum, consistent with MSS files.
%
% =============================================================
% first version Laura C coaching ChatGPT
%  modified by Laura C. 

%%
clearvars -except ctds
redo=1; 

ncrilepath = './';
matpath = '/Volumes/leg/work/scientific_work_areas/oceanography/CTD/BASproc/';

%% 1. Load the CTD structure variable
matfile = [matpath,'SD063_ctd.mat'];
load(matfile)
% The structure is called:
% ctds
%% 2. Name of output NetCDF file
% Basic dimensions
nstation = length(ctds);
nsample  = length(ctds(1).press);
stationnumber = ctds.station; 
startSTN = min(stationnumber); 
endSTN   = max(stationnumber); 

% file name 
ncfile = [ncrilepath,'SD063_ctds.nc'];

% Delete old file if it already exists
if isfile(ncfile)
    delete(ncfile)
end


%% 3. Get variables CTDs structure

% Variables
MetadataVariables  = fieldnames(ctds);

% variables with only one dimension 
onedimensionVars = {
    'lat'
    'lon'
    'tide_height_zh'
    'tide_rising_rate_mpday'
    'tide_phase_fraction'
    'gtime'
    'names'
    'station'
    };
% Remove these from the list of profile variables
MetadataVariables = setdiff(MetadataVariables, onedimensionVars, 'stable');

% Basic dimensions
nstation = length(ctds);
nsample  = length(ctds(1).press);


%% ============================================================
%  4. Metadata for variables
% =============================================================

meta = struct();

meta.press.long_name = 'Sea water pressure';
meta.press.units     = 'dbar';
meta.press.comment   = 'prDM: Pressure, Digiquartz [db].';

meta.depth.long_name = 'Depth';
meta.depth.units     = 'm';
meta.depth.comment   = 'Depth estimate from CTD pressure sensor.';

meta.temp.long_name = 'Sea water temperature';
meta.temp.units     = 'degC';
meta.temp.comment   = 'Average of temperature sensors 1 and 2';

meta.salin.long_name = 'Practical salinity';
meta.salin.units     = 'psu';
meta.salin.comment   = 'Average of practical salinity calculated from conductivity sensors 1 and 2';

meta.Ctemp.long_name = 'Conservative Temperature';
meta.Ctemp.units     = 'degC';
meta.asalin.comment  = 'Estimated using GSW matlab package'; 


meta.asalin.long_name = 'Absolute Salinity';
meta.asalin.units     = 'g kg-1';
meta.asalin.comment  = 'Estimated using GSW matlab package'; 


meta.potemp.long_name = 'Potential temperature';
meta.potemp.units     = 'degC';
meta.potemp.comment  = 'Estimated using GSW matlab package'; 

meta.sigma0.long_name = 'Potential density anomaly referenced to 0 dbar';
meta.sigma0.units     = 'kg m-3';

meta.sigma2.long_name = 'Potential density anomaly referenced to 2000 dbar';
meta.sigma2.units     = 'kg m-3';

meta.sigma4.long_name = 'Potential density anomaly referenced to 4000 dbar';
meta.sigma4.units     = 'kg m-3';

% ============================================================
%  CTD-specific variables
% =============================================================

meta.cond1.long_name = 'Conductivity sensor 1';
meta.cond1.units     = 'S m-1';
meta.cond1.comment   = 'c0mS/cm: Conductivity [mS/cm]';

meta.cond2.long_name = 'Conductivity sensor 2';
meta.cond2.units     = 'S m-1';
meta.cond2.comment   = 'c1mS/cm: Conductivity, 2 [mS/cm]';

meta.temp1.long_name = 'Temperature sensor 1';
meta.temp1.units     = 'degC';
meta.temp1.comment   = 't090C: Temperature [ITS-90, deg C]';

meta.temp2.long_name = 'Temperature sensor 2';
meta.temp2.units     = 'degC';
meta.temp2.comment   = 't190C: Temperature, 2 [ITS-90, deg C]';

meta.salin1.long_name = 'Practical salinity sensor 1';
meta.salin1.units     = 'psu';
meta.salin1.comment = 'Practical salinity estimated from conductivity sensor 1';

meta.salin2.long_name = 'Practical salinity sensor 2';
meta.salin2.units     = 'psu';
meta.salin2.comment = 'Practical salinity estimated from conductivity sensor 2';

meta.potemp1.long_name = 'Potential temperature sensor 1';
meta.potemp1.units     = 'degC';

meta.potemp2.long_name = 'Potential temperature sensor 2';
meta.potemp2.units     = 'degC';

meta.oxygen1_umol_kg.long_name = 'Dissolved oxygen sensor 1';
meta.oxygen1_umol_kg.units     = 'umol kg-1';
meta.oxygen1.comment   = 'sbox0Mm/Kg: Oxygen, SBE 43 [umol/kg]';

meta.oxygen2_umol_kg.long_name = 'Dissolved oxygen sensor 2';
meta.oxygen2_umol_kg.units     = 'umol kg-1';
meta.oxygen2.comment   = 'sbox1Mm/Kg: Oxygen, SBE 43, 2 [umol/kg]';

meta.oxygen_umol_kg.long_name = 'Dissolved oxygen';
meta.oxygen_umol_kg.units     = 'umol kg-1';

meta.fluor_ug_l.long_name = 'Chlorophyll-a fluorescence';
meta.fluor_ug_l.units     = 'ug L-1';
meta.fluor_ug_l.comment   = 'flC: Fluorescence, Chelsea Aqua 3 Chl Con [ug/l]';

meta.par.long_name = 'Photosynthetically active radiation';
meta.par.units     = 'umol photons m-2 s-1';
meta.par.comment   = 'par: PAR/Irradiance, Biospherical/Licor [umol photons/m^2/sec]';

meta.BeamTrans.long_name = 'Beam transmission';
meta.BeamTrans.units     = 'percent';
meta.BeamTrans.comment   = 'CStarTr0: Beam Transmission, WET Labs C-Star [%]'; 

meta.alt.long_name = 'Altitude';
meta.alt.units     = 'm';
meta.alt.comment   = 'altM: Altimeter [m]';

meta.latscan.long_name = 'Latitude';
meta.latscan.units     = 'degrees_north';

meta.lonscan.long_name = 'Longitude';
meta.lonscan.units     = 'degrees_east';

meta.time_elapsed.long_name = 'Elapsed time since start of CTD cast';
meta.time_elapsed.units     = 's';

meta.scan.long_name = 'CTD scan number';
meta.scan.units     = '1';

meta.flag.long_name = 'CTD data quality flag';
meta.flag.units     = '1';
meta.flag.comment   = 'flag:  0.000e+00';

meta.pumps.long_name = 'CTD pump status';
meta.pumps.units     = '1';
meta.pumps.comment   = 'pumps: Pump Status';

meta.ladcp_u.long_name = 'LADCP eastward velocity';
meta.ladcp_u.units     = 'm s-1';

meta.ladcp_v.long_name = 'LADCP northward velocity';
meta.ladcp_v.units     = 'm s-1';

% ============================================================
%  Station-level variables
% =============================================================

meta.station.long_name = 'CTD station number';
meta.station.units     = '1';

meta.lat.long_name = 'Latitude';
meta.lat.units     = 'degrees_north';

meta.lon.long_name = 'Longitude';
meta.lon.units     = 'degrees_east';

meta.tide_height_zh.long_name = 'Tidal height relative to chart datum';
meta.tide_height_zh.units     = 'm';

meta.tide_rising_rate_mpday.long_name = 'Tidal rising rate';
meta.tide_rising_rate_mpday.units     = 'm day-1';

meta.tide_phase_fraction.long_name = 'Tidal phase fraction';
meta.tide_phase_fraction.units     = '1';

%% 7. Create the sample dimension


nccreate(ncfile,'station', ...
    'Dimensions',{'station',nstation}, ...
    'Datatype','int32');

nccreate(ncfile,'press', ...
    'Dimensions',{'press',nsample}, ...
    'Datatype','int32');

% Write dimensions

ncwrite(ncfile,'station',1:nstation);
ncwrite(ncfile,'press',1:nsample);

ncwriteatt(ncfile,'station','long_name','CTD station number');
ncwriteatt(ncfile,'press','long_name','Pressure bins within CTD cast');


%% ============================================================
%  Create profile variables and add them 
% =============================================================
for i = 1:length(MetadataVariables)

    var = MetadataVariables{i};
    
    nccreate(ncfile,var, ...
        'Dimensions',{'station',nstation,'sample',nsample}, ...
        'Datatype','double');

    ncwriteatt(ncfile,var,'long_name',meta.(var).long_name);
    ncwriteatt(ncfile,var,'units',meta.(var).units);

    if isfield(meta.(var),'comment')
        ncwriteatt(ncfile,var,'comment',meta.(var).comment);
    end

end

for i = 1:length(MetadataVariables)

    var = MetadataVariables{i};

    data = NaN(nstation,nsample);

    for s = 1:nstation
        data(s,:) = ctds(s).(var)(:).';
    end

    ncwrite(ncfile,var,data);

end
%% ============================================================
%  Create and write station-level variables
% =============================================================

stationVars = {
    'lat'
    'lon'
    'tide_height_zh'
    'tide_rising_rate_mpday'
    'tide_phase_fraction'
    };

for i = 1:length(stationVars)

    var = stationVars{i};

    nccreate(ncfile,var, ...
        'Dimensions',{'station',nstation}, ...
        'Datatype','double');

    ncwriteatt(ncfile,var,'long_name',meta.(var).long_name);
    ncwriteatt(ncfile,var,'units',meta.(var).units);

end

for i = 1:length(stationVars)

    var = stationVars{i};

    data = arrayfun(@(x) x.(var),ctds);

    ncwrite(ncfile,var,data);

end

%% ============================================================
%  Cast time
% =============================================================

cast_time = arrayfun(@(x) ...
    datenum(x.gtime(1),x.gtime(2),x.gtime(3), ...
            x.gtime(4),x.gtime(5),x.gtime(6)), ctds);
nccreate(ncfile,'cast_time', ...
    'Dimensions',{'station',nstation}, ...
    'Datatype','double');

ncwrite(ncfile,'cast_time',cast_time);

ncwriteatt(ncfile,'cast_time','long_name', ...
    'Date and time of CTD cast');

ncwriteatt(ncfile,'cast_time','units', ...
    'MATLAB datenum');

ncwriteatt(ncfile,'cast_time','comment', ...
     'Stored as MATLAB datenum (days since 0-Jan-0000). Convert using datetime(cast_time,''ConvertFrom'',''datenum'').');


%% ============================================================
% 12.   Global metadata
% =============================================================

ncwriteatt(ncfile,'/','title', ...
    'CTD observations');

ncwriteatt(ncfile,'/','summary', ...
    ['Hydrographic and biogeochemical observations collected during ', ...
     'CTD casts using a stainless-steel CTD rosette equipped with ', ...
     'conductivity, temperature, pressure, dissolved oxygen, ', ...
     'fluorescence, PAR, beam transmission, and ADCP.']);

ncwriteatt(ncfile,'/','processing_level', ...
    'Processed CTD data');

ncwriteatt(ncfile,'/','comment', ...
    'Data are provided as processed CTD profiles. Each station contains 3500 depth bins.');

ncwriteatt(ncfile,'/','Conventions','CF-1.8');


%% 14. Display the resulting NetCDF

ncdisp(ncfile)
