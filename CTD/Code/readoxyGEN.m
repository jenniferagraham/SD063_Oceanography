function break_loop=readoxyGEN(aaa)
%
% reads oxygen from excel spreadsheet file
% into matlab bottle file 
%
% Written for SD033 following readsalGEN.m - Milo Bischof
%
%

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
ee=num2str(eec);
else 
    eee=input('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n','s');  %new cast
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end
end

oxyfile=fullfile(dir_oxy,['',cruise,'_oxy_event_',ee,'.csv'])

if ~exist(oxyfile)
    warning('Oxygen file does not exist!');
    sampleoxy=[];
    niskinnums=[];
     samplevol=[];
    sampletemp=[];
else
    datacsv=readmatrix(oxyfile);
    oxydim=size(datacsv);
    %datacsv=csvread(oxyfile);
    sampleoxy = datacsv(9:oxydim(1),14);
    niskinnums= datacsv(9:oxydim(1),2);
    samplevol=datacsv(9:oxydim(1),10);
    sampletemp=datacsv(9:oxydim(1),9);
end
sampleoxy=sampleoxy(~isnan(niskinnums)); %umol/l, not umol/kg
niskinnums=niskinnums(~isnan(niskinnums));
% samplevol=samplevol(~isnan(niskinnums)); %oxygen sample bottle volume, at fixing temperature, excluding reagent volume
 sampletemp=sampletemp(~isnan(niskinnums)); %fixing temperature

if ~exist(fullfile(dir_out,'oxygen'),'dir')
    mkdir(fullfile(dir_out,'oxygen'));
end

%% calculate oxygen for each Niskin bottle
fname=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st'])
load (fname,'-mat');  %% get botno from botnnn.1st file
%also need salinity from bottle file to get water density at fixing

%% put duplicate data into structure array 'nisk' and save as niskinoxygens.mat
samples=sort(niskinnums);
dd=diff(samples);
n=1;
for m=1:length(dd)
    if dd(m)==0
        sfl(n)=samples(m);
        bot(n,:)=find(niskinnums==sfl(n));
        n=n+1;
    end
end
if exist('sfl','var')==1
    fileoxy=fullfile(dir_out,'oxygen','niskinoxygens.mat')
    if exist(fileoxy,'file')==2
        load(fileoxy)
        kk=0;
        for k=1:length(nisk)
            if nisk(k).stn==aaa
                kk=k;
            end
        end
        if kk==0
            nisk(length(nisk)+1)=struct('stn',aaa,'bot',sfl,'S1',sampleoxy(bot(:,1)),'S2',sampleoxy(bot(:,2)));
        else
            nisk(kk)=struct('stn',aaa,'bot',sfl,'S1',sampleoxy(bot(:,1)),'S2',sampleoxy(bot(:,2)));
        end

        save (fileoxy,'nisk','-append')
    else
        nisk(1)=struct('stn',aaa,'bot',sfl,'S1',sampleoxy(bot(:,1)),'S2',sampleoxy(bot(:,2)));
        save (fileoxy,'nisk')
    end
    % % added MB SD033
    % for ii=1:length(sfl)
    %     sampleoxy(length(sampleoxy)+1) = mean([sampleoxy(bot(ii,1)) sampleoxy(bot(ii,2))],'omitnan') ;
    %     niskinnums(length(niskinnums)+1) = sfl(ii) ;
    %     sampleoxy(bot(ii,1)) = nan ;
    %     sampleoxy(bot(ii,2)) = nan ;
    % end
    % niskinnums = niskinnums(~isnan(sampleoxy(1:length(niskinnums)))) ;
    % sampleoxy = sampleoxy(~isnan(sampleoxy)) ;
end


%    botsal = niskinnums+nan;   % botno = Niskin bottle nums
botoxy=NaN*ones(length(botno),1);
%botsamplevol=botoxy;
botfixtemp=botoxy;
for i=botno
    f = find(niskinnums==i);
    if ~isempty(f)
        % if std(sampleoxy(f))>0.002
        %     disp(' ')
        %     disp(['Large standard deviation for bottle ',num2str(i),' oxygen']);
        %     disp(' ')
        % end
        botoxy(i) = mean(sampleoxy(f),'omitnan');  
      %  botsamplevol(i)=mean(samplevol(f),'omitnan'); 
        botfixtemp(i)=mean(sampletemp(f),'omitnan'); 
    end
end

%now have sample oxy (ml/l) and fixing temperature in same form as bottle salinity
%so can calculate an (uncalibrated) density to convert units
%if have salinity samples everywhere, could use them instead

 botsampleCtemp = gsw_CT_from_t(ctdasalin,botfixtemp',0); %fixing temperature
 botsamplesigma0 = (gsw_sigma0(ctdasalin,botsampleCtemp)+1000)/1000;  %full (uncalibrated) density at point of sampling, kg/l

botoxy_umol_kg=botoxy./botsamplesigma0';  %(umol/l).(1/dens)=(umol/kg)
%[botoxy botoxy_umol_kg]
% save to matlab file


otfile=fullfile(dir_out,'oxygen',[cruise,'_oxy_',aaa,'',frame_fileadd,'',eee,'.mat'])
save (otfile,'sampleoxy','niskinnums','botoxy','botoxy_umol_kg','botsampleCtemp','botfixtemp','botsamplesigma0')

if nargout>0
    break_loop=false;
end
