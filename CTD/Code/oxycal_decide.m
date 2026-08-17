clear
close all


%assume offsets are much larger than for T and C, so don't chase gradient
%effects or calibration order (but if anyone feels keen...)

%might need to run through more than once if change in sensor/sensor
%behaviour (especially if things get cold)


CTDvarn
load (fullfile(dir_out,'oxygen','oxycals.end.mat'))
oxyoff1(:,1)=NaN; oxyoff2(:,1)=NaN; 

%if need to split. Want same variable names
% indsplit=17;
% stn=stn(1:indsplit); oxyoff1=oxyoff1(:,1:indsplit); oxyoff2=oxyoff2(:,1:indsplit); 
% botpress=botpress(:,1:indsplit); ctdO1_kg=ctdO1_kg(:,1:indsplit); ctdO2_kg=ctdO2_kg(:,1:indsplit);
% ctdt1=ctdt1(:,1:indsplit); ctdt2=ctdt2(:,1:indsplit);
% otfile=fullfile(dir_out,'oxygen','oxycals.start.mat');
% save(otfile,'stn','oxyoff1','oxyoff2','botpress','ctdO1_kg','ctdO2_kg','ctdt1','ctdt2')
% load (fullfile(dir_out,'oxygen','oxycals.all.mat'))  %reset variables
% stn=stn((indsplit+1):end); oxyoff1=oxyoff1(:,(indsplit+1):end); oxyoff2=oxyoff2(:,(indsplit+1):end);
% botpress=botpress(:,(indsplit+1):end);ctdO1_kg=ctdO1_kg(:,(indsplit+1):end); ctdO2_kg=ctdO2_kg(:,(indsplit+1):end);
% ctdt1=ctdt1(:,(indsplit+1):end); ctdt2=ctdt2(:,(indsplit+1):end);
% otfile=fullfile(dir_out,'oxygen','oxycals.end.mat');
% save(otfile,'stn','oxyoff1','oxyoff2','botpress','ctdO1_kg','ctdO2_kg','ctdt1','ctdt2')

figure  %might be pressure dependence, especially if going very deep
plot(botpress,oxyoff1,'k.');hold on
title('Oxygen 1 offset against pressure')
figure
plot(botpress,oxyoff2,'g.')
title('Oxygen 2 offset against pressure')

offest=10; %to approximately centre filtering
stnsplit=30;
oxyint=160:20:360;
for oc=1:(length(oxyint)-1)
    ii=ctdO1_kg>=oxyint(oc)&ctdO1_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff1-offest)<15);
    oxy1plot(oc)=mean(ctdO1_kg(ii),'omitmissing');
    oxyoff1plot(oc)=mean(oxyoff1(ii),'omitmissing');
    % ii=ctdO1_kg>=oxyint(oc)&ctdO1_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff1-offest)<15)&stn<=stnsplit;
    %    oxy1plotStn1(oc)=mean(ctdO1_kg(ii),'omitmissing');
    % oxyoff1plotStn1(oc)=mean(oxyoff1(ii),'omitmissing');
    %     ii=ctdO1_kg>=oxyint(oc)&ctdO1_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff1-offest)<15)&stn>stnsplit;
    %    oxy1plotStn2(oc)=mean(ctdO1_kg(ii),'omitmissing');
    % oxyoff1plotStn2(oc)=mean(oxyoff1(ii),'omitmissing');
end

figure %oxygen offset normally a scaling factor of oxygen
plot(ctdO1_kg,oxyoff1,'k.');hold on
plot(oxy1plot,oxyoff1plot,'r.','MarkerSize',15)
% plot(oxy1plotStn1,oxyoff1plotStn1,'c.','MarkerSize',15)
% plot(oxy1plotStn2,oxyoff1plotStn2,'m.','MarkerSize',15)
title('Oxygen 1 offset against oxygen 1')
% % % % %stations 7:30, Oxy 1
% % % % x1=[160 360];   
% % % % y1=[4 12];
% % % % plot(x1,y1,'r')

x1=[160 360];   
y1=[5.5 17];
plot(x1,y1,'r')

ocalib1int=interp1(x1,y1,ctdO1_kg);
oresid1=oxyoff1-ocalib1int;

offest=5;
stnsplit=30;
oxyint=160:20:360;
for oc=1:(length(oxyint)-1)
    ii=ctdO2_kg>=oxyint(oc)&ctdO2_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff2-offest)<15);
    oxy2plot(oc)=mean(ctdO2_kg(ii),'omitmissing');
    oxyoff2plot(oc)=mean(oxyoff2(ii),'omitmissing');
    %    ii=ctdO2_kg>=oxyint(oc)&ctdO2_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff2-offest)<15)&stn<=stnsplit;
    %    oxy2plotStn1(oc)=mean(ctdO2_kg(ii),'omitmissing');
    % oxyoff2plotStn1(oc)=mean(oxyoff2(ii),'omitmissing');
    %     ii=ctdO2_kg>=oxyint(oc)&ctdO2_kg<oxyint(oc+1)&botpress<4900&(abs(oxyoff2-offest)<15)&stn>stnsplit;
    %    oxy2plotStn2(oc)=mean(ctdO2_kg(ii),'omitmissing');
    % oxyoff2plotStn2(oc)=mean(oxyoff2(ii),'omitmissing');
end

figure
plot(ctdO2_kg,oxyoff2,'g.'); hold on
 plot(oxy2plot,oxyoff2plot,'b.','MarkerSize',15)
% plot(oxy2plotStn1,oxyoff2plotStn1,'r.','MarkerSize',15)
% plot(oxy2plotStn2,oxyoff2plotStn2,'k.','MarkerSize',15)
title('Oxygen 2 offset against oxygen 2')


% % % % %stations 7:30, Oxy2
% % % % x2=[160 360];
% % % % y2=[2 4.5];

x2=[160 360];
y2=[2.5 10];
plot(x2,y2,'b')
ocalib2int=interp1(x2,y2,ctdO1_kg);
oresid2=oxyoff2-ocalib2int;

figure  %might be pressure dependence, especially if going very deep
plot(botpress,oresid1,'k.');hold on
plot(botpress,oresid2,'g.')


pind=1;
for pcut=[0 15 125 250:500:6250]
    jj=find(botpress>(pcut-500)&botpress<pcut);
    if isfinite(jj)
        
        oresidav1(pind)=mean(oresid1(jj),'omitmissing');
        botptda1(pind)=mean(botpress(jj),'omitmissing');
      %  cdiffav1filt(pind)=median(condoff1filt(jj),'omitmissing');
      %  botptda1f(pind)=median(botp1f(jj),'omitmissing');
        
        oresidav2(pind)=mean(oresid2(jj),'omitmissing');
        botptda2(pind)=mean(botpress(jj),'omitmissing');
       % cdiffav2filt(pind)=median(condoff2filt(jj),'omitmissing'); 
      %  botptda2f(pind)=median(botp2f(jj),'omitmissing');
        
        pind=pind+1;
    end
end
plot(botptda1,oresidav1,'r.','MarkerSize',15)
 plot(botptda2,oresidav2,'b.','MarkerSize',15)
% % % % %stations 7:30
% % % % xp1=[0 3500 4500 6200];   
% % % % yp1=[0.3 -1.8 -2.5 -13];
% % % % %y1=[-0.00025 -0.0005];
% % % % plot(xp1,yp1,'m')
% % % % 
% % % % xp2=[0 3500 4500 6200];
% % % % yp2=[-0.5 0.4 -0.5 -9.5];
% % % % plot(xp2,yp2,'g')

xp1=[0 3500 4500 6200];   
yp1=[0.3 -1.8 -4 -13];
%y1=[-0.00025 -0.0005];
plot(xp1,yp1,'m')

xp2=[0 3500 4500 6200];
yp2=[0.3 1 -0.6 -9.5];
plot(xp2,yp2,'g')

% pressure=0:6200; %to test plotting, need to apply equation directly for 24hz files
% ccalib1=NaN*pressure;
% for ip=1:(length(x1)-1)
%     ii=pressure>x1(ip)&pressure<=x1(ip+1);
%     ccalib1(ii)=y1(ip)+((y1(ip+1)-y1(ip))/x1(ip+1))*pressure(ii); 
% end 
ocalib1intp=interp1(xp1,yp1,botpress);
plot(botpress,ocalib1intp,'k--')   %check this matches the simple plotting

% ccalib2=NaN*pressure;
% for ip=1:(length(x2)-1)
%     ii=pressure>x2(ip)&pressure<=x2(ip+1);
%     ccalib2(ii)=y2(ip)+((y2(ip+1)-y2(ip))/x2(ip+1))*pressure(ii); 
% end
ocalib2intp=interp1(xp2,yp2,botpress);
plot(botpress,ocalib2intp,'k--')

ocalibdiffp=ocalib1intp-ocalib2intp;

ssco=size(ocalib1intp);
stno=repmat(stn,[ssco(1) 1]);

figure
plot(stno,ocalib1intp-oresid1,'k.'); hold on
% ii=botpress>700;
% plot(stno(ii),ccalib1int(ii)-condoff1(ii),'r.'); 
plot([0 max(stn)],[0 0],'m')
xlabel('CTD station')
ylabel('Residual from calibration fit, 1')

figure
plot(stno,ocalib2intp-oresid2,'k.'); hold on
% ii=botpress>700;
% plot(stno(ii),ccalib2int(ii)-condoff2(ii),'g.'); 
plot([0 max(stn)],[0 0],'m')
xlabel('CTD station')
ylabel('Residual from calibration fit, 2')

oxycalib1full=interp1(x1,y1,ctdO1_kg)+interp1(xp1,yp1,botpress);
oxycalib2full=interp1(x2,y2,ctdO1_kg)+interp1(xp2,yp2,botpress);

figure  %might be pressure dependence, especially if going very deep
plot(botpress,oxyoff1,'k.');hold on
plot(botpress,oxyoff2,'g.')

plot(botpress,oxycalib1full,'r.')
plot(botpress,oxycalib2full,'b.')

figure

plot(botpress,oxyoff1-oxycalib1full,'r.'); hold on
plot([0 max(max(botpress))],[0 0],'k')
title('final offset 1 against pressure')
figure
plot(botpress,oxyoff2-oxycalib2full,'b.'); hold on
plot([0 max(max(botpress))],[0 0],'k')
title('final offset 2 against pressure')

figure
plot(ctdt1,oxyoff1-oxycalib1full,'r.'); hold on
plot([min(min(ctdt1)) max(max(ctdt1))],[0 0],'k')
title('final offset 1 against temperature')
figure
plot(ctdt2,oxyoff2-oxycalib2full,'b.'); hold on
plot([min(min(ctdt2)) max(max(ctdt2))],[0 0],'k')
title('final offset 2 against temperature')