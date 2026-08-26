%MAKE_TOTAL_BATHY Concatenate all echo sounder tables
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

set_underway_params

for n=1:length(bathy_tables)
    concatenate_table('bathy',bathy_tables{n});
end
