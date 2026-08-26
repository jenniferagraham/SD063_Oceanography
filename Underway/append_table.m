function append_table(theprefix,thetable,daynumber,yy)
%APPEND_TABLE Append daily data for a RVDAS table to the concatenated file
%
%   APPEND_TABLE (theprefix, thetable, daynumber, yy)
%
%   Appends the daily data for a specified RVDAS table to the concatenated 
%   file. Preferentially uses calibrated, cleaned files.
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%
%   If the data are already in the file, you will be asked if you want to
%   overwrite them.
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version
%   version 1.1 - 20240813 - Povl Abrahamsen, SD041 - remove NaN timestamps
%   version 1.2 - 20241213 - Povl Abrahamsen, post-SD033 - avoid version
%       7.3 mat-files if possible

if nargin<4
    dt_now = datetime('now'); 
    yy = mod(year(dt_now), 100);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<3
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end
end

all_file=fullfile('..',theprefix,thetable,[thetable,'_all.mat']);

rawfile=fullfile('..',theprefix,thetable,sprintf('%s_%.2d%.3d.mat',thetable,mod(yy,100),daynumber));
cleanfile=fullfile('..',theprefix,thetable,sprintf('%s_%.2d%.3d_clean.mat',thetable,mod(yy,100),daynumber));
calfile=fullfile('..',theprefix,thetable,sprintf('%s_%.2d%.3d_cal.mat',thetable,mod(yy,100),daynumber));
cleancalfile=fullfile('..',theprefix,thetable,sprintf('%s_%.2d%.3d_clean_cal.mat',thetable,mod(yy,100),daynumber));

if exist(cleancalfile,'file')
    load(cleancalfile);
    file_used=cleancalfile;
elseif exist(calfile,'file')
    load(calfile);
    file_used=calfile;
elseif exist(cleanfile,'file')
    load(cleanfile);
    file_used=cleanfile;
elseif exist(rawfile,'file')
    load(rawfile);
    file_used=rawfile;
else
    warning('No data found to append for %s',thetable);
    return;
end

newdata=eval(thetable);

if isempty(newdata.time)
    warning('New data file for %s is empty. Not appending.',thetable);
    return;
end

if ~exist(all_file,'file')
    warning('No existing data file for %s',thetable);
    copyfile(file_used,all_file);
    return
end

load(all_file);
olddata=eval(thetable);

if olddata.time(end)>newdata.time(1)
    fprintf(1,'Already have data beyond jday %.2d%.3d.\n',yy,daynumber);
    c=input('Overwrite end of old data? (y/N) ','s');
    if isempty(c) || lower(c)~='y'
        return;
    end
    fprintf(1,'Removing end of old data file.\n')
    olddata=cutstruct(olddata,1:find(olddata.time>=newdata.time(1),1));
end

if (newdata.time(1)-olddata.time(end))>=1
    warning('There is a gap of %.1f days before the appended file.',...
        newdata.time(1)-olddata.time(end));
end

fprintf(1,'Adding file %s\n',file_used);

data=catstruct(olddata,newdata);

[~,ind]=unique(data.time); % look for duplicate time stamps
if length(ind)~=length(data.time)
    warning('duplicate time stamps in %s',thetable);
    if any(isnan(data.time))
        warning('NaN time stamps in %s',thetable);
        ind=setdiff(ind,find(isnan(data.time)));
    end
    data=cutstruct(data,ind);
elseif any(isnan(data.time))
    warning('NaN time stamps in %s',thetable);
    data=cutstruct(data,find(~isnan(data.time)));
end
eval([thetable,'=data;'])
save(all_file,thetable);
finfo_all_file=dir(all_file);
if isempty(finfo_all_file) || finfo_all_file.bytes<1000
    % that didn't work - let's try the other file format
    disp("Saving with v7.3")
    save(all_file,thetable,'-v7.3');
end
