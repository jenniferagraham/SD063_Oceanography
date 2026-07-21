%function break_loop=fallrateGEN(aaa)

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
 
%if nargin<1
    aaa=input('Station number?\n','s');
% elseif ~ischar(aaa)
%     aaa=num2str(aaa);
% end
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];
disp(['processing cast ',aaa])

CTDvarn

infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.vhc.dn']) %.var  %allowing it to be rerun for testing
otfile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.var.dn'])
otfile2=fullfile(dir_out,[cruise,'_ctd_',aaa,'.vhc.dn'])


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
 %meaningless false-positives (1/8th, 1/12th or 1/24th of a second)
 
 Ksmk=3;
 for ik=2:(length(K)-Ksmk)
     if isnan(K(ik))&&(isfinite(K(ik-1))&&(sum(isfinite(K(ik:ik+Ksmk)))))
        K(ik)=1;
     end
 end
 
 %K can also have individual "good" points amongst bad, which throw next
 %section off
 Ksmr=12;
for ik=(Ksmr+1):(length(K)-(Ksmr+1))
     if isfinite(K(ik))&&(isnan(nanmean(K(ik-Ksmr):K(ik-1)))&&isnan(nanmean(K(ik+1):K(ik+Ksmr))))
        K(ik)=NaN;
     end
end
 
for kloop=1:3
 
 iic=find(isfinite(cond1),1);
 Kc=0*K;
 
 for ikc=(iic+1):length(K)
     if K(ikc)==1
         Kc(ikc)=0;
     else
         Kc(ikc)=Kc(ikc-1)+1;
     end
 end
 
 %Make blocks of the highest count
 Kb=NaN*Kc;
 for ikb=2:(length(K)-1)
     if Kc(end-ikb)==0
         Kb(end-ikb)=0;
     else
         Kb(end-ikb)=max(Kc(end-ikb),Kb(end-(ikb-1)));
     end
 end
 
 Kcd=[0; diff(Kb)]; %large absolute numbers correspond to first and last "good" data after a gap
 
 TimeInt=12;
 DepthInt=1;
 DepthRef=2;
 
 ii=find(Kcd>TimeInt);
 jj=find(Kcd<-TimeInt);
 
 if ~isempty(ii)
     for ick=1:length(ii)
     if (press(ii(ick))-min(press))<DepthInt
          break   %too close to the start
     end 
     if (press(ii(ick))-max(press))>-DepthInt
          break   %too close to the end
     end 
      
   %   if (press(ii(ick))-min(press))>(DepthInt+DepthRef)&&(press(ii(ick))-max(press))<-(DepthInt+DepthRef)
     iip3=find(press<(press(ii(ick))-DepthInt)&press>(press(ii(ick))-(DepthInt+DepthRef)));  
    % iip2=find(press>(press(jj(ick))+DepthInt)&press<(press(jj(ick))+(DepthInt+DepthRef))); 
     iipuse=[iip3];%; iip3];
   %   end
 
%  if (press(ii(ick))-min(press))>(DepthInt+DepthRef)
%      iip3=find(press<(press(ii(ick))-DepthInt)&press>(press(ii(ick))-(DepthInt+DepthRef)));  %default to looking up
%     else
%     iip3=find(press>(press(ii(ick))+DepthInt)&press<(press(ii(ick))+(DepthInt+DepthRef)));
%  end
 
     temprefmax=max(potemp(iipuse).*K(iipuse))
     temprefmin=min(potemp(iipuse).*K(iipuse))
     temprefdiff=max(potemp(iip3))-min(potemp(iip3));
     
      iip1=find(press<(press(jj(ick))+DepthInt)&press>(press(ii(ick))-DepthInt));
      length(iip1)
      offc=1;
      iio=[];
      for iipc=1:length(iip1)
     if (potemp(iip1(iipc))>(temprefmax+temprefdiff/2)||potemp(iip1(iipc))<(temprefmin-temprefdiff/2))&&isfinite(K(iip1(iipc)))
       
         iio(offc)=iip1(iipc);
         offc=offc+1;
     end
      end
      length(iio)
      
      if ~isempty(iio)
     figure
plot(potemp,press,'k.');axis ij; hold on
plot(potemp(isnan(K)),press(isnan(K)),'b.'); ylim([press(ii(ick))-5 press(ii(ick))+5])
plot(potemp(iio),press(iio),'r.');


rk=input('Remove red points? 1/0 \n');
if rk==1
    K(iio)=NaN;
end

close all
      end
      
     end
 end
 
 
end
%  
%  ii=find(Kcd<-TimeInt);
%  jj=find(Kcd>TimeInt); %these will (normally) be the same length
%  
%  if ~isempty(ii)
%      for ick=1:length(ii)
%      if (press(ii(ick))-max(press))>-DepthInt
%           break   %too close to the end
%      end 
%       
%  if (press(ii(ick))-max(press))<-(DepthInt+DepthRef)
%      iip3=find(press>(press(ii(ick))+DepthInt)&press<(press(ii(ick))+(DepthInt+DepthRef)));
%     else
%     iip3=find(press<(press(ii(ick))-DepthInt)&press<(press(ii(ick))-(DepthInt+DepthRef)));
%  end
%  
%      temprefmax=max(potemp(iip3));
%      temprefmin=min(potemp(iip3));
%      temprefdiff=max(potemp(iip3))-min(potemp(iip3));
%      
%       iip1=find(press>(press(jj(ick)))&press<(press(ii(ick))+DepthInt));  %limit checks to within a metre
%       offc=1;
%       iio=[];
%       for iipc=1:length(iip1)
%      if (potemp(iip1(iipc))>(temprefmax+temprefdiff)||potemp(iip1(iipc))<(temprefmin-temprefdiff))&&isfinite(K(iip1(iipc)))
%        
%          iio(offc)=iip1(iipc);
%          offc=offc+1;
%      end
%       end
%       
%      if ~isempty(iio)
%      figure
% plot(potemp,press,'k.');axis ij; hold on
% plot(potemp(isnan(K)),press(isnan(K)),'b.'); ylim([press(ii(ick))-5 press(ii(ick))+5])
% plot(potemp(iio),press(iio),'r.');
% 
% rk=input('Remove red points? 1/0 \n');
% if rk==1
%     K(iio)=NaN;
% end
% 
% close all
%      end
%      
%      end
% end
%  
%  potempkeep=potemp;  %if want to plot differences
%  salinkeep=salin;
%  sig0keep=sig0;
%  presskeep=press;


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


% figure
% plot(potempkeep,presskeep,'r.');axis ij; hold on
% plot(potemp,press,'k.')
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

% if nargout>0
%     break_loop=false;
% end
