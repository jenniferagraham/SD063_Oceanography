function break_loop=splitcast_calGEN(aaa,fileow)

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
 
CTDvarn_cal

infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.clb'])
upfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.clb.up'])
dnfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.clb.dn'])

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

for iv=1:length(vpc) %temporary down
    if vpc(iv)==1
       eval([varnames{iv,1},'dn=',varnames{iv,1},'(1:imaxprs);']);
    end
end

for iv=1:length(vpc) %keep names for up
    if vpc(iv)==1
       eval([varnames{iv,1},'=',varnames{iv,1},'(imaxprs:end);']);
    end
end

save(upfile,'names','gtime','lat','lon',varnames{(vpc==1),1});


for iv=1:length(vpc) %rename down and save
    if vpc(iv)==1
       eval([varnames{iv,1},'=',varnames{iv,1},'dn;']);
    end
end
save(dnfile,'names','gtime','lat','lon',varnames{(vpc==1),1});

if nargout>0
    break_loop=false;
end
