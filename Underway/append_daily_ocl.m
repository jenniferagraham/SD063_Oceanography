function append_daily_ocl(daynumber,yy)
%APPEND_DAILY_OCL Append daily oceanlogger tables to concatenated file
%
%   APPEND_DAILY_OCL (daynumber, year)
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version

if nargin<2
    dt_now = datetime('now'); 
    yy = mod(year(dt_now), 100);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end

    if jday_now<120 && daynumber>240
        yy=yy-1;
    end
end

set_underway_params

for n=1:length(ocl_tables)
    append_table('ocl',ocl_tables{n},daynumber,yy);
end
