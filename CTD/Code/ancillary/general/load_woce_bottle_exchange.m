function bottle=load_woce_bottle_exchange(fname)

fid=fopen(fname,'rt');

if ~strncmp(fgetl(fid),'BOTTLE',6)
    fclose(fid);
    error([fname,': Not a bottle file?']);
end
nextline=fgetl(fid);
while nextline(1)=='#' %skip comments
    nextline=fgetl(fid);
end
vars=textscan(nextline,'%s','delimiter',',');vars=vars{1};
units=textscan(fgetl(fid),'%s','delimiter',',');units=units{1};
if length(units)<length(vars)
    units{(length(units)+1):length(vars)}='';
end

formatstring='';
varnames={};unitnames={};
for n=1:length(vars)
    if length(vars{n})>7 && strcmp(vars{n}(end-6:end),'_FLAG_W')
        formatstring=[formatstring,'%d'];
        varnames{end+1}=[varnames{end},'_flag'];
    elseif length(vars{n})>5 && strcmp(vars{n}(end-4:end),'_FLAG')
        formatstring=[formatstring,'%d'];
        varnames{end+1}=[varnames{end},'_flag'];
    else
        formatstring=[formatstring,'%f'];
        switch(vars{n})
            case 'EXPOCODE'
                varnames{end+1}='cruise';
                formatstring(end)='s';
            case 'SECT_ID'
                varnames{end+1}='sectionname';
                formatstring(end)='s';
            case 'STNNBR'
                varnames{end+1}='station';
            case 'CASTNO'
                varnames{end+1}='cast';
            case 'SAMPNO'
                varnames{end+1}='sample_id';
            case 'BTLNBR'
                varnames{end+1}='bottle_id';
            case 'CTDRAW'
                varnames{end+1}='depth';
            case 'CTDPRS'
                varnames{end+1}='ctdpress';
            case 'CTDTMP'
                varnames{end+1}='ctdtemp';
            case 'CTDSAL'
                varnames{end+1}='ctdsalin';
            case 'CTDOXY'
                varnames{end+1}='ctdox';
            case 'CTDXMISS'
                varnames{end+1}='ctdtrans';
            case {'CTDBETA660','CTDBETA700'}
                varnames{end+1}='ctdbackscatter';
            case 'SALNTY'
                varnames{end+1}='salin';
            case 'SALTREF'
                varnames{end+1}='saltref';
            case 'THETA'
                varnames{end+1}='potemp';
            case 'OXYGEN'
                varnames{end+1}='ox';
            case 'SILCAT'
                varnames{end+1}='si';
            case 'NO2+NO3'
                varnames{end+1}='no2no3';
            case 'NITRAT'
                varnames{end+1}='no3';
            case 'NITRIT'
                varnames{end+1}='no2';
            case 'PHSPHT'
                varnames{end+1}='po4';
            case 'CFC-11'
                varnames{end+1}='cfc11';
            case 'CFC-12'
                varnames{end+1}='cfc12';
            case 'CFC113'
                varnames{end+1}='cfc113';
            case 'CCL4'
                varnames{end+1}='ccl4';
            case 'TRITUM'
                varnames{end+1}='tritium';
            case 'HELIUM'
                varnames{end+1}='helium';
            case 'DELHE3'
                varnames{end+1}='del_he3';
            case 'DELC14'
                varnames{end+1}='del_c14';
            case '14C_DIC'
                varnames{end+1}='del_c14_dic';
            case 'C14ERR'
                varnames{end+1}='del_c14_err';
            case 'DELC13'
                varnames{end+1}='del_c13';
            case 'C13ERR'
                varnames{end+1}='del_c13_err';
            case {'D30SI_SILCAT','DELSI30'}
                varnames{end+1}='del_si30';
            case {'DELO18','OXY_18'}
                varnames{end+1}='del_o18';
            case 'NEON'
                varnames{end+1}='neon';
            case 'TCARBN'
                varnames{end+1}='total_carbon';
            case 'PCO2'
                varnames{end+1}='pco2';
            case 'TCO2'
                varnames{end+1}='tco2';
            case 'PCO2TMP'
                varnames{end+1}='pco2_temp';
            case 'ALKALI'
                varnames{end+1}='alkalinity';
            case 'PH_SWS'
                varnames{end+1}='ph_sws';
            case 'PH_TMP'
                varnames{end+1}='ph_temp';
            case 'PH_TOT'
                varnames{end+1}='ph_tot';
            case 'DOC'
                varnames{end+1}='doc';
            case 'CDOM325'
                varnames{end+1}='cdom_325';
            case 'CDOM340'
                varnames{end+1}='cdom_340';
            case 'CDOM380'
                varnames{end+1}='cdom_380';
            case 'CDOM412'
                varnames{end+1}='cdom_412';
            case 'CDOMSL'
                varnames{end+1}='cdom_sl';
            case 'CDOMSN'
                varnames{end+1}='cdom_sn';
            case 'REVPRS'
                varnames{end+1}='press';
            case 'HELIER'
                varnames{end+1}='helium_error';
            case 'TRITER'
                varnames{end+1}='tritium_error';
            case {'REVTMP','REFTMP','SBE35','SBE35TMP'}
                varnames{end+1}='temp';
            case 'NEONER'
                varnames{end+1}='neon_error';
            case 'DELHER'
                varnames{end+1}='del_he3_error';
            case 'N2O'
                varnames{end+1}='n2o';
            case 'SF6'
                varnames{end+1}='sf6';
            case 'SIGMA-THETA'
                varnames{end+1}='sigma_theta';
            case 'SIGMA-1'
                varnames{end+1}='sigma_1';
            case 'SIGMA-2'
                varnames{end+1}='sigma_2';
            case 'SIGMA-3'
                varnames{end+1}='sigma_3';
            case 'SIGMA-4'
                varnames{end+1}='sigma_4';
            case 'CTDFLUOR'
                varnames{end+1}='fluor';
            case 'POC'
                varnames{end+1}='poc';
            case 'PON'
                varnames{end+1}='pon';
            case 'POM'
                varnames{end+1}='pom';
            case 'CH4'
                varnames{end+1}='ch4';
            case 'BSI'
                varnames{end+1}='bsi';
            case 'PAR'
                varnames{end+1}='par';
            case {'CHLORA','BOTCHLA'}
                varnames{end+1}='chl';
            case {'DATE','TIME','LATITUDE','LONGITUDE','DEPTH'}
                varnames{end+1}='skip';
            otherwise
                fclose(fid);
                error(['Unknown variable: ',vars{n}]);
        end
        unitnames{length(varnames)}=lower(units{n});
    end
end

data=textscan(fid,formatstring,'delimiter',',');
if ~strncmp(fgetl(fid),'END_DATA',8)
    if strncmp(data{1}{end},'END_DATA',8)
        nbot=length(data{1})-1;
        data{1}=data{1}(1:nbot);
        for n=2:length(data)
          if length(data{n})>nbot
%             warning('Why is this variable longer than the number of bottles?');
            data{n}=data{n}(1:nbot);
          end
        end
    else
        fclose(fid);
        error('Could not read to end of data');
    end
end
fclose(fid);


for n=1:length(varnames)
    if strcmp(varnames{n},'skip')
        continue;
    end
    if length(varnames{n})>5 && strcmp(varnames{n}(end-4:end),'_flag')
        bottle.(varnames{n})=uint8(data{n});
    else
        bottle.(varnames{n})=data{n};
    end
    if length(unitnames)>=n && ~isempty(unitnames{n})
        bottle.([varnames{n},'_unit'])=unitnames{n};
    end
end
