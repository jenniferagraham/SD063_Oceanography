function [d,p] = svcalc4(d,p) % edited by Shenjie on SD046
%function [d,p] = svcalc4(d,p)
%calibrate backscatter parameters
%% for now, test  ADCP parameters...
num = max(size(d.temp));
d.mvbs1 = zeros(p.nbins,num); % Dienes 1999
d.mvbs2 = zeros(p.nbins,num); % Mullison 2017

disp('Using following frequency dependant constants from Deines (1995) Paper..');
p.svconst =[75,-163.3,23.8,3.15,0.027,150,-153.3,24.0,1.88,0.044,300,-148.2,15.4,2.64,0.069,600,-141.4,15.4,2.90,0.153,1200,-129.5,12.6,1.67,0.48];
p.svconst = reshape(p.svconst,5,5)';


if (d.down.Frequency == 75) fi = 1; end
if (d.down.Frequency == 150) fi = 2; end
if (d.down.Frequency == 300) fi = 3; end
if (d.down.Frequency == 600) fi = 4; end
if (d.down.Frequency == 1200) fi = 5; end

disp(p.svconst(fi,1:5))

d.rssi = d.ts_edited/0.45;% d.ts is the raw target strength
p.kc = 0.45;
% p.er = 79.5;
p.er = 40; % Shenjie/Ryan 27-Feb-2025, tune down the noise reference level
%% set the relevant alpha (same value with depth for now)
msg = sprintf('Using %5.3f for alpha\n',p.svconst(fi,5));
disp(msg);
p.alpha = ones(num,1) * p.svconst(fi,5);

p.range = zeros(length(d.zd),1);
rangesq = zeros(length(d.zd),1);
%% set up range matrix...using formula from Deines 1995 paper
%size(d.mvbs)
for i = 1:length(d.zd)
  p.range(i) = ((d.down.Blank/100)+ ((d.down.Pulse_length + d.down.Cell_length)/200) +...
   (i-1)*d.down.Cell_length/100 + (d.down.Cell_length/400))/cos(d.down.Beam_angle*pi/180);
  p.range(i) = p.range(i) * 1475/1500;
  rangesq(i) = p.range(i) ^2;
%% %% range(i) = d.zd(i)/cos(d.down.Beam_angle*pi/180);
end  
    tmpaa = sprintf('dc = %d, bin = %d\n',num,length(d.zd));
    disp(tmpaa);

for dc=1:num

%%  Calculate Sv from the formula in RDI Application Note FSA-008...

 for bin = 1:length(d.zd)
    d.mvbs1(bin,dc) = p.svconst(fi,2) + ... % C
        (10*log10((d.temp(dc)+273.16))) + (20*log10(p.range(bin)))- ...% 10log((T+273.16)R^2
        (10*log10(d.down.Pulse_length/100)) - ... Ldbw
        (p.svconst(fi,3)) + ... Pdbw
        (2*(p.alpha(dc))*p.range(bin)) + ... 2alphaR
        p.kc*(d.rssi(d.izd(bin),dc)-p.er);%Kc*(E-Er)

    d.mvbs2(bin,dc) = p.svconst(fi,2) + ... % C
        (10*log10((d.temp(dc)+273.16))) + (20*log10(p.range(bin)))- ...% 10log((T+273.16)R^2
        (10*log10(d.down.Pulse_length/100)) - ... Ldbw
        (p.svconst(fi,3)) + ... Pdbw
        (2*(p.alpha(dc))*p.range(bin)) + ... 2alphaR
        10*log10(10^(p.kc*(d.rssi(d.izd(bin),dc)-p.er)/10)-1);%10*log10(10^(Kc*(E-Er)/10)-1)

 end

end

