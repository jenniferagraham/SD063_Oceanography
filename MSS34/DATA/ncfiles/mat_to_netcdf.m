%% Convert one MSS FastEps MAT file to NetCDF
% MSS .mat --> NetCDF
% Template for one MSS cast
% first version Laura C coaching ChatGPT
%  modified by Laura. 
clear
clc

redo=1; 

ncrilepath = './ncfiles/';

for ii=1:55
%% 1. Load the MSS cast
caststr = sprintf('%03d',ii);
matfile = ['SD063_mss_',caststr,'_struct.mat'];
clear mss
load(matfile)

% The structure is called:
% mss


%% 2. Name of output NetCDF file

ncfile = [ncrilepath,'SD063_mss_',caststr,'.nc'];

% Delete old file if it already exists
if isfile(ncfile)
    delete(ncfile)
end


%% 3. Get variables and units from the MSS structure

% Variables originally defined by FastEps
sensors = mss.sensors;
units   = mss.units;

% All variables actually present in mss.data
dataNames = fieldnames(mss.data);


%% 4. Define human-readable long names

longNames.press = ...
    'Sea water pressure';
comment.press = ...
    'Pressure values are processed and averaged onto a 0.5 dbar interval during FastEps processing.';

longNames.epsilon1 = ...
    'Raw/unfiltered TKE dissipation rate calculated purely from Shear Probe 1.';

longNames.epsilon2 = ...
    'Raw/unfiltered TKE dissipation rate calculated purely from Shear Probe 2.';

longNames.temp = ...
    'Temperature';

longNames.cond = ...
    'Electrical conductivity';

longNames.acc = ...
    'Horizontal acceleration';

longNames.vel = ...
    'Profiler velocity';

longNames.time = ...
    'Elapsed time';

longNames.peps = ...
    'Processed turbulent kinetic energy dissipation rate.';
comment.peps ='The final, high-quality dissipation rate processed using FastEPS. This is the column you typically use for scientific analysis and plotting.';

longNames.epsilon = ...
    'Raw/unfiltered TKE dissipation rate- a standard mathematically averaged dissipation rate between the two probes.';

longNames.sal = ...
    'Practical Salinity';

longNames.sig_t = ...
    'Density anomaly';

longNames.dens = ...
    'Reordered density';

longNames.bvf = ...
    'Squared Brunt-Vaisala frequency';


% Variables added during subsequent processing

longNames.corrsal = ...
    'Corrected Practical Salinity';

longNames.asal = ...
    'Absolute Salinity';

longNames.ct = ...
    'Conservative Temperature';


%% 5. Define units for variables added after FastEps
% post processing
extraUnits.corrsal = 'psu';
extraUnits.asal    = 'g kg-1';
extraUnits.ct      = 'degC';


%% 6. Number of samples

n = length(mss.data.press);


%% 7. Create the sample dimension

nccreate(ncfile, 'sample', ...
    'Dimensions', {'sample', n});


%% 8. Create and write each data variable

for i = 1:length(dataNames)

    name = dataNames{i};

    % Get data from mss.data
    x = mss.data.(name);

    % Create NetCDF variable
    nccreate(ncfile, name, ...
        'Dimensions', {'sample', length(x)}, ...
        'Datatype', 'double');

    % Write data
    ncwrite(ncfile, name, x);


    %% Units

    % Is this one of the original FastEps variables?
    sensorIndex = find(strcmp(sensors, name), 1);

    if ~isempty(sensorIndex)

        % Unit comes directly from mss.units
        unit = units{sensorIndex};

    elseif isfield(extraUnits, name)

        % Unit for variables added later
        unit = extraUnits.(name);

    else

        % No unit known
        unit = '';

    end

    if ~isempty(unit)
        ncwriteatt(ncfile, name, 'units', unit);
    end


    %% Long name

    if isfield(longNames, name)

        ncwriteatt(ncfile, name, ...
            'long_name', longNames.(name));

    end

end


%% 9. Add information about the salinity correction

ncwriteatt(ncfile, 'corrsal', 'comment', ...
    'Practical Salinity corrected using an offset determined from comparison with ship CTD measurements.');


%% 10. Add latitude, longitude and station

nccreate(ncfile, 'latitude', ...
    'Datatype', 'double');

ncwrite(ncfile, 'latitude', mss.lat);

ncwriteatt(ncfile, 'latitude', ...
    'long_name', 'Latitude');

ncwriteatt(ncfile, 'latitude', ...
    'units', 'degrees_north');


nccreate(ncfile, 'longitude', ...
    'Datatype', 'double');

ncwrite(ncfile, 'longitude', mss.lon);

ncwriteatt(ncfile, 'longitude', ...
    'long_name', 'Longitude');

ncwriteatt(ncfile, 'longitude', ...
    'units', 'degrees_east');


nccreate(ncfile, 'cast', ...
    'Datatype', 'double');

ncwrite(ncfile, 'cast', mss.station);

ncwriteatt(ncfile, 'cast', ...
    'long_name', 'cast number');


%% 11. Cast time
cast_time = datestr(mss.time, 'yyyy-mm-ddTHH:MM:SS');
comment.casttime = [cast_time, ...
    ' | cast_time is stored as MATLAB datenum (days since 0-Jan-0000). ', ...
    'Convert using datestr(cast_time) or datetime(cast_time,''ConvertFrom'',''datenum'').'];

nccreate(ncfile, 'cast_time', ...
    'Datatype', 'double');

ncwrite(ncfile, 'cast_time', mss.time);

ncwriteatt(ncfile, 'cast_time', ...
    'long_name', 'Cast time');

ncwriteatt(ncfile, 'cast_time', ...
    'units', 'MATLAB datenum');

ncwriteatt(ncfile, 'cast_time', ...
    'comment', ...
    comment.casttime);

%% 12. Global metadata

ncwriteatt(ncfile, '/', 'title', ...
    'MSS microstructure profiler data');

ncwriteatt(ncfile, '/', 'instrument', ...
    'MSS - Microstructure and Shear profiler');

ncwriteatt(ncfile, '/', 'processing', ...
    'Data processed using FastEps (MSSpro).');

ncwriteatt(ncfile, '/', 'processing_description', ...
    'MSS profile processed using the standard FastEps processing procedure.');

ncwriteatt(ncfile, '/', 'data_source', ...
    'MSSpro FastEps processed data');


%% 13. Pressure information

ncwriteatt(ncfile, 'press', 'comment', ...
    'Pressure coordinate of the FastEps-processed profile, with data averaged over 0.5 dbar intervals.');


%% 14. Display the resulting NetCDF

ncdisp(ncfile)
end