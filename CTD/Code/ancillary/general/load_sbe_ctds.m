function ctds=load_sbe_ctds(ctddir,cruisename,use_secondary,depth_name,station_name,export_matlab)
ctdfiles=dir(fullfile(ctddir,'*.cnv'));
for n=1:length(ctdfiles)
    fname=fullfile(ctddir,ctdfiles(n).name);
    ctd.cruise=cruisename;
    [ctd.lat,ctd.lon,gtime,data,names,~]=cnv2mat(fname);
    if min(data(:))<-1e20 || max(data(:))>1e20
        warning('Binary CNV is corrupt. Trying to read ASCII');
        try
            data=textread([fname(1:end-3),'asc'],'','headerlines',1);
        catch
            error('Problem reading ASCII file. Exiting.');
        end
    end
    ctd.date=datenum(gtime);
    if nargin>3 && ~isempty(depth_name)
        fid=fopen(fname,'rt');
        nextline=fgetl(fid);
        while ~feof(fid) && ~strncmp(nextline,'*END*',5)
          if strncmpi(nextline,depth_name,length(depth_name))
            try
              ctd.botdepth=str2double(strtok(nextline((length(depth_name)+2):end)));
            end
            if isfield(ctd,'botdepth') && isnan(ctd.botdepth)
              try
                ctd.botdepth=str2double(strtok(nextline((length(depth_name)+2):end-1)));
              end
            end
            break;
          elseif strncmpi(nextline,['** ',depth_name],length(depth_name)+3)
            try
              ctd.botdepth=str2double(strtok(nextline((length(depth_name)+5):end)));
            end
            if isfield(ctd,'botdepth') && isnan(ctd.botdepth)
              try
                ctd.botdepth=str2double(strtok(nextline((length(depth_name)+5):end-1)));
              end
            end
            break;
          end
          nextline=fgetl(fid);
        end
        fclose(fid);
    end
    if ~isfield(ctd,'botdepth') || isempty(ctd.botdepth)
        ctd.botdepth=nan;
    end
    if nargin>4 && ~isempty(station_name)
        fid=fopen(fname,'rt');
        nextline=fgetl(fid);
        while ~feof(fid) && ~strncmp(nextline,'*END*',5)
          if strncmpi(nextline,depth_name,length(station_name))
            try
              ctd.station=str2double(nextline((length(station_name)+2):end));
            catch
              ctd.station=str2double(nextline((length(station_name)+2):end-1));
            end
            break;
          elseif strncmpi(nextline,['** ',station_name],length(station_name)+3)
            try
              ctd.station=str2double(nextline((length(station_name)+5):end));
            catch
              ctd.station=str2double(nextline((length(station_name)+5):end-1));
            end
            break;
          end
          nextline=fgetl(fid);
        end
        fclose(fid);
    else
        ctd.station=str2double(ctdfiles(n).name(6:8));
        if isnan(ctd.station) & length(ctdfiles(n).name)>13 % try something else - for Polarstern
            ctd.station=str2double(ctdfiles(n).name(8:10));
            ctd.cast=str2double(ctdfiles(n).name(12:13));
        end
    end
    if ~isfield(ctd,'station') || isempty(ctd.station)
        ctd.station=nan;
    end
    
    for m=1:size(names,1)
        varcode=textscan(names(m,:),'# name %*d = %s %*s');
        varcode=varcode{1}{1}(1:end-1);
        switch(varcode)
            case 'scan'
                continue;
            case 'prDM'
                ctd.press=data(:,m);
            case 'depSM'
                ctd.depth=data(:,m);
            case 't090C'
                ctd.temp1=data(:,m);
            case 't190C'
                ctd.temp2=data(:,m);
            case 'c0S/m'
                ctd.cond1=data(:,m)*10;
            case 'c1S/m'
                ctd.cond2=data(:,m)*10;
            case 'c0mS/cm'
                ctd.cond1=data(:,m);
            case 'c1mS/cm'
                ctd.cond2=data(:,m);
            case 'sbeox0Mm/Kg'
                ctd.ox1=data(:,m);
            case 'sbeox0ML/L'
                ctd.ox1=data(:,m);
%                 if isfield(ctd,'salin1')
%                   ctd.ox1=ctd.ox1.*44.661./... %first convert to umol/l
%                     sw_dens(ctd.salin1,ctd.temp1,ctd.press).*1000; %then convert to umol/kg
%                 else
                  ctd.ox1=ctd.ox1.*44.661./... %first convert to umol/l
                    sw_dens(sw_salt(ctd.cond1./sw_c3515,ctd.temp1,ctd.press),...
                    ctd.temp1,ctd.press).*1000; %then convert to umol/kg
%                 end
            case 'sbeox1ML/L'
                ctd.ox2=data(:,m);
%                 if isfield(ctd,'salin1')
%                   ctd.ox2=ctd.ox2.*44.661./... %first convert to umol/l
%                     sw_dens(ctd.salin2,ctd.temp2,ctd.press).*1000; %then convert to umol/kg
%                 else
                  ctd.ox2=ctd.ox2.*44.661./... %first convert to umol/l
                    sw_dens(sw_salt(ctd.cond2./sw_c3515,ctd.temp2,ctd.press),...
                    ctd.temp2,ctd.press).*1000; %then convert to umol/kg
%                 end
            case {'flC','flECO-AFL'}
                ctd.fluor=data(:,m);
            case {'wetBTrans','xmiss','CStarTr0'}
                ctd.trans=data(:,m);
            case 'potemp090C'
                ctd.potemp1=data(:,m);
            case 'potemp190C'
                ctd.potemp2=data(:,m);
            case 'sal00'
                ctd.salin1=data(:,m);
            case 'sal11'
                ctd.salin2=data(:,m);
            case 'altM'
                ctd.alt=data(:,m);
            case 'pumps'
                ctd.pumps=data(:,m);
            case 'flag'
                ctd.flag=data(:,m);
            case {'bat','CStarAt0'}
                ctd.atten=data(:,m);
            case 'CStarAt1'
                ctd.atten2=data(:,m);
            case 'par'
                ctd.par=data(:,m);
            case 'spar'
                ctd.surf_par=data(:,m);
            case 'turbWETbb0'
                ctd.turbid_bb=data(:,m);
            case 'turbWETntu0'
                ctd.turbid_ntu=data(:,m);
            case {'sigma-é00','sigma-é11','sbeox0V','density00','svCM','sbeox0PS'} % variables to ignore
            otherwise
                warning('Unknown variable: %s',names(m,:));
        end
    end
    if nargin>2 && use_secondary
        if isfield(ctd,'temp2')
            ctd.temp=ctd.temp2;
        else
            warning('Using primary temperature');
            ctd.temp=ctd.temp1;
        end
        if isfield(ctd,'cond2')
            ctd.cond=ctd.cond2;
        else
            warning('Using primary conductivity');
            ctd.cond=ctd.cond1;
        end
        if isfield(ctd,'salin2')
            ctd.salin=ctd.salin2;
        else
            warning('Using primary salinity');
            ctd.salin=ctd.salin1;
        end
        if isfield(ctd,'ox2')
            ctd.ox=ctd.ox2;
        elseif isfield(ctd,'ox1')
            warning('Using primary oxygen');
            ctd.ox=ctd.ox1;
        end
    else
        ctd.temp=ctd.temp1;
        ctd.cond=ctd.cond1;
        ctd.salin=ctd.salin1;
        if isfield(ctd,'ox1')
            ctd.ox=ctd.ox1;
        end
    end
    if n>1 && ~isempty(setdiff(fieldnames(ctd),fieldnames(ctds(n-1))))
        newfields=setdiff(fieldnames(ctd),fieldnames(ctds(n-1)));
        for m=1:(n-1)
          for o=1:length(newfields)
            ctds(m).(newfields{o})=nan(size(ctds(m).temp));
          end
        end
        ctds=orderfields(ctds,fieldnames(ctd));
    elseif n>1 && ~isempty(setdiff(fieldnames(ctds(n-1)),fieldnames(ctd)))
        newfields=setdiff(fieldnames(ctds(n-1)),fieldnames(ctd));
        for o=1:length(newfields)
            ctd.(newfields{o})=nan(size(ctd.temp));
        end
        ctd=orderfields(ctd,fieldnames(ctds));
    end
    if ~all(diff(ctd.press)>0)
        [~,botind]=max(ctd.press);
        ctd=cutmooring(ctd,1:botind);
    end
    ctds(n)=ctd;
    if nargin>5
        newfname=[ctdfiles(n).name(1:end-4),'_2db.mat'];
        if strncmpi(newfname,'nbp',3) && ~strcmp(newfname(8),'_')
            newfname=[newfname(1:7),'_',newfname(8:end)];
        end
        save (fullfile(ctddir,'matlab',newfname),...
            '-struct','ctd','-v7');
    end
    clear ctd
end
