function ctd=load_mstar_ctd(fname,cruisename,filevarnames)
% ctdfiles=dir(fullfile(ctddir,'*_2db*.nc'));
ctdfiles=dir(fname);

if nargin<3
    filevarnames={'press','temp',{'salin','psal'},'cond','potemp',...
        {'ox','oxygen'},'fluor',{'trans','transmittance'},...
        {'scatter','backscatter'}};
end
% o=1;
% for n=1:length(ctdfiles)
%     if strcmp(ctdfiles(n).name(end-8:end),'_1_2db.nc')
%         continue;
%     end
%     fname=fullfile(ctddir,ctdfiles(n).name);
    ctd.cruise=cruisename;
    ctd.lon=ncreadatt(fname,'/','longitude');
    ctd.lat=ncreadatt(fname,'/','latitude');
    ctd.botdepth=ncreadatt(fname,'/','water_depth_metres');
    ctd.date=datenum(ncreadatt(fname,'/','data_time_origin'));
    [~,station_text]=strtok(ctdfiles.name,'_');
    [~,station_text]=strtok(station_text,'_');
%     station_text=strtok(station_text,'_');
    station_text=station_text(2:end-3);
    have_suffix=1;
    while length(station_text)>4 && have_suffix
        if strcmp(station_text(end-3:end),'_2db') || strcmp(station_text(end-3:end),'_2up')
            station_text=station_text(1:(end-4));
        elseif strcmp(station_text(end-3:end),'_cal')
            station_text=station_text(1:(end-4));
        elseif strcmp(station_text(end-4:end),'_psal')
            station_text=station_text(1:(end-5));
        elseif strcmp(station_text(end-2:end),'_dn') || strcmp(station_text(end-2:end),'_up')
            station_text=station_text(1:(end-3));
        else
            have_suffix=0;
        end
    end
    station_text(station_text=='_')='';
    ctd.station=str2double(station_text);
%     if ctd.station>99999 %upcast only...
%         clear ctd;
%         continue;
%     else
    if ctd.station>9999
        ctd.cast=mod(ctd.station,1000);
        ctd.station=floor(ctd.station/1000);
    elseif ctd.station>999
        ctd.cast=mod(ctd.station,100);
        ctd.station=floor(ctd.station/100);
        if ctd.cast>50 %upcast only
            clear ctd;
            return; 
        end
    elseif ctd.station>199
        ctd.cast=mod(ctd.station,10);
        ctd.station=floor(ctd.station/10);
    else
        ctd.cast=[];
    end

    for m=1:length(filevarnames)
        if ischar(filevarnames{m}) || ...
                (iscellstr(filevarnames{m}) && length(filevarnames{m})==1)
            load_nc_var(filevarnames{m},filevarnames{m});
        else
            load_nc_var(filevarnames{m}{1},filevarnames{m}{2});
        end
    end
%     ctds(o)=ctd;
%     o=o+1;
%     clear ctd    
% end

function load_nc_var(matvarname,ncvarname)
evalin('caller',sprintf('ctd.%s=ncread(fname,''%s'');',matvarname,ncvarname));
evalin('caller',sprintf('ctd.%s_unit=ncreadatt(fname,''%s'',''units'');',matvarname,ncvarname));
