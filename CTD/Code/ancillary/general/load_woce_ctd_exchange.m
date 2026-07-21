function ctd=load_woce_ctd_exchange(fname)

fid=fopen(fname,'rt');

if ~strncmp(fgetl(fid),'CTD',3)
    fclose(fid);
    error([fname,': Not a CTD file?']);
end
nheaders=1;n=0;
while n<nheaders
    [headername,headervalue]=strtok(fgetl(fid),' = ');
    if headername(1)=='#' %skip comments
        continue;
    end
    headervalue=headervalue(4:end);
    switch(headername)
        case 'NUMBER_HEADERS'
            nheaders=str2double(headervalue);
        case 'EXPOCODE'
            ctd.cruise=headervalue;
        case 'SECT'
            ctd.sectionname=headervalue;
        case 'STNNBR'
            ctd.station=str2double(headervalue);
        case 'CASTNO'
            ctd.cast=str2double(headervalue);
        case 'DATE'
            ctd.date=datenum(headervalue,'yyyymmdd');
        case 'TIME'
            ctd.date=ctd.date+datenum(headervalue,'HHMM')-datenum('0000','HHMM');
        case 'LATITUDE'
            ctd.lat=str2double(headervalue);
        case 'LONGITUDE'
            ctd.lon=str2double(headervalue);
        case 'DEPTH'
            ctd.botdepth=str2double(headervalue);
    end
    n=n+1;
end

vars=textscan(fgetl(fid),'%s','delimiter',',');vars=vars{1};
units=textscan(fgetl(fid),'%s','delimiter',',');units=units{1};

formatstring='';
varnames={};unitnames={};have_flag=[];
for n=1:length(vars)
    if length(vars{n})>7 && strcmp(vars{n}(end-6:end),'_FLAG_W')
        formatstring=[formatstring,'%d'];
        have_flag(length(varnames))=1;
    else
        formatstring=[formatstring,'%f'];
        switch(vars{n})
            case 'CTDPRS'
                varnames{end+1}='press';
            case 'CTDTMP'
                varnames{end+1}='temp';
            case 'CTDSAL'
                varnames{end+1}='salin';
            case 'CTDOXY'
                varnames{end+1}='ox';
            case {'TRANSM','CTDXMISS'}
                varnames{end+1}='trans';
            case 'CTDTURB'
                varnames{end+1}='turb';
            case {'CTDBETA660','CTDBETA700','CTDBETA650_124'}
                varnames{end+1}='backscatter';
            case {'FLUORM','CTDFLUOR'}
                varnames{end+1}='fluor';
            case 'PAR'
                varnames{end+1}='par';
            otherwise
                fclose(fid);
                error(['Unknown variable: ',vars{n}]);
        end
        unitnames{end+1}=lower(units{n});
    end
end
have_flag((length(have_flag)+1):length(varnames))=0;

data=textscan(fid,formatstring,'delimiter',',');
if ~strncmp(fgetl(fid),'END_DATA',8)
    fclose(fid);
    error('Could not read to end of data');
end
fclose(fid);

press=data{strmatch('press',varnames)};
if median(diff(press))==1
    startind=2-mod(press(1),2);
    dp=2;
else
    startind=1;
    dp=1;
end

m=1;
for n=1:length(varnames)
    ctd.(varnames{n})=data{m}(startind:dp:end);
    ctd.(varnames{n})(ctd.(varnames{n})==-999)=nan;
    if have_flag(n)
        m=m+1;
        ctd.([varnames{n},'_flag'])=uint8(data{m}(startind:dp:end));
    end
    ctd.([varnames{n},'_unit'])=unitnames{n};
    m=m+1;
end

ctd.potemp=sw_ptmp(ctd.salin,ctd.temp,ctd.press,0);
