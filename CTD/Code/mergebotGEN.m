function break_loop=mergebotGEN(aaa)
% reads in _bot_.1st, adds bottle salinity from _bot_.sal and SBE35 from _bot_.sb35

if nargin<1
    aaa=input('Station number?\n','s');
elseif ~ischar(aaa)
    aaa=num2str(aaa);
end
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];
disp(['processing cast ',aaa])
 
CTDvarn


if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(find(CastEvent(:,1)==aac),2);
eee=num2str(eec,'%03d');
eee=['_',eee,];
else 
    eee=input('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n','s');  %new cast
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end
end


% close all

% first read botnnn.1st and salnnn.mat files
infile_bot = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st']);
disp(['   Input file = ',infile_bot])
infile_sal = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sal']);
disp(['   Input file = ',infile_sal])
infile_sb35 = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sb35']);
disp(['   Input file = ',infile_sb35])
infile_oxy = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.oxy']) ;
disp(['   Input file = ',infile_oxy])
otfile = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.all']);
disp(['   Output file = ',otfile])

if ~exist(infile_bot,'file')
    warning('No bottle file for cast %s.',aaa);
    if nargout>0
        break_loop=false;
    end
    return;
end
load ('-mat',infile_bot);

if exist(infile_sal)
saldata=load('-mat',infile_sal,'niskinnums','samplesals');
[~,ind]=intersect(botno,saldata.niskinnums);
for ims=1:length(ind) 
   iib=find(saldata.niskinnums==botno(ind(ims)),1,'first'); %ignore any second samples from same Niskin  
   botsal(ind(ims))=saldata.samplesals(iib);
end

else
    disp('no salt file')
end
botsal
if exist(infile_sb35)
sbe35data=load('-mat',infile_sb35,'sb35botno','sb35caltemp');
[~,ind]=intersect(botno,sbe35data.sb35botno);
sb35temp(ind)=sbe35data.sb35caltemp;
else
    disp('no sbe35 file')
end

if exist(infile_oxy)
oxydata = load('-mat',infile_oxy,'sampleoxy','niskinnums','botoxy') ;
botoxy = oxydata.botoxy ;
else
    disp('no oxygen file')
end


save(otfile,'botno','lat','lon','gtime',varbotnames{(vpd_bot==1),1});

if nargout>0
    break_loop=false;
end
