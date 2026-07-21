clear

%start here for calibration
%
%Order:
%
%find temperature offset (here)
%Apply temperature calibration, if needed, to bottle files (dead-end .tcl files)
%in tempcalbottGEN
%Back-calculate conductivity from sample salinity and calibrated CTD temperature
%in salcalGEN_tcal
%go through conductivity calibration (salcal_decide)
%Apply all calibrations in salcalappGEN
%Recalculate salinity and density

CTDvarn

close all
load (fullfile(dir_out,'SBE35','tempcals.all.mat'));

figure
plot(botp,sb35temp-ctdt1,'b.'); hold on
title ('SBE35-CTD T1')  %first look at everything
xlabel('Pressure')
figure
plot(botp,(sb35temp-ctdt1)-0.75*ctdgradt1,'r.');%'r^','MarkerFaceColor','r')
title ('SBE35-CTD T1, gradient adjusted')
xlabel('Pressure')

figure
plot(botp,sb35temp-ctdt2,'g.'); hold on
title ('SBE35-CTD T2')
xlabel('Pressure')
figure
plot(botp,(sb35temp-ctdt2)-0.75*ctdgradt2,'k.');%'k^','MarkerFaceColor','k')
title ('SBE35-CTD T2, gradient adjusted')
xlabel('Pressure')

figure
plot(botp,ctdt1-ctdt2,'k.'); hold on
plot([0 6000],[0 0],'r')
title ('CTD T1-T2')  %any calibrations should sum to make this flat on 0
        %more data in full deep CTD casts. Check first, last and deepest

T1T2difflim=0.002;


jj=stdt1>0.0025;    %removing data when high variability around bottle firing

kk=(ctdt1-ctdt2)>T1T2difflim;  %useful, but criterion will need checking 
offest=-0.001;
ll=abs(sb35temp-ctdt1-offest)>0.05;

ii=jj|kk|ll;
ctdt1filt=ctdt1;
ctdgradt1filt=ctdgradt1;
botp1f=botp;
ctdt1filt(ii)=NaN;
ctdgradt1filt(ii)=NaN;
botp1f(ii)=NaN;


jj=stdt2>0.0025;
kk=(ctdt1-ctdt2)>T1T2difflim;  %useful, but criterion will need checking 
offest=-0.001;
ll=abs(sb35temp-ctdt2-offest)>0.05;

ii=jj|kk|ll;
ctdt2filt=ctdt2;
ctdgradt2filt=ctdgradt2;
botp2f=botp;
ctdt2filt(ii)=NaN;
ctdgradt2filt(ii)=NaN;
botp2f(ii)=NaN;

figure
plot(botp,(sb35temp-ctdt2filt)-0.75*ctdgradt2filt,'k.');%'k^','MarkerFaceColor','k')
title ('SBE35-CTD T2, gradient adjusted, filtered')

pind=1;
for pcut=[25 125 250:500:6250]
    jj=find(botp>(pcut-500)&botp<pcut);  %not pretty...
    if isfinite(jj)
        
        tdiffav1(pind)=nanmean(sb35temp(jj)-ctdt1(jj));
        botptda1(pind)=nanmean(botp(jj));
        tdiffav1filt(pind)=nanmean(sb35temp(jj)-ctdt1filt(jj));
        tgradav1filt(pind)=nanmean(ctdgradt1filt(jj));
        botptda1f(pind)=nanmean(botp1f(jj));
        
        tdiffav2(pind)=nanmean(sb35temp(jj)-ctdt2(jj));
        botptda2(pind)=nanmean(botp(jj));
        tdiffav2filt(pind)=nanmean(sb35temp(jj)-ctdt2filt(jj)); 
        tgradav2filt(pind)=nanmean(ctdgradt2filt(jj));
        botptda2f(pind)=nanmean(botp2f(jj));
        
        pind=pind+1;
    end
end

figure
plot(botp,sb35temp-ctdt1,'c.')
hold on
plot(botp1f,sb35temp-ctdt1filt,'b.')
plot(botptda1,tdiffav1,'r.')
plot(botptda1f,tdiffav1filt,'r.','MarkerSize',25)
plot(botptda1f,tdiffav1filt-0.75*tgradav1filt,'r^','MarkerFaceColor','r')

plot(botp,sb35temp-ctdt2,'y.')
plot(botp2f,sb35temp-ctdt2filt,'g.')
plot(botptda2,tdiffav2,'k.')
plot(botptda2f,tdiffav2filt,'k.','MarkerSize',25)
plot(botptda2f,tdiffav2filt-0.75*tgradav2filt,'k^','MarkerFaceColor','k')

xlabel('Pressure (dbar)');
ylabel('SBE35 - CTD (^oC)');
title('c/b/r = primary; y/g/k = secondary;');


figure
plot(botptda1f,tdiffav1filt,'r.','MarkerSize',25)
hold on
plot(botptda2f,tdiffav2filt,'k.','MarkerSize',25)
title('Average offsets after filtering, no gradient correction')

figure
plot(botptda1f,tdiffav1filt-0.75*tgradav1filt,'r^','MarkerFaceColor','r')
hold on
plot(botptda2f,tdiffav2filt-0.75*tgradav2filt,'k^','MarkerFaceColor','k')
title('Average offsets (r=1,k=2), gradient correction applied')
xlabel('Pressure')

x1=[0 2000 6200];  
y1=[0.00055 -0.00065 -0.00065];
%y1=[-0.00025 -0.0005];
plot(x1,y1,'m')

x2=[0 2000 6200];
y2=[-0.00025 -0.00125 -0.00125];
plot(x2,y2,'g')

pressure=0:6200; %to test plotting, need to apply equation directly for 24hz files
% tcalib1=NaN*pressure;
% for ip=1:(length(x1)-1)
%     ii=pressure>x1(ip)&pressure<=x1(ip+1);
%     tcalib1(ii)=y1(ip)+((y1(ip+1)-y1(ip))/x1(ip+1))*pressure(ii); 
% end 
% plot(pressure,tcalib1,'k--')   %check this matches the simple plotting
tcalib1=interp1(x1,y1,botp);

plot(botp,tcalib1,'r.')
% tempoffset1fcn = @(press,temp,oxygen,stano,gtime) 0.0*temp + interp1([0 3000 6200],[-0.0001 -0.0006 -0.0006],press);  
%generic fit function for salcalapp: offset (potentially) a function of the
%variable itself and pressure (broken-stick fit) 

tcalib2=NaN*pressure;
% for ip=1:(length(x2)-1)
%     ii=pressure>x2(ip)&pressure<=x2(ip+1);
%     tcalib2(ii)=y2(ip)+((y2(ip+1)-y2(ip))/x2(ip+1))*pressure(ii); 
% end
tcalib2=interp1(x2,y2,botp);
plot(botp,tcalib2,'k.')

tcalibdiff=tcalib1-tcalib2;

figure
plot(stn,tcalib1-(sb35temp-ctdt1),'k.'); hold on
plot([0 max(stn)],[0 0],'m')
xlabel('CTD station')
ylabel('Residual from calibration fit')

figure
plot(stn,tcalib2-(sb35temp-ctdt2),'k.'); hold on
plot([0 max(stn)],[0 0],'m')
xlabel('CTD station')
ylabel('Residual from calibration fit')

figure
plot(botptda1f,(tdiffav1filt-0.75*tgradav1filt)-(tdiffav2filt-0.75*tgradav2filt),'r^','MarkerFaceColor','r'); hold on
plot(botp,tcalibdiff,'r--')
xlabel('Pressure')
title('T1-T2 Average offsets, gradient correction applied')
