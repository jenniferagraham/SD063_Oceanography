function [gtime,data,names,lat,lon]=cnv2mat(cnv_file);

% CNV2MAT Reads the SeaBird ASCII .CNV file format
%
%  Usage:   [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
%
%     Input:  cnv_file = name of .CNV file  (e.g. 'cast002.cnv')
%
%     Output: lon = longitude in decimal degrees, West negative
%             lat = latitude in decimal degrees, North positive
%           gtime = Gregorian time vector in UTC
%            data = matrix containing all the columns of data in the .CNV file
%           names = string matrix containing the names and units of the columns
%         sensors = string matrix containing the names of the sensors
%
%  NOTE: How lon,lat and time are written to the header of the .CNV
%        file may vary with CTD setup.  For our .CNV files collected on 
%        the Oceanus, the lat, lon & time info look like this:
%
%    * System UpLoad Time = Mar 30 1998 18:48:42
%    * NMEA Latitude = 42 32.15 N
%    * NMEA Longitude = 069 28.69 W
%    * NMEA UTC (Time) = 23:50:36
%
%  Modify the lat,lon and date string handling if your .CNV files are different.

%  4-8-98  Rich Signell (rsignell@usgs.gov)  
%     incorporates ideas from code by Derek Fong & Peter Brickley
%  2001 - includes modifications by Kate Stansfield to accept binary files
%  2023 - modified by Povl Abrahamsen to fix time handling on RRS Discovery
%  2024 - modified by Povl Abrahamsen to support SBE19+V2 (SeaCat) data files,
%     allow coordinates in decimal degrees, and exit cleanly with an error if 
%     the data file is misssing.

% Open the .cnv file as read-only text
%
  fid=fopen(cnv_file,'rt');

  if fid<1
      error('File %s does not exist',cnv_file);
  end

% 
% Read the header.
% Start reading header lines of .CNV file,
% Stop at line that starts with '*END*'
%
% Pull out NMEA lat & lon along the way and look
% at the '# name' fields to see how many variables we have.
%
str='*START*';
while (~strncmp(str,'*END*',5));
     str=fgetl(fid);
%-----------------------------------
%
%    Read the NMEA latitude string.  This may vary with CTD setup.
%
     if (strncmp(str,'* NMEA Lat',10))
        is=findstr(str,'=');
        isub=is+2:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(findstr(str(isub),'N'))
           lat=dm(1)+dm(2)/60;
        else  
           lat=-(dm(1)+dm(2)/60);
        end
%-------------------------------
%
%    Read the NMEA longitude string.  This may vary with CTD setup.
%
     elseif (strncmp(str,'* NMEA Lon',10))
        is=findstr(str,'=');
        isub=is+2:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(findstr(str(isub),'E'))
           lon=dm(1)+dm(2)/60;
        else  
           lon=-(dm(1)+dm(2)/60);
        end
%-------------------------------
%
%    Read the manual latitude string.  This may vary with CTD setup.
%
     elseif (strncmp(str,'** Latitude',11))
        if exist('lat','var') % don't overwrite the NMEA latitude
           continue;
        end
        is=findstr(str,':');
        isub=is+2:length(str);
        dm=sscanf(str(isub),'%f',2);
        if length(dm)<2 % decimal degrees
           lat=dm;
        elseif (findstr(upper(str(isub)),'N'))
           lat=dm(1)+dm(2)/60;
        elseif (findstr(upper(str(isub)),'S'))
           lat=-(dm(1)+dm(2)/60);
        else
           lat=dm(1)+sign(dm(1))*abs(dm(2))/60;
        end
%-------------------------------
%
%    Read the manual longitude string.  This may vary with CTD setup.
%
     elseif (strncmp(str,'** Longitude',12))
        if exist('lon','var') % don't overwrite the NMEA longitude
           continue;
        end
        is=findstr(str,':');
        isub=is+2:length(str);
        dm=sscanf(str(isub),'%f',2);
        if length(dm)<2 % decimal degrees
           lon=dm;
        elseif (findstr(upper(str(isub)),'E'))
           lon=dm(1)+dm(2)/60;
        elseif (findstr(upper(str(isub)),'W'))
           lon=-(dm(1)+dm(2)/60);
        else
           lon=dm(1)+sign(dm(1))*abs(dm(2))/60;
        end

%------------------------
%
%    Read the 'System upload time' to get the date.
%           This may vary with CTD setup.
%
%    This is useful if we are using older files without the date in the
%    NMEA time string. Or if there are no NMEA data. 
%
     elseif (strncmp(str,'* System UpLoad',15))
        is=findstr(str,'=');
%    convert date string to Julian time
        n=datenum(str(is+2:end),'mmm dd yyyy HH:MM:SS');
        gtime=datevec(n);

%------------------------
%
%    Read the 'start_time' to get the date.
%           This is not normally used in real-time profiling CTD files, but 
%           is used in moored and internally recording SBE instruments. 
%           Sometimes, if NMEA is available, only the time will be correct, 
%           and the date will be 1 Jan 2000!
     elseif (strncmp(str,'# start_time',12))
        is=findstr(str,'=');
%    convert date string to Julian time
        n=datenum(str(is+2:end),'mmm dd yyyy HH:MM:SS');
        gtime_new=datevec(n);
        if ~all(isnan(gtime)) && isequalwithequalnans([2000 1 1],gtime_new(1:3))
            % use our upload/NMEA date if available
            gtime(4:6)=gtime_new(4:6);
        else
            gtime=gtime_new;
        end

%----------------------------
%
%    Read the NMEA TIME string.  This may vary with CTD setup.
%
%      replace the System upload time with the NMEA time
     elseif (strncmp(str,'* NMEA UTC',10))
        is=findstr(str,'=');
        if length(str) > (is+12) %we have a date!
%    convert date string to Julian time
            n=datenum(str(is+2:end),'mmm dd yyyy HH:MM:SS');
            gtime=datevec(n);
        else %time only - use date from upload time
            is=findstr(str,':');
            if isempty(is) || ~exist('gtime','var')
                continue;
            end
            isub=is(1)-2:length(str);
            gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
        end
%------------------------------
%
%    Read the variable names & units into a cell array
%
     elseif (strncmp(str,'# name',6))  
        var=sscanf(str(7:10),'%d',1);
        var=var+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff variable names into cell array
      names{var}=str;
%------------------------------
%
%    Read the sensor names into a cell array
%
     elseif (strncmp(str,'# sensor',8))  
        sens=sscanf(str(10:11),'%d',1);
        sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff sensor names into cell array
      sensors{sens}=str;
      
%
%  pick up bad flag value
     elseif (strncmp(str,'# bad_flag',10))  
        isub=13:length(str);
        bad_flag=sscanf(str(isub),'%g',1);
     elseif (strncmp(str,'# file_type',11))  
        isub=15:length(str);
        filetype=sscanf(str(isub),'%s',1);
     elseif (strncmp(str,'# nvalues',9))  
        isub=12:length(str);
        nvalues=sscanf(str(isub),'%g',1);
     end
end
%==============================================
%
%  Done reading header.  Now read the data!
%
nvars=var;  %number of variables

% Read the data into one big matrix
%
if (strncmp(filetype,'binary',6)==1)
   	data=fread(fid,[nvars nvalues],'float32');
else
    data=fscanf(fid,'%f',[nvars nvalues]);
end

fclose(fid);

%
% Flag bad values with nan
%
ind=find(data==bad_flag);
data(ind)=data(ind)*nan;

%
% Flip data around so that each variable is a column
data=data.';

% Convert cell arrays of names to character matrices
names=char(names);
%sensors=char(sensors);

return
