function break_loop=deriveGEN(aaa,fileow)

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


if ~(strcmp(ctchoice,'1')||strcmp(ctchoice,'2'))
    error('ctchoice must be set in CTDvarn, and must be ''1'' or ''2''.');
end

% load file containing CTD data

infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.edt'])  %was .int but no need to interpolate interpolate
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var'])
if exist(infile,'file')  
load (infile,'-mat');
else
       break_loop=true;
        return;
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

if exist('lonscan','var') && exist('latscan','var') % update position to start of downcast
  %  indstart=find(~isnan(cond1),1);

    iic1=find(isfinite(cond1), 1 ); 
    if exist('cond2','var')
iic2=find(isfinite(cond2), 1 );
indstart=min(iic1,iic2);  %start of downcast
    else
        indstart=iic1;
    end
if isfinite(indstart)
    disp(sprintf('Updating cast start position from %.4f° %.4f° to %.4f° %.4f°',...
        lat,lon,latscan(indstart),lonscan(indstart)));
    lon=lonscan(indstart);
    lat=latscan(indstart);
else
    %never a big change anyway
end
end

temp=eval(['temp',ctchoice]);

salin1=gsw_SP_from_C(cond1,temp1,press);  %for cond in S/m need a 10*
ii=press<-1.5;
press(ii)=-1.5; %These are out of the water (probably)
if sum(isfinite(cond1(ii)))
warning('pressure <-1.5 in water, adjusted')
end
asalin1 = gsw_SA_from_SP(salin1,press,lon,lat);
if exist('temp2','var') && exist('cond2','var')
    salin2=gsw_SP_from_C(cond2,temp2,press);
asalin2 = gsw_SA_from_SP(salin2,press,lon,lat);
end
salin=eval(['salin',ctchoice]);
asalin=eval(['asalin',ctchoice]);

%potemp1=sw_ptmp(salin1,temp1,press,0);
potemp1 = gsw_pt_from_t(asalin1,temp1,press,0);
 Ctemp1 = gsw_CT_from_t(asalin1,temp1,press);
if exist('temp2','var') && exist('cond2','var')
    %potemp2=sw_ptmp(salin2,temp2,press,0);
    potemp2 = gsw_pt_from_t(asalin2,temp2,press,0);

 Ctemp2 = gsw_CT_from_t(asalin2,temp2,press);
end
potemp=eval(['potemp',ctchoice]);
Ctemp=eval(['Ctemp',ctchoice]);

if exist('oxygen_umol_kg','var') && ~exist('oxygen1_umol_kg','var')
    oxygen1_umol_kg=oxygen_umol_kg;
end
if exist('oxygen_V','var') && ~exist('oxygen1_V','var')
    oxygen1_V=oxygen_V;
end

% apply hysteresis correction - check that this has not already been
% applied in datcnv!
non_edit=load('-mat',...
    fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.red']),'oxygen1_umol_kg','oxygen2_umol_kg');
if ~isfield(non_edit,'oxygen1_umol_kg')
    non_edit.oxygen1_umol_kg=non_edit.oxygen_umol_kg;
end
oxygen1_mask=isnan(oxygen1_umol_kg);
oxygen1_umol_kg=oxygenhysteresis(time_elapsed,press,non_edit.oxygen1_umol_kg);
oxygen1_umol_kg(oxygen1_mask)=nan;


if exist('oxygen2_umol_kg','var')
    oxygen2_mask=isnan(oxygen2_umol_kg);
    oxygen2_umol_kg=oxygenhysteresis(time_elapsed,press,non_edit.oxygen2_umol_kg);
    oxygen2_umol_kg(oxygen2_mask)=nan;
end

if exist('oxygen1_umol_kg','var') && exist('oxygen2_umol_kg','var')
    oxygen_umol_kg=eval(['oxygen',ctchoice,'_umol_kg']);
else
    oxygen_umol_kg=oxygen1_umol_kg;
end

sigma0 = gsw_sigma0(asalin,Ctemp);
sigma2 = gsw_sigma2(asalin,Ctemp);
sigma4 = gsw_sigma4(asalin,Ctemp);
% 
% sig0=sw_pden(salin,temp,press,0)-1000;
% sig2=sw_pden(salin,temp,press,2000)-1000;
% sig4=sw_pden(salin,temp,press,4000)-1000;

%if ~exist('depth','var')
 %   depth=sw_dpth(press,lat);
    depth=-gsw_z_from_p(press,lat);
%end
    
% varl='';
% for iv=1:length(vpd)
%     if vpd(iv)==1
%        varl= [varl,' ',varnames{iv,1},];
%     end
% end
% eval(['save ',otfile,' names gtime lat lon ',varl,])
save(otfile,'names','gtime','lat','lon',varnames{(vpd==1),1})


%save (ctdsave,'names','gtime','lat','lon','time_elapsed','scan','press','temp1','temp2','cond1','cond2', ...
%    'oxy_ml_l','oxy_umol_Kg','oxy_raw','fluor_ug_l','par','BeamTrans','latscan','lonscan','alt','flag','salin1','salin2','potemp1','potemp2','sig0','sig2','sig4','depth','pumps','PressTemp');

%clear

if nargout>0
    break_loop=false;
end
