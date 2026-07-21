function ctd=load_bodc_ctd_exchange_netcdf(fname)

finfo=ncinfo(fname);

varnames={};
m=1;
while m<=length(finfo.Variables)
    if finfo.Variables(m).Name(1)=='F' && strcmp(finfo.Variables(m).Datatype,'char')
        m=m+1;
        continue;
    end
    switch(finfo.Variables(m).Name)
        case 'ACYCAA01'
            varname='skip';
        case 'PRESPR01'
            varname='press';
        case {'TEMPS901','TEMPST01'}
            varname='temp';
        case {'PSALCC01','PSALST01'}
            varname='salin';
        case 'DOXYCZ01'
            varname='ox_mol_l';
        case 'POTMCV01'
            varname='potemp';
        case 'TOKGPR01'
            varname='ltokg';
        case 'SIGTEQ01'
            varname='sigma_theta';
        case 'POPTZZ01'
            varname='trans';
        case 'CPHLPR01'
            varname='fluor';
        otherwise
            error(['Unknown unit: ',finfo.Variables(m).Name]);
    end
    if strcmp(varname,'skip')
        m=m+1;
        continue;
    end
    varnames{end+1}=varname;
    ctd.(varname)=double(ncread(fname,finfo.Variables(m).Name));
    ctd.([varname,'_flag'])=ncread(fname,['F',finfo.Variables(m).Name]);
    ctd.(varname)(ctd.([varname,'_flag'])=='N')=nan;
    m=m+1;
end

tempdata=nan(length(ctd.press),length(varnames));
for m=1:length(varnames)
    tempdata(:,m)=ctd.(varnames{m});
end
tempdata(:,strmatch('press',varnames))=nan;

goodind=find(~all(isnan(tempdata),2));
for m=1:length(varnames)
    ctd.(varnames{m})=ctd.(varnames{m})(goodind);
    ctd.([varnames{m},'_flag'])=ctd.([varnames{m},'_flag'])(goodind);
end

if isfield(ctd,'ox_mol_l') && isfield(ctd,'ltokg')
    ctd.ox=ctd.ox_mol_l.*ctd.ltokg;
    ctd.ox_flag=ctd.ox_mol_l_flag;
    ctd=rmfield(ctd,{'ox_mol_l','ltokg','ox_mol_l_flag','ltokg_flag'});
end


