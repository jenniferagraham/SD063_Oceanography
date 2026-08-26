function data=rvdas_listit(rtables,startdate,enddate,stream,fields,convert_positions)

% RVDAS_LISTIT (rtables, startdate, enddate, stream, fields, convert_positions)
% Gets data from an RVDAS table in a specified date range
%
% version 1.0 - 20220814 - Povl Abrahamsen, SD020 - initial version
% version 1.1 - 20221226 - Povl Abrahamsen, DY158 - update to disable 
%     position conversions on Disco, where this has already been done
% version 2.0 - 20231125 - Kat Turner and Jeremy Robst, SD033 - updated to use ODBC
% version 2.1 - 20240721 - Povl Abrahamsen, SD041 - fix lat/lon direction
%     on SDA, change to use native Postgresql interface

if nargin<5 || isempty(fields)
    fields=rtables.(stream); % include all variables
elseif ischar(fields)
    if strcmp(fields,'*')
        fields=rtables.(stream); % include all variables
    else
        fields={fields};
    end
end
if nargin<6
    convert_positions=true; % default for SDA
end

selectedVariablesStr = strjoin(fields, ', ');

% Connect to database
conn = postgresql(rtables.server_info.databasesource, ...
    rtables.server_info.username, rtables.server_info.password);

% Construct the SQL query
if isfield(rtables.server_info,'view') & ~strcmp(rtables.server_info.view,'sd')
    stream=strcat('rvdas_views.',stream);
end

sqlQuery = sprintf(strcat('SELECT time, %s ', ...
                    ' FROM %s ', ...
                    ' WHERE time >= ''%s'' AND time < ''%s'' ', ...
                    ' ORDER BY time ASC'), ...
                    selectedVariablesStr, stream, ...
                    datetime(startdate,'Format','yyyy-MM-dd HH:mm:SS'), ...
                    datetime(enddate,'Format','yyyy-MM-dd HH:mm:SS'))

% Read the data
dbds = databaseDatastore(conn, sqlQuery);
ds = readall(dbds);

% Close the connection
close(dbds);
conn.close();

% Parse the data

names = ds.Properties.VariableNames;

names = names(:);

names(1) = []; % variable 1 is always time - deal with it later
% units(1) = [];

% Make all variable names lowercase in mexec
ds.Properties.VariableNames = lower(ds.Properties.VariableNames);
names = lower(names);

% Convert time stamps - adapted from mexec code originally written by Brian King on JC211

ts = ds.time; % This is massively faster if we extract ts, and don't access ds.time inside the loop

if numel(ts) == 0

    data.time = nan(size(ts));
    data.year=data.time;
    data.time_jday=data.time;
    data.time_secs=data.time;

elseif class(ts)=='datetime' % we have a datetime object!

    data.time = convertTo(ts,'datenum');
    % variables for consistency with RVS "listit" scripts
    data.year=ts.Year;
    data.time_jday=data.time-datenum(data.year,1,1); % midnight on Jan 1 is 0
    data.time_secs=data.time_jday.*86400;

else

    if class(ts)=='char'
        ts={ts};
    end
    
    nt = length(ts);
    
    % padding strings
    e7 = '.000+00';
    e5 = '00+00';
    e4 = '0+00';
    
    cc = char(ts);
    
    % If ts is a single time, and is length < 26, eg when called from mrdfinfo, then 
    % cc won't have size 26. So pad it out.
    ccsize = size(cc);
    padsize = [ccsize(1) 26-ccsize(2)];
    if padsize(2) > 0
        pad = char(zeros(padsize)+double(' ')); %char array of spaces
        cc = [cc pad]; % Now cc is Nx26, if it wasn't before
    end
    
    kspace = strfind(cc(:,23)',' '); % find where column 22 is a space, and fix it
    for kl = kspace(:)'; cc(kl,20:26) = e7 ; end
    kspace = strfind(cc(:,25)',' ');
    for kl = kspace(:)'; cc(kl,22:26) = e5 ; end
    kspace = strfind(cc(:,26)',' ');
    for kl = kspace(:)'; cc(kl,23:26) = e4 ; end
    
    st1 = cc'; st1 = st1(:)';  % make a single long char array and read out of it.
    dall = sscanf(st1,'%4d-%2d-%2d %2d:%2d:%6f+%*2d'); % * means skip %2d
    dall = reshape(dall,[6 nt]); % Reshape to datevecs
    dall = dall';
    data.time = datenum(dall);

    % variables for consistency with RVS "listit" scripts
    data.year=dall(:,1);
    data.time_jday=data.time-datenum(data.year,1,1); % midnight on Jan 1 is 0
    data.time_secs=data.time_jday.*86400;

end

for kl = 1:length(names)
    data.(names{kl}) = ds.(names{kl}); % convert to structure
end

% Convert positions if requested and if found

if isfield(data,'latitude') && isfield(data,'latdir') % latitude variables found
    fprintf('in');
    if convert_positions
        lathc = char(data.latdir); lathc = lathc(:)';
        klats = [strfind(lathc,'s');strfind(lathc,'S')];
        data.latitude(klats)=-data.latitude(klats);
        data.latitude=fix(data.latitude./100)+...
            rem(data.latitude,100)./60;
    end
    data=rmfield(data,'latdir');
end

if isfield(data,'longitude') && isfield(data,'londir') % longitude variables found

    if convert_positions
        lonhc = char(data.londir); lonhc = lonhc(:)';
        klonw = [strfind(lonhc,'w');strfind(lonhc,'W')];
        data.longitude(klonw)=-data.longitude(klonw);
        data.longitude=fix(data.longitude./100)+...
            rem(data.longitude,100)./60;
    end
    data=rmfield(data,'londir');

end

disp(["finished running ", stream])
