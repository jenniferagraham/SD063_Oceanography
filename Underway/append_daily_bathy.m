function append_daily_bathy(daynumber,yy)
%APPEND_DAILY_BATHY Append daily echo sounder tables to concatenated file
%
%   APPEND_DAILY_BATHY (daynumber, year)
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

if nargin<2
    dt_now = datetime('now'); 
    yy = year(dt_now);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end
end

set_underway_params

for n=1:length(bathy_tables)
    append_table('bathy',bathy_tables{n},daynumber,yy);
end
