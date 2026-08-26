function concatenate_table(theprefix,thetable)
%CONCATENATE_TABLE Concatenates all data for a RVDAS table to a single file
%
%   CONCATENATE_TABLE (theprefix, thetable)
%
%   Finds all data files for a specified RVDAS table, and concatenate to a
%   single file. Preferentially uses calibrated, cleaned files.
%
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - initial version
%   version 1.1 - 20240813 - Povl Abrahamsen, SD041 - remove NaN timestamps
%   version 1.2 - 20241213 - Povl Abrahamsen, post-SD033 - convert any
%       cellstrs to char arrays for storage efficiency, and avoid version
%       7.3 mat-files if possible

thefiles=dir(fullfile('..',theprefix,thetable,...
    [thetable,'_*.mat']));
o=1;
for m=1:length(thefiles)
    if endsWith(thefiles(m).name,'_all.mat') || endsWith(thefiles(m).name,'_orig.mat')
        continue;
    end
    if endsWith(thefiles(m).name,'_clean.mat') && ...
        exist(fullfile(thefiles(m).folder,[thefiles(m).name(1:end-4),'_cal.mat']),'file')
            continue;
    end
    if exist(fullfile(thefiles(m).folder,[thefiles(m).name(1:end-4),'_clean.mat']),'file') || ...
        exist(fullfile(thefiles(m).folder,[thefiles(m).name(1:end-4),'_cal.mat']),'file')
            continue
    end
    load(fullfile(thefiles(m).folder,thefiles(m).name));
%     if isfield(eval(thetable),'time_1')
%         eval([thetable,'=rmfield(',thetable,',{''time_1'',''sensorid'',''messageid''});']);
%     end
    fprintf(1,'Adding file %s\n',thefiles(m).name);
    if o==1
        data=eval(thetable);
    else
        data=eval(['catstruct(data,',thetable,');']);
    end
    o=o+1;
end
if ~exist('data','var')
    warning('no data for table %s',thetable)
    return;
end
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
thefields=fieldnames(data);
for n=1:length(thefields)
    if iscellstr(data.(thefields{n}))
        data.(thefields{n})=cell2mat(data.(thefields{n}));
    end
end
eval([thetable,'=data;'])
fname_out=fullfile('..',theprefix,thetable,[thetable,'_all.mat']);
save(fullfile('..',theprefix,thetable,...
    [thetable,'_all.mat']),thetable);
finfo_out=dir(fname_out);
if isempty(finfo_out) || finfo_out.bytes<1000
    % that didn't work - let's try the other file format
    save(fullfile('..',theprefix,thetable,...
        [thetable,'_all.mat']),thetable,'-v7.3');
end
