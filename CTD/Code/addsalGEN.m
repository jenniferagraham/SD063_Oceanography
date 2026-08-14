function break_loop=addsalGEN(aaa)
% function to read botnnn.1st and add sample salinity to create botnnn.sal
% added salinity flag
% set to 1 for data present, 0 for data nan

% modified for JR165 Mar 07 by MIW

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
infile = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st']);
otfile = fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sal'])

% eval(['unix(''cp ' infile ' ' otfile ''');'])

load ('-mat',infile);

fname=fullfile(dir_out,'salts',[cruise,'_sal_',aaa,'',frame_fileadd,'',eee,'.mat']);
load ('-mat',fname);

[~,~,niskinind]=intersect(niskinnums,botno);

for i=1:length(niskinind)
    for iv=1:length(vpd_botctd)
        if vpd_botctd(iv)>=1
           
           eval(['',varbotnames{iv,1},'a(i)=',varbotnames{iv,1},'(niskinind(i));']);
           %eval(['',varbotnames{iv,1},'a(i)=',varbotnames{iv,1},'(i)';]);
        end
    end
end

for iv=1:length(vpd_botctd)
    if vpd_botctd(iv)>=1
       if length(niskinnums)>0
          eval([varbotnames{iv,1},'=',varbotnames{iv,1},'a;']);
       else
          eval([varbotnames{iv,1},'=[];']);
       end
    end
end

save(otfile,'gtime','samplesals','niskinnums','niskinind','botno',varbotnames{(vpd_bot==1),1});

if nargout>0
    break_loop=false;
end
