function break_loop=readsalGEN(aaa)
%
% readsal reads salinity from excel spreadsheet file (jr165_salts_master.xls)
% into matlab bottle file (salnnn.mat)
%
% Modified by DRS for JR141 (Feb 2006)
%    because more than one sample may have been taken from a
%    Niskin bottle, and not all Niskin bottles were sampled,
%    take the mean of multiple samples & place a NAN by niskins
%    that weren't sampled.

% modified for JR165 Mar 07 by MIW
% modified for JR177 Jan 08 by MIW
% Stores data from all samples instead of taking means of duplicates.
% Duplicate data stored in structure array 'nisk' in niskinsalts.mat

%    disp(' '); disp('*** readsal.m ***')

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


salfile=fullfile(dir_salts,['output_sal_',cruise,'_',aaa,'.csv']);


if ~exist(salfile)
    warning('Salinity file %s does not exist!',salfile)
    samplesals=[];
    niskinnums=[];
else
    datacsv=readmatrix(salfile);

    samplesals=datacsv(:,4);  %column four as calculating salinities within matlab
    niskinnums=datacsv(:,2);
end
samplesals=samplesals(~isnan(niskinnums));
niskinnums=niskinnums(~isnan(niskinnums));

if ~exist(fullfile(dir_out,'salts'),'dir')
    mkdir(fullfile(dir_out,'salts'));
end

%% calculate salinity for each Niskin bottle
fname=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.1st'])
load ('-mat',fname,'botno')   %% get botno from botnnn.1st file

%% put duplicate data into structure array 'nisk' and save as niskinsalts.mat
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
    filesalt=fullfile(dir_out,'salts','niskinsalts.mat')
    if exist(filesalt,'file')==2
        load(filesalt)
        kk=0;
        for k=1:length(nisk)
            if nisk(k).stn==aaa
                kk=k;
            end
        end
        if kk==0
            nisk(length(nisk)+1)=struct('stn',aaa,'bot',sfl,'S1',samplesals(bot(:,1)),'S2',samplesals(bot(:,2)));
        else
            nisk(kk)=struct('stn',aaa,'bot',sfl,'S1',samplesals(bot(:,1)),'S2',samplesals(bot(:,2)));
        end
        save (filesalt,'nisk','-append')
    else
        nisk(1)=struct('stn',aaa,'bot',sfl,'S1',samplesals(bot(:,1)),'S2',samplesals(bot(:,2)));
        save (filesalt,'nisk')
    end
%     % added MB SD033 - commented out by EPA for now
%     for ii=1:length(sfl)
%         samplesals(length(samplesals)+1) = mean([samplesals(bot(ii,1)) samplesals(bot(ii,2))],'omitnan') ;
% %         samplecond(length(samplecond)+1) = mean([samplecond(bot(ii,1)) samplecond(bot(ii,2))],'omitnan') ;
%         niskinnums(length(niskinnums)+1) = sfl(ii) ;
%         samplesals(bot(ii,1)) = nan ;
%         samplesals(bot(ii,2)) = nan ;
%     end
% %     samplecond = samplecond(~isnan(samplesals(1:length(samplecond)))) ;
%     niskinnums = niskinnums(~isnan(samplesals(1:length(niskinnums)))) ;
%     samplesals = samplesals(~isnan(samplesals)) ;
end

%    botsal = niskinnums+nan;   % botno = Niskin bottle nums
botsal=nan*ones(24,1);
for i=botno
    f = find(niskinnums==i);
    if ~isempty(f)
        if std(samplesals(f))>0.002
            disp(' ')
            disp(['Large standard deviation for bottle ',num2str(i),' salinity']);
            disp(' ')
        end
        botsal(i) = nanmean(samplesals(f));  % salinity of Niskin
    end
end

% set up salinity flag
b=find(isnan(botsal)==1);
a=size(botsal,1);
salflag=ones(a,1);
salflag(b)=0;
salflag = ones(size(botsal));
salflag(isnan(botsal))=0;

% save to matlab file

otfile=fullfile(dir_out,'salts',[cruise,'_sal_',aaa,'',frame_fileadd,'',eee,'.mat'])
save (otfile,'samplesals','niskinnums','botsal','salflag')

if nargout>0
    break_loop=false;
end
