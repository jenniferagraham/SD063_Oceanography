
clear
sc=input('Enter first cast\n');
if sc<0
    ec=-sc;
    sc=-sc;
else
ec=input('Enter last cast\n');
end

fileow=0;

for aa=sc:ec

    clear ('-regexp','[^aa ^fileow]')
skipflag=0;


aaa = num2str(aa,'%03d');

   bl=0;
while bl==0
%aaa = input('Station number?\n','s');
% while length(aaa)<3
%     aaa=['0',aaa,''];
% end 
CTDvarn


if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(find(CastEvent(:,1)==aac),2);
eee=num2str(eec,'%03d')
eee=['_',eee,];
else 
    disp('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n');  %new cast
    disp(['Skipping cast ',aaa,''])
skipflag=1;
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end

end

if skipflag~=1
ctdsave=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var']);

if exist(ctdsave,'file')
    if fileow~=1
    disp('Derived variable file exists')
    disp('Force overwrite (1), check individually (2) or stop (3)')
    fileexist=input('');
else
    fileexist=1;
    end
else
  fileexist=0;  
end
if fileexist==3
    error('Output file exists')
elseif fileexist==1
    fileow=1;
else
    fileow=0;
end


disp('Running deriveGEN') % .edt -> .var
if deriveGEN(aaa,fileow),  bl=1;
    break, end

disp('Running onehzctdGEN') % .var -> .1hz
if onehzctdGEN(aaa,fileow),  bl=1; 
    break, end

disp('Running splitcastGEN') % .var -> .var.up & .var.dn
if splitcastGEN(aaa,fileow),  bl=1; 
    break, end

disp('Running fallrateGEN') % .var.dn -> .var.dn
if fallrateGEN(aaa),   bl=1;
    break, end

% disp('Running fallrateTEST_sda') % .var.dn -> .var.dn
% if fallrateTEST_sda(aaa), break, end

disp('Running gridctdGEN') % .var.dn -> .2db.mat ; .var.up -> .2db.up.mat
if gridctdGEN(aaa,fileow),  bl=1; 
    break, end

disp('Running ctdplotGEN') 
if ctdplotGEN(aaa),   bl=1;
    break, end

end
bl=1; %successful loop
end
end
