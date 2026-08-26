%MAKE_TOTAL_NAV Concatenate all navigation tables
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

set_underway_params

for n=1:length(nav_tables)
    concatenate_table('nav',nav_tables{n});
end
