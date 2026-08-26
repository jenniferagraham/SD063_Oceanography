%MAKE_TOTAL_OCL Concatenate all underway (ocl - "Oceanlogger") tables
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

set_underway_params

for n=1:length(ocl_tables)
    concatenate_table('ocl',ocl_tables{n});
end
