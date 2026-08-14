function break_loop=sb35readGEN(aaa)

%function to read in the SB35 output from *.cap and put it in the
%matlab file botnnn.sb35 where nnn is the station number.
%MRP on JR97, 19/2/05
%Amended for JR141, Jan 2006. Deb Shoosmith
%Amended for JR165, March 2007, Brandon & MW
% Amdended for JR177, Jan 2008 by MW

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

%% read in the raw sbe file file


infile=fullfile(dir_SBE35,[cruise,'_',sb35_prefix,aaa,frame_fileadd,sb35_fileadd,'.asc']);
infile2=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st']);
infile3=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_2db_up.mat']);
% infile4=fullfile(dir_out,[cruise,'_ctd_',aaa,'.red']);
display(['Getting data from ',infile])
outfile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sb35']);

% epab: commented this out, since this is also in the .1st file
% %% read in the time of the CTD
% load(infile4,'-mat','gtime');

%% read from  the SBE file
fid=fopen(infile,'rt');
if fid<0
    warning('No SBE35 file for cast %s.',aaa);
    if nargout>0
        break_loop=false;
    end
    return;
end
finished=0; i=1;
while finished<1 & ~feof(fid)
  fline=upper(fgetl(fid));
  if findstr('DD',fline)
    range=sscanf(fline,'DD%d,%d');
    if range(1)<1, range(1)=1; end % even if you've specified zero, the SBE35 will start at 1!
    scans=range(2)-range(1)+1;
    for i=1:scans
        fline=upper(fgetl(fid));
        if (isnumeric(fline) && fline<0) || isempty(strtrim(fline))
            finished=1;
            break;
        end
        for j=1:17
            [data{j}, fline]=strtok(fline);
        end
       
        sb35scan(i)=str2num(data{1});
        sb35date{i}=[data{5} ' ' data{2} ' ' data{3} ' ' data{4}];
        sb35botno(i)=str2num(data{8});
        sb35rawrange(i)=str2num(data{11});
        sb35rawval(i)=str2num(data{14});
        sb35caltemp(i)=str2num(data{17});
    end
  end
end
fclose(fid);

% EPA, SD041: I have commented out all of the following lines, since they
% will remove data when bottles have not been fired in sequential (and/or 
% increasing) order. In addition, there is a risk that they may remove data 
% if the SBE35 clock has not been set correctly or has drifted badly (this 
% shouldn't happen, but regularly does). You should ensure that your SBE35 
% data match the correct cast! But we'll still include a warning, just in
% case...

load(infile3,'gtime','time_elapsed');
ctdtime=datenum(gtime(1:6));
sbetime=datenum(sb35date);
if min(sbetime)<ctdtime
    warning('Your SBE35 file starts before the CTD cast! Check that this is the correct file.');
end
if exist('time_elapsed','var')
    ctd_endtime=ctdtime+max(time_elapsed)./24./3600;
    if max(sbetime)>(ctd_endtime + 0.1./24) % allow six minutes... 
        warning('Your SBE35 file ends more than six minutes after the CTD cast! Check that this is the correct file.');
    end
end

% caststart=min(find(sbetime>ctdtime));
% castends=[find(diff(sb35botno)<0),length(sb35botno)]; %end of cast
% castend=castends(min(find(castends>caststart)));
% 
% sb35scan=sb35scan(caststart:castend);
% sb35date=sb35date(caststart:castend);       disp(['    Bottle numbers: '])
% sb35botno=sb35botno(caststart:castend);     disp(sb35botno)
% sb35rawrange=sb35rawrange(caststart:castend);
% sb35rawval=sb35rawval(caststart:castend);
% sb35caltemp=sb35caltemp(caststart:castend);
% 
% if isempty(sb35scan)
%     error('You must have the wrong SBE35 file... No bottles found for this cast');
%     %HJV JR200: I wouldn't be so sure. If the SB35 time is out by seven
%     %hours then this bit will fail
% end
save(outfile,'sb35*')  

% clear

display(['Getting data from ',infile2])
load (infile2,'-mat');
%ctdpress
if ~sum(isfinite(sb35temp))
    clear sb35temp
end

nnn=str2num(aaa(1:3));

display(['Getting data from ',infile3])
load (infile3,'-mat');
for ic=1:length(ctdpress)
     if isfinite(ctdpress(ic))
        ctdgrad1(ic)=temp1(max(floor(ctdpress(ic)/2),1))-temp1(ceil(ctdpress(ic)/2));
        ctdgrad2(ic)=temp2(max(floor(ctdpress(ic)/2),1))-temp2(ceil(ctdpress(ic)/2));
     else
        ctdgrad1(ic)=NaN;
        ctdgrad2(ic)=NaN;
     end
end
 

filetc=fullfile(dir_out,'SBE35','tempcals.all.mat');
if exist(filetc,'file')
    load(filetc)
   l=find(nnn==stn,1);
    if isempty(l)
        l=length(stn)+1;
    end
else
    l=1;
end

%assume for now these are standard variables...


stn(l)=nnn;
botn(1:length(sb35botno),l)=sb35botno; botn(botn==0)=NaN;
[~,~,sb35botind]=intersect(sb35botno,botno);
botp(1:length(sb35botno),l)=ctdpress(sb35botind); botp(isnan(botn))=NaN;
% botp(1:length(sb35botno),l)=ctdpress([1,3,5,7,9,11,13,15:23]); botp(isnan(botn))=NaN;

% length(sb35botind)
sb35temp(1:length(sb35botind),l)=sb35caltemp; 
sb35temp(sb35temp==0)=NaN; %not great, but a lot of decimal places to save us
%sb35temp(isnan(botn),l)=NaN;

ctdt1(1:length(sb35botno),l)=ctdtemp1(sb35botind); ctdt1(isnan(botn))=NaN;
ctdt2(1:length(sb35botno),l)=ctdtemp2(sb35botind); ctdt2(isnan(botn))=NaN;
stdt1(1:length(sb35botno),l)=stdtemp1(sb35botind); stdt1(isnan(botn))=NaN;
stdt2(1:length(sb35botno),l)=stdtemp2(sb35botind); stdt2(isnan(botn))=NaN;
ctdgradt1(1:length(sb35botno),l)=ctdgrad1(sb35botind); ctdgradt1(isnan(botn))=NaN;
ctdgradt2(1:length(sb35botno),l)=ctdgrad2(sb35botind); ctdgradt2(isnan(botn))=NaN;





% if exist('temp1flag','var')==1
%     eval(['save C:\hjv\JR17003\CTD\procMB\SBE35\tempcals.all.mat stn botn botp sb35temp ctdt1 ctdt2 stdt1 stdt2 temp1flag temp2flag'])
% else
%     eval(['save  ',filetc,' stn botn botp sb35temp ctdt1 ctdt2 stdt1 stdt2 ctdgradt1 ctdgradt2'])
%end
if ~exist(fullfile(dir_out,'SBE35'),'dir')
    mkdir(fullfile(dir_out,'SBE35'));
end
save(filetc,'stn','botn','botp','sb35temp','ctdt1','ctdt2','stdt1','stdt2','ctdgradt1','ctdgradt2');

clear sb35*
% figure
% plot(sb35temp-ctdt1,ctdpress,'b*',sb35temp-ctdt2,ctdpress,'r*')
% axis ij, grid on
% %ax=axis; axis([-.1 .1 ax(3) ax(4)])
% % axis([-0.07 0.07 0 max(ctdpress)+10]) %ceil(max(ctdpress)/100)*100])
% ylim([0 max(ctdpress)+10])
% xlabel 'Temperature difference / ^oC'
% ylabel 'Pressure / db'
% title(['Station ' aaa ' SB35: sb35-t1 is blue, sb35-t2 is red'])
% setfigA4

if nargout>0
    break_loop=false;
end
