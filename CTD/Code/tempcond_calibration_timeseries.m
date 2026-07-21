CTDvarn

close all
%temp offset 
load (fullfile(dir_out,'SBE35','tempcals.all.mat'));
ctdt1_edit=ctdt1+0.00054004;
ctdt2_edit=ctdt2-0.0011;

figure(20)
hold on
scatter(stn,nanmean(sb35temp-ctdt1_edit))
scatter(stn,nanmean(sb35temp-ctdt1),'r')

figure(21)
hold on
scatter(stn,nanmean(sb35temp-ctdt2_edit))
scatter(stn,nanmean(sb35temp-ctdt2),'r')


load (fullfile(dir_out,'salts','salcals12.all.mat'))

ctdt1_edit=ctdt1+0.00054004;
ctdt2_edit=ctdt2-0.0011;

%use new temps for sal cal

botc_edit=sw_c3515*sw_cndr(bots,ctdt1_edit,botpress);


sal1_edit=sw_salt(ctdc1/sw_c3515,ctdt1_edit, botpress);
sal2_edit=sw_salt(ctdc2/sw_c3515,ctdt2_edit, botpress);

ii=stdt1>0.0025|abs(condoff1)>0.015;
ctdc1(ii)=NaN;
sal1_edit(ii)=NaN;
ii=stdt2>0.0025|abs(condoff2)>0.015;
ctdc2(ii)=NaN;
sal2_edit(ii)=NaN;

figure(1) 
title('sal1 - bots')
plot(stn,sal1_edit-bots,'.');
hold on;
scatter(stn,nanmean(sal1_edit-bots))

figure(2)
title('sal2 - bots')
plot(stn,sal2_edit-bots,'.');
hold on;
scatter(stn,nanmean(sal2_edit-bots))

figure(3) 
title('c1 - botC')
plot(stn,ctdc1-botc_edit,'.');
hold on;
scatter(stn,nanmean(ctdc1-botc_edit))
figure(4)
title('c2-botc')
plot(stn,ctdc2-botc_edit,'.');
hold on;
scatter(stn,nanmean(ctdc2-botc_edit))


%piecewise offset 
ctdc2_edit= zeros(size(ctdc2));

for n=1:56
if 1<=n && n<=18
    ctdc1_edit(:,n)=ctdc1(:,n)+0.0013;
else 
    ctdc1_edit(:,n)=ctdc1(:,n)+0.000043954;
end
if 1<=n && n<=15
    n
i%ctdc2_edit(:,n)=ctdc2(:,n)+0.0029;
ctdc2_edit(:,n)=ctdc2(:,n)+0.0011;

elseif 16<=n && n<=25
%ctdc2_edit(:,n)=(0.0027-(n-18)*0.00042366)+ctdc2(:,n); %18
%ctdc2_edit(:,n)=(0.0029-(n-15)*0.00032630)+ctdc2(:,n); %18
ctdc2_edit(:,n)=(0.0011-(n-15)*0.00017629)+ctdc2(:,n); %18
else
 %ctdc2_edit(:,n)=ctdc2(:,n)-0.00068930 ;
ctdc2_edit(:,n)=ctdc2(:,n)-0.00066288 ;
end

end
ctdc2_edit=ctdc2_edit+ctdc1_edit-ctdc1;
figure(10)
title('ctdc2-bot_edit')
plot(stn,ctdc2-botc_edit,'.');
hold on;
scatter(stn,nanmean(ctdc2-botc_edit))
% figure(11)
scatter(stn,nanmean(ctdc2-ctdc2_edit))

figure(11);
title('ctdc2_edit-botc_edit')
plot(stn,ctdc2_edit-botc_edit,'.');
hold on;
scatter(stn,nanmean(ctdc2_edit-botc_edit))


% ctdc1_edit=ctdc1+0.00057338;

figure(12)
title('ctdc1_edit-botc_edit')
plot(stn,ctdc1_edit-botc_edit,'.');
hold on;
scatter(stn,nanmean(ctdc1_edit-botc_edit))

figure(13)
title('offset between sonsors before and after edits')
hold on
scatter(stn, nanmean(ctdc1_edit-ctdc2_edit),'r')
scatter(stn, nanmean(ctdc1-ctdc2),'b')

figure;
ax1=subplot(2,1,1);
hold on;
ax2=subplot(2,1,2);
hold on;
for n=1:61
ctd=load(fullfile(dir_out,sprintf('JR18004_ctd_%.3d.2db.mat',n)),...
    'temp1','temp2','press','cond1','cond2');
axes(ax1);
errorbar(n,nanmean(ctd.cond1-ctd.cond2),nanstd(ctd.cond1-ctd.cond2),'k+');
ctd.temp1_edit=ctd.temp1+0.00054004;
ctd.temp2_edit=ctd.temp2-0.0011;
if 1<=n && n<=18
    ctd.cond1_edit=ctd.cond1+0.0013;
else 
    ctd.cond1_edit=ctd.cond1+0.000043954;
end

if 1<=n && n<=15
ctd.cond2_edit=ctd.cond2+0.0011;
elseif 16<=n && n<=25
    ctd.cond2_edit=(0.0011-(n-15)*0.00017629)+ctd.cond2; %18
else
    ctd.cond2_edit=ctd.cond2-0.00066288 ;
end
ctd.cond2_edit=ctd.cond2_edit+ctd.cond1_edit-ctd.cond1;

ctd.sal1_edit=sw_salt(ctd.cond1_edit./sw_c3515,ctd.temp1_edit,ctd.press);
ctd.sal2_edit=sw_salt(ctd.cond2_edit./sw_c3515,ctd.temp2_edit,ctd.press);
axes(ax2);
errorbar(n,nanmean(ctd.cond1_edit-ctd.cond2_edit),nanstd(ctd.cond1_edit-ctd.cond2_edit),'k+');
end
