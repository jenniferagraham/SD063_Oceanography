function break_loop=splitcastGEN(aaa,fileow)

% SPLITCAST splits a CTD file into an upcast and a downcast.

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

txtfile=fullfile(dir_out,[cruise,'_ctd',frame_fileadd,'_calibrations.txt'])
if exist(txtfile,'file')
    %there are calibration offsets, so go into calibration mode
    CTDvarn_cal
    calflag=1;
else
    calflag=0;
end

if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(aai,2);
eee=num2str(eec,'%03d');
else 
    eee=input('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n','s');  %new cast
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end

padzeros=max([3-length(eee),4-strfind(eee,'.')]);
eee=[repmat('0',1,padzeros),eee];
eee(eee=='.')=[];
eee=['_',eee,];
end

if calflag==0
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var'])
upfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var.up'])
dnfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var.dn'])
else
 infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb'])
upfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb.up'])
dnfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb.dn'])
end

if nargin<2
    fileow=0;
end
if exist(dnfile,'file')  
    if fileow==0  %so setting to 1 skips this step
    crow=input('Output file exists, proceed? y/n \n','s');
    if crow~='y'
        disp('Script already run')
        break_loop=true;
        return;
    else
        disp('Output file will be overwritten')
    end
    end
end

% load input file
 
load (infile,'-mat');

%pressure left in at edit stage now (for 1hz output) so remove it here (so
%fallrate works)
iic=find(isfinite(cond1), 1 ); %start of downcast
if iic~=1
press(1:(iic-1))=NaN;
end


maxprs=max(press);
norecs = length(scan);
imaxprs=find(press == maxprs, 1 );

%to split, either need to hold one half with temporary variable names,
%store all variables somewhere else or reload the file.

for iv=1:length(vpd) %temporary down
    if vpd(iv)==1
       eval([varnames{iv,1},'dn=',varnames{iv,1},'(1:imaxprs);']);
    end
end

for iv=1:length(vpd) %keep names for up
    if vpd(iv)==1
       eval([varnames{iv,1},'=',varnames{iv,1},'(imaxprs:end);']);
    end
end

save(upfile,'names','gtime','lat','lon',varnames{(vpd==1),1});


for iv=1:length(vpd) %rename down and save
    if vpd(iv)==1
       eval([varnames{iv,1},'=',varnames{iv,1},'dn;']);
    end
end
save(dnfile,'names','gtime','lat','lon',varnames{(vpd==1),1});

if nargout>0
    break_loop=false;
end
