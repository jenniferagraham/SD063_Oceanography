function break_loop=oxycalGEN(aaa)


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

% load file
 
infile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.oxy']);
infile3 =fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.2db.up.mat']); 
% if exist(infile,'file')
load (infile,'-mat');

if isempty(sampleoxy)
    if nargout>0
        break_loop=false;
    end
    return;
end

infile2=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var']); 
load (infile2,'-mat');

botoxy_umol_kg =botoxy_umol_kg' ; 

%for ik=1:length(niskinind)

%iin=find(niskinind(ik)==niskinnums,1,'first');  %needed if bottle numbers
%out of order

offset1=botoxy_umol_kg(niskinind)-ctdoxygen1_umol_kg(niskinind);

if exist('ctdoxygen2_umol_kg','var')
offset2=botoxy_umol_kg(niskinind)-ctdoxygen2_umol_kg(niskinind);
else
   offset2=NaN*offset1;  
end



% % % % offset1=sampleoxy-ctdoxygen1_umol_kg';  %are these the same units?
% % % % offset2=sampleoxy-ctdoxygen2_umol_kg';
% might need to put this back in once calibrations are done? - MB
% offset1_uncal=botoxy_uncal-ctdoxygen1_umol_kg'; 
% offset2_uncal=botoxy_uncal-ctdoxygen2_umol_kg';  %not generalised for just one T/C set, could easily create a separate version for that

nnn=str2num(aaa(1:3))  %in case text appended
otfile=fullfile(dir_out,'oxygen','oxycals.all.mat');
if exist(otfile,'file')
    load (otfile)
   
    for i=1:length(stn)
        if stn(i)==nnn
            l=i;
        else
            l=[];
        end
    end
    if isempty(l)
        l=length(stn)+1;
    end
else
    l=1;
end

stn(l)=nnn;

ln=length(niskinind);
botnum(1:ln,l)=niskinind;  

botpress(1:ln,l)=ctdpress(niskinind);
ctdt1(1:ln,l)=ctdtemp1(niskinind);
ctdc1(1:ln,l)=ctdcond1(niskinind);

ctdO1_kg(1:ln,l)=ctdoxygen1_umol_kg(niskinind);
ctds1(1:ln,l)=ctdsalin1(niskinind);
stdt1(1:ln,l)=stdtemp1(niskinind); 
stdc1(1:ln,l)=stdcond1(niskinind);
%ctdgradc1(ik,l)=ctdgrad1(iin);

if exist('ctdoxygen2_umol_kg','var')

ctdt2(1:ln,l)=ctdtemp2(niskinind);
ctdc2(1:ln,l)=ctdcond2(niskinind);
ctds2(1:ln,l)=ctdsalin2(niskinind); 
stdt2(1:ln,l)=stdtemp2(niskinind);
stdc2(1:ln,l)=stdcond2(niskinind); 
ctdO2_kg(1:ln,l)=ctdoxygen2_umol_kg(niskinind);
%ctdgradc2(ik,l)=ctdgrad2(iin); 
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
 ctdO1_kg(isnan(botnum))=NaN;
 ctdO2_kg(isnan(botnum))=NaN;
 ctds1(isnan(botnum))=NaN;
ctds2(isnan(botnum))=NaN;
stdt1(isnan(botnum))=NaN;
 stdt2(isnan(botnum))=NaN;
 stdc1(isnan(botnum))=NaN;
stdc2(isnan(botnum))=NaN;



oxyoff1(1:ln,l)=offset1; oxyoff1(isnan(botnum))=NaN;
oxyoff2(1:ln,l)=offset2; oxyoff2(isnan(botnum))=NaN;
% oxyoff1_uncal(1:length(niskinnums),l)=offset1_uncal; oxyoff1_uncal(isnan(botnum))=nan;
% oxyoff2_uncal(1:length(niskinnums),l)=offset2_uncal; oxyoff2_uncal(isnan(botnum))=nan;
otfile
save(otfile,'stn','botnum','botpress','ctdt1','ctdt2',...
    'ctds1','ctds2','ctdc1','ctdc2','stdt1','stdt2','stdc1','stdc2',...
    'ctdO1_kg','ctdO2_kg','oxyoff1','oxyoff2') % also included 'oxyoff1_uncal','oxyoff2_uncal', before

if nargout>0
    break_loop=false;
end
