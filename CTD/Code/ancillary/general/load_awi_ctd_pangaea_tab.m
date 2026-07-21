function ctd=load_awi_ctd_pangaea_tab(fname)

fid=fopen(fname,'rt','n','UTF-8');

if ~strcmp(fgetl(fid),'/* DATA DESCRIPTION:')
    fclose(fid);
    error([fname,': Not an AWI tab-delimited data file?']);
end
nextline=fgetl(fid);
while ~strcmp(nextline,'*/')
    if strncmp(nextline,'Event(s)',8)
        n=1;
        event_text=nextline;
        while ~strncmp(nextline,'Parameter(s)',12) && ...
                ~strncmp(nextline,'Comment',7)
            [~,nextline]=strtok(['X',nextline],char(9)); %tab
            [eventname{n},nextline]=strtok(nextline(2:end),' ');
            altname{n}=strtok(nextline(3:end),')');
            n=n+1;
            nextline=fgetl(fid);
        end
        nevents=n-1;
    end
    nextline=fgetl(fid);
end
fields=textscan(fgetl(fid),'%s','delimiter','\t');
fields=fields{1};
formatstr='';
varname=cell(1,length(fields));
unitname=varname;
m=1;
for n=1:length(fields)
    [varstr,unitstr]=strtok(fields{n},'[');
    if varstr(end)==' ', varstr=varstr(1:end-1); end
    switch(varstr)
        case 'Event'
            formatstr=[formatstr,'%s']; %'%2s%d/%d-%d'];
            varname{m}='event';
%             varname{m}='cruise_prefix';
%             varname{m+1}='cruise_no';
%             varname{m+2}='station';
%             varname{m+3}='cast';
%             m=m+3;
        case 'Date/Time'
            formatstr=[formatstr,'%16s'];
            varname{m}='date';
        case 'Latitude'
            formatstr=[formatstr,'%f'];
            varname{m}='lat';
        case 'Longitude'
            formatstr=[formatstr,'%f'];
            varname{m}='lon';
        case 'Elevation'
            formatstr=[formatstr,'%f'];
            varname{m}='botdepth';
        case 'Depth water'
            formatstr=[formatstr,'%f'];
            varname{m}='depth';
        case 'Press'
            formatstr=[formatstr,'%f'];
            varname{m}='press';
        case 'Temp'
            formatstr=[formatstr,'%f'];
            varname{m}='temp';
        case 'Cond'
            formatstr=[formatstr,'%f'];
            varname{m}='cond';
        case 'Sal'
            formatstr=[formatstr,'%f'];
            varname{m}='salin';
        case 'Tpot'
            formatstr=[formatstr,'%f'];
            varname{m}='potemp';
        case 'Sigma-theta'
            formatstr=[formatstr,'%f'];
            varname{m}='sigma_theta';
        case {'NOBS','Sv'}
            formatstr=[formatstr,'%*f'];
            varname{m}='skip';
        case 'Attenuation'
            formatstr=[formatstr,'%f'];
            varname{m}='atten';
        case 'O2'
            formatstr=[formatstr,'%f'];
            varname{m}='ox';
        case 'O2 sat'
            formatstr=[formatstr,'%f'];
            varname{m}='oxsat';
        case 'Fluorometer'
            formatstr=[formatstr,'%f'];
            varname{m}='fluor';
        otherwise
            formatstr=[formatstr,'%*f'];
            varname{m}='skip';
            warning(['Unknown variable: ',varstr]);
    end
    if ~isempty(unitstr)
        unitname{m}=unitstr(2:end-1); %remove brackets
    end
    m=m+1;
end
fposbefore=ftell(fid);
data=textscan(fid,formatstr,'delimiter','\t','whitespace','Z');
if length(data{end})<1
    m=1;
    newformatstr='';
    while m<=length(varname)
        [tempformatstr,formatstr]=strtok(formatstr,'%');
        if length(data{m})<1
            newformatstr=[newformatstr,'%*c%',tempformatstr,formatstr];
            break;
        else
            newformatstr=[newformatstr,'%',tempformatstr];
            m=m+1;
        end
    end
    fseek(fid,fposbefore,'bof');
    data=textscan(fid,newformatstr,'delimiter','\t','whitespace','Z');
end

fclose(fid);

% if strncmp(eventname{1},'PS',2)
%   eventparts=textscan(char(eventname')','%2s%d/%d-%d');
%   if length(eventparts{4})<1
%     eventparts=textscan(char(altname')','%2s%d/%d');
%     eventparts{end+1}=ones(size(eventparts{end}));
%   end
% % elseif strncmp(eventname{1},'SWARP',5)
% %     eventparts=textscan(char(eventname')','%5s%d_%d-%d');
% else
%     numchars=find(~isletter(eventname{1}),1)-1;
%     eventparts=textscan(char(eventname')',['%',int2str(numchars),'s%d_%d-%d']);
% %     keyboard;
% end

numchars=find(~isletter(eventname{1}),1)-1;
if eventname{1}(numchars+1)=='_' % no cruise number, just name
    eventparts=textscan(char(eventname')',['%',int2str(numchars),'s_%d-%d']);
    eventparts={eventparts{1},[],eventparts{2:3}};
elseif eventname{1}(numchars+1)=='-' && eventname{1}(1)=='A' % old-style cruise number
    numchars=find(eventname{1}=='_',1)-1;
    eventparts=textscan(char(eventname')',['%',int2str(numchars),'s_%d-%d']);
    eventparts={eventparts{1},[],eventparts{2:3}};
else
    eventparts=textscan(char(eventname')',['%',int2str(numchars),'s%d/%d-%d']);
    if length(eventparts{4})<1
        eventparts=textscan(char(eventname')',['%',int2str(numchars),'s%d_%d-%d']);
    end
    if length(eventparts{4})<1 
        if strncmp(eventname{1},'PS',2)
            eventparts=textscan(char(altname')',['%',int2str(numchars),'s%d/%d']);
        else
            eventparts=textscan(char(eventname')',['%',int2str(numchars),'s%d_%d']);
        end
        eventparts{end+1}=ones(size(eventparts{end}));
    end
end

n=1;
% nrec=length(data{1});
cruise=strcat(eventparts{1},int2str(eventparts{2}));
for l=1:length(eventname)
    cast=struct('cruise',cruise{l},'station',eventparts{3}(l),...
        'cast',eventparts{4}(l));
    if strcmp(varname{1},'event')
        cast_ind=strmatch(eventname{l},data{1},'exact');
    else
        cast_ind=1:length(data{1}); %full length of file
        % extract metadata from header:
        while(length(event_text>0))
            [new_item,event_text]=strtok(event_text,'*');
            [key,value]=strtok(new_item,':');
            value=strtrim(value(2:end));
            switch(strtrim(key))
                case 'LONGITUDE'
                    cast.lon=str2double(value);
                case 'LATITUDE'
                    cast.lat=str2double(value);
                case 'DATE/TIME'
                    cast.date=datenum(value,'yyyy-mm-ddTHH:MM');
                case 'ELEVATION'
                    cast.botdepth=-str2double(strtok(value)); % skip units
            end
        end
    end
    for m=1:length(varname)
        switch(varname{m})
            case {'event','cruise_prefix','cruise_no','station','cast','skip'} %station indentifier variables
                continue;
            case {'lon','lat'} %station variables
                cast.(varname{m})=data{m}(cast_ind(1));
            case 'botdepth' %change from negative to positive!
                cast.(varname{m})=-data{m}(cast_ind(1));
            case 'date'
                cast.(varname{m})=datenum(data{m}(cast_ind(1)),'yyyy-mm-ddTHH:MM');
            otherwise %cast variables
                cast.(varname{m})=data{m}(cast_ind);
                cast.(varname{m})(cast.(varname{m})==-9.9999)=nan;
        end
        if ~isempty(unitname{m})
            cast.([varname{m},'_unit'])=unitname{m};
        end
    end
    if ~isfield(cast,'press') || isempty(cast.press)
        if isfield(cast,'depth') && ~isempty(cast.depth)
            cast.press=sw_pres(cast.depth,cast.lat);
            cast.press_unit='dbar';
        else
            warning('No depth or pressure in station!');
        end
    end
    if ~isfield(cast,'temp') || isempty(cast.temp)
        if isfield(cast,'potemp') && ~isempty(cast.potemp) && ...
                isfield(cast,'salin') && ~isempty(cast.salin)
            cast.temp=sw_temp(cast.salin,cast.potemp,cast.press,0);
            cast.temp_unit=cast.potemp_unit;
        else
            warning('No temperature or salininty in station?!');
        end
    end
    ctd(n)=cast;
    n=n+1;
end

