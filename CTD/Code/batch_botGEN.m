
clear
sc=input('Enter first cast\n');
if sc<0
    ec=-sc;
    sc=-sc;
else
ec=input('Enter last cast\n');
end

fileow=0;

CTDvarn
% 
temp_cal_file=fullfile(dir_out,'SBE35','tempcals.all.mat');
salt_cal_file=fullfile(dir_out,'salts','salcals12.all.mat');
% oxy_cal_file=fullfile(dir_out,'oxygen','oxycals.all.mat');

if exist(temp_cal_file,'file')    
    disp('Temperature calibration file exists')
    delete_temp=input('Do you want to erase it? y/[n] ','s');
    if ~isempty(delete_temp) && strncmpi(delete_temp,'y',1)
        delete(temp_cal_file);
    end
end
if exist(salt_cal_file,'file')    %salcalGEN now doesn't duplicate entries
    disp('Salinity calibration file exists')
    delete_salt=input('Do you want to erase it? y/[n] ','s');
    if ~isempty(delete_salt) && strncmpi(delete_salt,'y',1)
        delete(salt_cal_file);
    end
end
% if exist(oxy_cal_file,'file')
%     disp('Oxygen calibration file exists')
%     delete_oxy=input('Do you want to erase it? y/[n] ','s');
%     if ~isempty(delete_oxy) && strncmpi(delete_oxy,'y',1)
%         delete(oxy_cal_file);
%     end
% end

for aa= sc:ec
    clear ('-regexp','[^aa ^fileow]')
    aaa = num2str(aa,'%03d');
    bl=0;
while bl==0
%% Make bottle file
    disp('Running makebotGEN') % .ros + .var + .bl -> _bot_.1st
    if makebotGEN(aaa)
        bl=1;
        disp('makebotGEN problem')
        break
    end

%% SBE35 temperatures
    disp('Running sb35readGEN') % _sbe35.asc + _bot_.1st + .2db.up.mat -> _bot_.sb35 & tempcals.all.mat
    if sb35readGEN(aaa)
        bl=1;
        disp('sb35readGEN problem')
        break
    end

%% Salts - comment out if not available
    disp('Running readsalGEN') % sal_.csv + .1st -> _sal_.mat
    if readsalGEN(aaa)   
        bl=1;     
        disp('readsalGEN problem')
        break
    end
% %  
    disp('Running addsalGEN') % _sal_.mat + .1st -> _bot_.sal
    if addsalGEN(aaa)
        bl=1;
       disp('addsalGEN problem')  
        break
    end
% %  
    disp('Running salcalGEN') % _bot_.sal + .2db.up.mat + .var -> salcals12.all.mat
    if salcalGEN(aaa)
        bl=1;
       disp('addsalGEN problem')  
    break
    end

%%%Oxygens - comment out if not available
 %   oxy_stns = [1:3 6:8 11 14 17 20 23 26 33] ; % list of stations that O2 samples were taken from
 %   if ismember(aa,oxy_stns)
        disp('Running readoxyGEN') % oxygen_.xlsx + .1st -> _oxy_.mat
        if readoxyGEN(aaa), break, end
% %  
        disp('Running addoxyGEN') % _oxy_.mat + .1st -> _bot_.oxy
        if addoxyGEN(aaa), break, end
% %  
       disp('Running oxycalGEN') % _bot_.oxy + .2db.up.mat + .var -> oxycals.all.mat
       if oxycalGEN(aaa), break, end
    
%end

%% Merge bottle data
    disp('Running mergebotGEN') % _bot_.1st + _bot_.sb35 + _bot_.sal + _bot_.oxy -> _bot_.all
    if mergebotGEN(aaa)
        bl=1;
       disp('mergebotGEN problem')  
       break
    end
bl=1; %successful loop
end
end
