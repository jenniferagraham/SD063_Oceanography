function export_cruise_to_odv(cruisename)

fid=fopen([lower(cruisename),'_ctds_odv.txt'],'wt');
fprintf(fid,'//<MissingValueIndicators>-999</MissingValueIndicators>\n');
fprintf(fid,strcat('Cruise\tStation\tType\tyyyy-mm-dd hh:mm\t',...
    'Longitude [degrees_east]\tLatitude [degrees_north]\t',...
    'Bot. Depth [m]\tPressure [dbar]:PRIMARYVAR\tTemp [degC]\tSalinity [psu]\t',...
    'Fluor [~$m~#g/l]\tOx [~$m~#mol/kg]\tTrans [%%]\tPAR [unknown]\t',...
    'LADCP_u [m/s]\tLADCP_v [m/s]\n'));

cruises={upper(cruisename)};

vars={'press','temp','salin','fluor','ox','trans','par','ladcp_u','ladcp_v'};
nvars=length(vars);

for n=1:length(cruises)
    fprintf(1,'Loading %s...',cruises{n});
    if exist([lower(cruises{n}),'_ctd.mat'],'file')
        load([lower(cruises{n}),'_ctd.mat']);
    else
        ctds=eval(['load_',lower(cruises{n}),'_ctd']);
    end
    fprintf(1,'writing...');
    for m=1:length(ctds)
        if ~isfield(ctds(m),'botdepth')
            ctds(m).botdepth=-999;
        end
        if ~isfield(ctds(m),'press') || isempty(ctds(m).press)
            if isfield(ctds(m),'depth') && ~isempty(ctds(m).depth)
                ctds(m).press=sw_pres(ctds(m).depth,ctds(m).lat);
            else
                error('No depth or pressure in cruise!');
            end
        end
        if isfield(ctds(m),'cast') && ~isempty(ctds(m).cast)
          stationstring=sprintf('%s\t%d_%d\t%c\t%s\t%.4f\t%.4f\t%d',...
            cruises{n},ctds(m).station,ctds(m).cast,'C',...
            [datestr(ctds(m).date,29),' ',datestr(ctds(m).date,15)],...
            ctds(m).lon,ctds(m).lat,round(ctds(m).botdepth));
        else
          stationstring=sprintf('%s\t%d\t%c\t%s\t%.4f\t%.4f\t%d',...
            cruises{n},ctds(m).station,'C',...
            [datestr(ctds(m).date,29),' ',datestr(ctds(m).date,15)],...
            ctds(m).lon,ctds(m).lat,round(ctds(m).botdepth));
        end
        nlines=length(ctds(m).press);
        data=nan(nlines,nvars);
        for o=1:nvars
            if isfield(ctds(m),vars{o})
                data(:,o)=ctds(m).(vars{o});
            end
        end
        data(isnan(data))=-999;
        fprintf(fid,[stationstring,repmat('\t%.4f',1,nvars),'\n'],data');
    end
    fprintf(1,'done.\n');
end

fclose(fid);