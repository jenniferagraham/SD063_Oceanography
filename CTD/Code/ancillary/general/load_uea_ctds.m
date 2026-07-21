function ctds=load_uea_ctds(ctddir,cruisename,use_secondary,force_calibrated,force_non_calibrated)

ctdfiles=dir(fullfile(ctddir,'*.2db'));
if isempty(ctdfiles)
    ctdfiles=dir(fullfile(ctddir,'*.1db'));
end
if isempty(ctdfiles)
    ctdfiles=dir(fullfile(ctddir,'*.2db.mat'));
end
if isempty(ctdfiles)
    error('No CTD files found')
end

if nargin>3 && ~isempty(force_calibrated) && force_calibrated
    n=1;
    while n<=length(ctdfiles)
        if ~contains(ctdfiles(n).name,'_cal')
            ctdfiles(n)=[];
        else
            n=n+1;
        end
    end
elseif nargin>4 && ~isempty(force_non_calibrated) && force_non_calibrated
    n=1;
    while n<=length(ctdfiles)
        if contains(ctdfiles(n).name,'_cal')
            ctdfiles(n)=[];
        else
            n=n+1;
        end
    end
end

% Removes any potential "hidden files" that should not be loaded,
% which might confuse the script
n=1;
while n<=length(ctdfiles)
    if contains(ctdfiles(n).name,'._')
        ctdfiles(n)=[];
    else
        n=n+1;
    end
end

for n=1:length(ctdfiles)
    fname=fullfile(ctddir,ctdfiles(n).name);
    ctd=load('-mat',fname);
    ctd.cruise=cruisename;
    ctd.date=datenum(ctd.gtime);
    ctd=rmfield(ctd,'gtime');
    ctdind=strfind(ctdfiles(n).name,'ctd');
%     ctd.station=str2double(ctdfiles(n).name(4:6));
%     if length(ctdfiles(n).name)>=12 && ~isnan(str2double(ctdfiles(n).name(7:8)))
%         ctd.cast=str2double(ctdfiles(n).name(7:8));
    if ctdfiles(n).name(ctdind+3)=='_'
        ctdind=ctdind+1;
    end
    ctd.station=str2double(ctdfiles(n).name(ctdind+[3:5]));
    if length(ctdfiles(n).name)>=(ctdind+9) && all(isstrprop(ctdfiles(n).name(ctdind+[7:9]),'digit'))
        ctd.cast=str2double(ctdfiles(n).name(ctdind+[7:9]));
    elseif length(ctdfiles(n).name)>=(ctdind+7) && all(isstrprop(ctdfiles(n).name(ctdind+[6:7]),'digit'))
        ctd.cast=str2double(ctdfiles(n).name(ctdind+[6:7]));
    else
        ctd.cast=[];
    end
    if isfield(ctd,'aaa'), ctd=rmfield(ctd,'aaa');end
    if isfield(ctd,'infile'), ctd=rmfield(ctd,'infile');end
    theFields=fieldnames(ctd);
    calFields=theFields(endsWith(theFields,'_cal'));
    for o=1:length(calFields)
        ctd.(calFields{o}(1:(end-4)))=ctd.(calFields{o});
        ctd=rmfield(ctd,calFields{o});
    end
    if any(isnan(ctd.press))
        ctd=cutmooring(ctd,find(~isnan(ctd.press)));
    end
    if ~isfield(ctd,'temp') && isfield(ctd,'temp1')
        if nargin>2 && use_secondary && isfield(ctd,'temp2')
            ctd.temp=ctd.temp2;
            ctd.cond=ctd.cond2;
            ctd.salin=ctd.salin2;
            if isfield(ctd,'potemp2')
                ctd.potemp=ctd.potemp2;
            end
        else
            ctd.temp=ctd.temp1;
            ctd.cond=ctd.cond1;
            ctd.salin=ctd.salin1;
            if isfield(ctd,'potemp1')
                ctd.potemp=ctd.potemp1;
            end
        end
    end
    ctds(n)=ctd;
end

