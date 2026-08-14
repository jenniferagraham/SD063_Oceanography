function break_loop=makebotGEN(aaa)

% function to read in Sea-bird .ros file and our .var file to create a bottle file 
% had to amend slightly for the specific CTD setup on JR141 (DRS, Feb 2006)
% Extracts median and std of temp, cond and press for the time period over
% which each bottle was fired.

% modified for JR165 Mar 07 by MIW
%modified after JR200 June 09 by HJV to use nanmedian and nanstd

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
else 
    disp('CastEvent table oddity, cast may not exist');  %new cast
    disp('If it does, edit CastEvent table')
    disp('Ending processing of this cast, for now at least')
      
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end

if ~exist('eee','var')
    break_loop=1;
    return
end

padzeros=max([3-length(eee),4-strfind(eee,'.')]);
eee=[repmat('0',1,padzeros),eee];
eee(eee=='.')=[];
eee=['_',eee,];
end

% first read ros file to get start stop scans
disp(' ')
disp('*** makebot.m ***')

varfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var']);
infile=fullfile(dir_sb,[cruise,'_',sb_prefix,aaa,frame_fileadd,'.ros']);
disp(['   Input file = ',infile])

if exist(varfile,'file')&&exist(infile,'file')

fid = fopen(infile,'r');
if fid>0
data_cell = {};
fs=0;
for ics=1:2000
        s = fgets(fid);
   if (strncmp(s,'# name',6))  %finds all variable lines
        var=sscanf(s(7:10),'%d',1); %reads number, starts at 0
        var=var+1; %left with last (highest) count
        
   end

   if strncmp('*END*',s,5); fs = ics;break; end
   
end
end

if ~exist('var','var')
    warning('No bottles fired on cast %s',aaa);
    break_loop=true;
    return;
end

nvars=var;
data=fscanf(fid,'%f',[nvars inf]);

fclose(fid);

for iv=1:length(vp_bot)
    if vp_bot(iv)==1
        eval([varbotnames{iv,1},'=data(',num2str(varbotnames{iv,2}),',:);'])
    end
end

% now read ctdnnn.wat file: changed to read ctdnnn.int file by MW, Mar07
% because otherwise it read in bad data
varfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var']);
disp(['   Input file = ',varfile])
load ('-mat',varfile)

%find start and stop locations for each bottle
%disp('JR307 cludge for botno (due to not having raw files at Rothera), fine if bottles always fired in order')
botno_fired=unique(bnbf);
bstartscan=nan(size(botno_fired));
bstopscan=bstartscan;
for i=1:length(botno_fired)
    bstartscan(i)=find(scan==min(bscan(find(bnbf==botno_fired(i)))));
    bstopscan(i)=find(scan==max(bscan(find(bnbf==botno_fired(i)))));
 %  botno(i)=i;
end

% if we do want to use/save the data from the .ros file, we need to reduce
% them to median values, too.

bnbf_bak=bnbf;
for iv=1:length(vp_bot)
    if varbotnames{iv,2}>0 % .ros variable 
        tempvar=nan(1,length(botno_fired));
        for i=1:length(botno_fired)
            tempvar(i)=median(eval([varbotnames{iv,1},'(bnbf_bak==botno_fired(i))']),'omitmissing');
        end
        eval([varbotnames{iv,1},'=tempvar;']);
        clear tempvar;
    else % derived / bottle variable - create nan placeholder
        eval([varbotnames{iv,1},'=NaN(1,length(botno_fired));']);
    end
end

for i=1:length(botno_fired)
for iv=1:length(vp_b)
    if vp_b(iv)>=1
       eval(['ctd',varnames{iv,1},'(i)=median(',varnames{iv,1},'(bstartscan(i):bstopscan(i)),''omitmissing'');']);
    end
    if vp_b(iv)>=2
       eval(['std',varnames{iv,1},'(i)=std(',varnames{iv,1},'(bstartscan(i):bstopscan(i)),''omitmissing'');']);
    end
end

    % pumps not useful for JR165 or JR177 as they were often on whilst CTD on deck
%     ctdpumps(i)=median(pumps(bstartscan(i):bstopscan(i)));
    % can't do this as flag is defined within matlab
    %ctdflag(i)=sum(flag(bstartscan(i):bstopscan(i)));
end


% err! finally read .BL file so we know which bottle is where!

infilebl=fullfile(dir_raw,[cruise,'_',sb_prefix,aaa,frame_fileadd,'.bl']);
disp(['   Input file = ',infilebl])

[index,botno]=textread(infilebl,'%n %n %*[^\n]','delimiter',',','headerlines',2);
botno=botno';

otfile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st']);
disp(['   Output file = ',otfile])

save (otfile,'botno','lat','lon','gtime',varbotnames{(vpd_bot==1),1})

else
  break_loop=1;
    return
end

if nargout>0
    break_loop=false;
end
