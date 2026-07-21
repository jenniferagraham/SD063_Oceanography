function ctd=load_bodc_ctd_exchange_ascii(fname)

fid=fopen(fname,'rt');

skiplines(3);
headerline=fgetl(fid);
if ~strncmp(headerline,'BODC Request Format',19)
    error([fname,': Not a BODC CTD file?']);
end
nheaders=str2double(headerline(50:52));
skiplines(1);
headerline=fgetl(fid);
ctd.station=cell2mat(textscan(headerline(3:34),'CTD%d'));
headerline=fgetl(fid);
headerpos=sscanf(headerline(1:40),'%3dd%fm%c%3dd%fm%c');
ctd.lat=headerpos(1)+headerpos(2)/60;
if strcmpi(char(headerpos(3)),'S')
    ctd.lat=-ctd.lat;
end
ctd.lon=headerpos(4)+headerpos(5)/60;
if strcmpi(char(headerpos(6)),'W')
    ctd.lon=-ctd.lon;
end
ctd.date=datenum(headerline(47:end),'yyyymmddHHMMSS');
skiplines(nheaders-2);

vars=textscan(fgetl(fid),'%s');vars=vars{1};
% units=textscan(fgetl(fid),'%s','delimiter',',');units=units{1};

formatstring='%*10c';
varnames={};unitnames={};
for n=2:length(vars)
    formatstring=[formatstring,'%10f%c'];
    switch(vars{n})
        case 'ACYCAA01'
            varnames{end+1}='skip';
        case 'PRESPR01'
            varnames{end+1}='press';
        case 'TEMPS901'
            varnames{end+1}='temp';
        case 'PSALCC01'
            varnames{end+1}='salin';
        case 'DOXYCZ01'
            varnames{end+1}='ox';
        case 'POTMCV01'
            varnames{end+1}='potemp';
        case 'TOKGPR01'
            varnames{end+1}='ltokg';
        otherwise
            error(['Unknown unit: ',vars{n}]);
    end
%     unitnames{end+1}=lower(units{n});
end
skiplines(1);

nvars=(length(vars)-1)*2;

data=fscanf(fid,formatstring,[nvars inf]);
fclose(fid);

flags=char(data(2:2:end,:));
data=data(1:2:end,:);
data(flags=='N')=nan;

tempdata=data;
tempdata(strmatch('press',varnames),:)=nan;
tempdata(strmatch('skip',varnames),:)=nan;

data=data(:,~all(isnan(tempdata)));

for n=1:length(varnames)
    switch(varnames{n})
        case 'skip'
        case 'ltokg'
            ctd.ox=ctd.ox.*data(n,:)';
        otherwise
            ctd.(varnames{n})=data(n,:)';
    end
end


function skiplines(n)
for m=1:n
    evalin('caller','fgetl(fid);');
end