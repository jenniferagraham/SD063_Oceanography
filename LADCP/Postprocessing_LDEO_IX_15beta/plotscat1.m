function d = plotscat1(f,d,p,mm,stn)
figure(9)
clf;
hold on
bot = min(find(d.z <= -p.maxdepth));
plot(mm(1,1:bot),d.z(1:bot)-((1*d.down.Cell_length/100)+d.down.Blank/100),'r')
plot(mm(2,1:bot),d.z(1:bot)-((2*d.down.Cell_length/100)+d.down.Blank/100),'y')
plot(mm(3,1:bot),d.z(1:bot)-((3*d.down.Cell_length/100)+d.down.Blank/100),'k')
plot(mm(4,1:bot),d.z(1:bot)-((4*d.down.Cell_length/100)+d.down.Blank/100),'b')
ylabel('depth (m)');
xlabel('MVBS (dB) bin 1 (red), 2 (yellow), 3 (black), 4 (blue)');
streamer(['SD046 cast # ',num2str(stn), ' Figure 9: MVBS profile']);
% streamer(['Fig.10:  Station : ',p.freq,p.name, ' MVBS profile']);
% tmp = sprintf('%sMVBS.ps',f.res);
%eval(['print -dpsc2 -f10 ' tmp]);
eval(['print -dpsc ',f.res,'fig9'])
