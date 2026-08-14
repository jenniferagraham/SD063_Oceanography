function break_loop=fallrateGEN(aaa)

%Hugh Venables, June 2008 code for repeating loop-edit type filtering of CTD profile,
%after initial soaking period has been removed.
%Removes data for periods when CTD above a pressure it has already
%reached on the down cast (up cast not treated) and when package moving at <0.25m/s (value
%taken from loop edit default)

%Note: loopedit only flags this data but it isn't removed by seabird
%processing or any post-processing (that I've seen) so this should be run
%even if loop edit has been, or use what loop edit created (so long as it
%can deal with the initial soak period - apparently it can be set to do so
%but I have seen it where it hasn't and the flag is therefore useless)
 
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
eec=CastEvent(find(CastEvent(:,1)==aac),2);
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
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var.dn'])
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var.dn'])
otfile2=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.vhc.dn'])
else
    infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb.dn'])
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb.dn'])
otfile2=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_vhc.clb.dn'])
end

if exist(infile,'file')
    load (infile,'-mat');
    
save(otfile2,'names','gtime','lat','lon',varnames{(vpd==1),1})

    prdiff=diff(press);
    prdiff=[NaN
        prdiff];
    
    k=0;
    K=NaN*press;
    % pressone=NaN*press;
    for i=1:length(press)
        if isfinite(press(i))
            %0.08 is just above the discrete step in pressure output, allowing it to
            %take one step back (as it does as standard)
            if k==0||i==1||(press(i)>(pressmax-0.08))%&&prdiff(i)>0.01) %removes data if data already below it or package going at <0.24m/s
                k=k+1;
                if k==1
                    pressmax=press(i);
                else
                    pressmax=max(press(i),pressmax);
                end
                % potemp1one(k)=potemp1(i);
                % sig0one.*K=sig0(i);
                K(i)=1;   %this is a flag for data to keep
            else
                K(i)=NaN;
                
            end
        end
    end
 
 %K will have large chunks missing and some individual gaps, which are
 %meaningless false-positives (1/12th or 1/24th of a second)
 
 for ik=2:(length(K)-2)
     if isnan(K(ik))&&(isfinite(K(ik-1))&&(isfinite(K(ik+1))||isfinite(K(ik+2))))
        K(ik)=1;
     end
 end

 potempkeep=potemp;
 salinkeep=salin;
 sigma0keep=sigma0;
 presskeep=press;

 iic=find(strcmp(columnuse,'edit_vars'));
sv=size(varnames);
     vpe=zeros(sv(1),1);
     for iv=1:sv(1)
         vpe(iv)=(varnames{iv,2}*varnames{iv,iic})>0;        
     end
     
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'=',varnames{iv,1},'.*K;']);
    end
end

%  press=press.*K;
%   alt=alt.*K;
%   cond1=cond1.*K;
%   cond2= cond2.*K;       
%   flag= flag.*K;
%   scan=scan.*K;
%   fluor_ug_l=fluor_ug_l.*K; 
%   oxygen_ml_l= oxygen_ml_l.*K;
%   oxygen_umol_kg= oxygen_umol_kg.*K;
%   oxygen_V= oxygen_V.*K;
%   par=par.*K;   %not critical to filter PAR...
%   potemp1= potemp1.*K;
%   potemp2=potemp2.*K;   
%   salin1 = salin1.*K;    
%   salin2 = salin2.*K; 
%   sig0 = sig0.*K;   
%   sig2 = sig2.*K;      
%   sig4 = sig4.*K;     
%   temp1= temp1.*K;     
%   temp2 = temp2.*K;      
% BeamTrans=BeamTrans.*K;      
%  
 
%   figure
% plot(press,potemp1,'r-'); hold on
%  plot(presskeep,potemp1keep,'b-')
%  plot(press,potemp1,'r.')
%  plot(presskeep,potemp1keep,'b.')
%  
%  figure
% plot(press,sig0,'r-'); hold on
%  plot(presskeep,sig0keep,'b-')
%  plot(press,sig0,'r.')
%  plot(presskeep,sig0keep,'b.')
%  
%  
%  figure
%  plot(press,salin1,'r-'); hold on
%  plot(presskeep,salinkeep,'b-')
%  plot(press,salin1,'r.')
%  plot(presskeep,salinkeep,'b.')
 
save(otfile,'names','gtime','lat','lon',varnames{(vpd==1),1})

end

if nargout>0
    break_loop=false;
end
