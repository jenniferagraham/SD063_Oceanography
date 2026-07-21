function break_loop=salcalGEN(aaa)
% salcal calculates the adjustment to nominally calibrated CTD salinity
% required to get best fit to bottle data
% Dave 30/4/03
% modified, mmm, CD160, August 2004
 
% modified for JR165 Mar 07 by MIW
% modified for JR177 Jan 08 by MIW
% modified for JR200 Jan 08 by HJV
% modified after SD033 by EPA: MB spotted that the "uncal" variables 
%   were not doing the correct thing, so have been disabled for now!

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


% load file containing bottle salinity, CTD conductivity, CTD temperature,
% CTD deltat and CTD pressure data
 
infile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sal'])
infile3 =fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_2db_up.mat']); 
if ~exist(infile,'file')
    warning('No salinity file for cast %s.',aaa);
    if nargout>0
        break_loop=false;
    end
    return;
end
load (infile,'-mat');

if isempty(samplesals)
    warning('Salinity file exists, but no samples on cast %s.',aaa);
    if nargout>0
        break_loop=false;
    end
    return;
end

infile2=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var']); 
load (infile2,'-mat');

if ctchoice==2   % preferentially use our secondary CTD temperature 
    t90=ctdtemp2;
else
    t90=ctdtemp1;
end 
%botcond=sw_c3515*sw_cndr(samplesals,t90',ctdpress');


%botcond=gsw_C_from_SP(samplesals,t90',ctdpress');


%really need to check salt bottles have been used in order
%have niskinnums and samplesals from the samples. Length=number of samples.
%Order=as per CTD/csv file creation step
%have ctdcond1(2) and niskinind. Length=number of unique niskins sampled
%Order=increasing numerical. Includes all bottles in niskinnums (once)


for ik=1:length(niskinnums)
iin=find(botno(niskinind)==niskinnums(ik),1,'first');
botcond(ik)=gsw_C_from_SP(samplesals(ik),t90(iin),ctdpress(iin));
offset1(ik)=botcond(ik)-ctdcond1(iin);

if exist('ctdcond2','var')
offset2(ik)=botcond(ik)-ctdcond2(iin);
end

end


% offset1_uncal=botcond_uncal-ctdcond1';  %assumes salt samples were done in order
% offset2_uncal=botcond_uncal-ctdcond2';  %not generalised for just one T/C set, could easily create a separate version for that

display(['Getting data from ',infile3])
load (infile3,'-mat'); 
for ic=1:length(ctdpress)
    if isfinite(ctdpress(ic))
        ctdgrad1(ic)=cond1(max(floor(ctdpress(ic)/2),1))-cond1(ceil(ctdpress(ic)/2));
        ctdgrad2(ic)=cond2(max(floor(ctdpress(ic)/2),1))-cond2(ceil(ctdpress(ic)/2));
    else
        ctdgrad1(ic)=NaN;
        ctdgrad2(ic)=NaN;
    end
end

nnn=str2num(aaa(1:3));  %in case text appended
otfile=fullfile(dir_out,'salts','salcals12.all.mat');
if exist(otfile,'file')
    load (otfile)
    l=find(nnn==stn,1);
    if isempty(l)
        l=length(stn)+1;
    end
   
else
    l=1;
end


stn(l)=nnn;

for ik=1:length(niskinnums)
  
iin=find(botno(niskinind)==niskinnums(ik),1,'first');
botnum(ik,l)=niskinnums(ik);  
bots(ik,l)=samplesals(ik);   %sample
botc(ik,l)=botcond(ik);      %back-calculated from sample using CTD temperature

botpress(ik,l)=ctdpress(iin);
ctdt1(ik,l)=ctdtemp1(iin);
ctdc1(ik,l)=ctdcond1(iin);
ctds1(ik,l)=ctdsalin1(iin);
stdt1(ik,l)=stdtemp1(iin); 
stdc1(ik,l)=stdcond1(iin);
ctdgradc1(ik,l)=ctdgrad1(iin);

if exist('ctdcond2','var')

ctdt2(ik,l)=ctdtemp2(iin);
ctdc2(ik,l)=ctdcond2(iin);
ctds2(ik,l)=ctdsalin2(iin); 
stdt2(ik,l)=stdtemp2(iin);
stdc2(ik,l)=stdcond2(iin); 
ctdgradc2(ik,l)=ctdgrad2(iin); 
end

end

 botnum(botnum==0)=NaN;
 botpress(isnan(botnum))=NaN;
bots(isnan(botnum))=NaN;
 botc(isnan(botnum))=NaN;
%sb35temp(1:length(niskinnums),l)=sb35calt; sb35temp(isnan(botnum))=NaN;
 ctdt1(isnan(botnum))=NaN;
 ctdt2(isnan(botnum))=NaN;
 ctdc1(isnan(botnum))=NaN;
 ctdc2(isnan(botnum))=NaN;
 ctds1(isnan(botnum))=NaN;
ctds2(isnan(botnum))=NaN;
stdt1(isnan(botnum))=NaN;
 stdt2(isnan(botnum))=NaN;
 stdc1(isnan(botnum))=NaN;
stdc2(isnan(botnum))=NaN;

condoff1(1:length(niskinnums),l)=offset1; condoff1(isnan(botnum))=NaN;
condoff2(1:length(niskinnums),l)=offset2; condoff2(isnan(botnum))=NaN;
% condoff1_uncal(1:length(niskinnums),l)=offset1_uncal; condoff1_uncal(isnan(botnum))=NaN;
% condoff2_uncal(1:length(niskinnums),l)=offset2_uncal; condoff2_uncal(isnan(botnum))=NaN;
 ctdgradc1(isnan(botnum))=NaN;
ctdgradc2(isnan(botnum))=NaN;

%eval(['save ' otfile ' stn botnum botpress bots botc sb35temp ctdt1 ctdt2 ctds1 ctds2 ctdc1 ctdc2 stdt1 stdt2 stdc1 stdc2 condoff1 condoff2'])
% eval(['save ' otfile ' stn botnum botpress bots botc ctdt1 ctdt2 ctds1 ctds2 ctdc1 ctdc2 stdt1 stdt2 stdc1 stdc2 condoff1 condoff2 condoff1_uncal condoff2_uncal ctdgradc1 ctdgradc2'])
save(otfile,'stn','botnum','botpress','bots','botc','ctdt1','ctdt2',...
    'ctds1','ctds2','ctdc1','ctdc2','stdt1','stdt2','stdc1','stdc2',...
    'condoff1','condoff2',... % previously also included 'condoff1_uncal','condoff2_uncal',...
    'ctdgradc1','ctdgradc2')

% clear ctd* bot* std* cond*

% end
% end

% format long
% offset1=off1
% offset2=off2
% format short

% eval(['save ' infile ' offset1 offset2 -append']); 

% recalculate salinity
% nctdsal1=ds_salt(ctdcond1+offset1,t68emp1,ctdpress);
% nctdsal2=ds_salt(ctdcond2+offset2,t68emp2,ctdpress);
% 
% subplot(3,1,3)
% hold on
% if length(unique(niskinnums))~=length(samplesals)
%     f1=find(diff(niskinnums)==0);
%     f2=find(diff(niskinnums)~=0);
% else
%     f1=[];
%     f2=(1:length(samplesals));
% end
% plot(samplesals(f2)'-nctdsal1(f2),ctdpress(f2),'b*')
% plot(samplesals(f2)'-nctdsal2(f2),ctdpress(f2),'g*')
% plot(samplesals(f1)'-nctdsal1(f1),ctdpress(f1),'bo')
% plot(samplesals(f1)'-nctdsal2(f1),ctdpress(f1),'bo')
% axis ij
% ylabel 'pressure'
% xlabel '\Delta S'
% % o1= sprintf('%f',off1);
% % o2= sprintf('%f',off2);
% tle=strcat('calibrated (with offset) salinity errors for stn ',nnn);
% % tle=strcat('calibrated (with offset) salinity errors for stn ',nnn, '-
% % offset 1=',o1,', offset 2 =',o2);
% title(tle)
% 
%%option to save figure file for each ctd
% eval(['print -dpsc sal',nnn]);

if nargout>0
    break_loop=false;
end

