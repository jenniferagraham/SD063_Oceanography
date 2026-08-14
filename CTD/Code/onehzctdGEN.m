function break_loop=onehzctdGEN(aaa,fileow)

% onehzctd averages data from a 24hz CTD profile to 1hz
%'dead-end' output for LADCP processing

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
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.1hz'])
else
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb'])
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'_cal.1hz'])
end

if nargin<2
    fileow=0;
end
if exist(otfile,'file')  %?add override in batch file?
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

load (infile,'-mat');

%
% which gridding variable and parameters?
%

% alternative is to use "scan" with delz=24. Does this actually make any difference?

grivar='time_elapsed';
mingrdvar=.5;
delz=1;
eval(['maxgrdvar=max(' grivar ');']);

nrows=ceil((maxgrdvar-mingrdvar+(delz/2))/delz);
norecs=length(scan);
novar=sum(double(vpd==1));
zgrid=[0:nrows-1]*delz + mingrdvar;

eval(['grdvar=' grivar ';']);
zmax=zgrid+delz/2;
zmin=zgrid-delz/2;

var=nan(novar,nrows);
var_ind=find(vpd==1);

try
    varin=zeros(novar,norecs);
    for k=1:novar
        eval(['varin(k,:)=',varnames{var_ind(k),1},''';']);
    end
    for j=1:nrows
        var(:,j)=mean(varin(:,(grdvar >= zmin(j) & grdvar < zmax(j))),2,"omitmissing");
    end
catch %probably out of memory...
    warning('Using slower version...');
    for j=1:nrows
        a=find(grdvar >= zmin(j) & grdvar < zmax(j));
        for k=1:novar
            eval(['var(k,j)=mean(',varnames{var_ind(k),1},'(a),"omitmissing");']);
        end
    end
end

for k=1:novar
    eval([varnames{var_ind(k),1},'=var(k,:)'';'])
end
% zgrid(zmin>max(eval(grivar)))=nan; % this lines sets the pressures above max. pressure to nan. Is this really a good thing to do?
eval([grivar,'=zgrid'';'])

%iipg=sum(isnan(press))

save(otfile,'names','gtime','lat','lon',varnames{(vpd==1),1});

if nargout>0
    break_loop=false;
end