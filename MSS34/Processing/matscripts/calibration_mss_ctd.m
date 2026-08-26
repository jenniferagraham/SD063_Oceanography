% info for mss calibration 

% mss station 2 (cast number 4-6)
% ctd cast 42
%% define variables 
clear all ; clc; close all 
profile=1; 
scatterplot=1;
diffProfile=0;
TSplot=1;
mac=1;
FZ=12;
%% define the paths


set(0, 'DefaultAxesFontSize', FZ);

% paths
if mac==0
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    MSSdataP = 'C:\Users\sa07lc\OneDrive - SAMS\Desktop\MSS\DATA_sd034\fasteps\upcast\';
    %CTDdataP = '';
        mssdataP = [disk,'MSS34\DATA\fasteps\'];
else
    disk = ['/Volumes/leg/work/scientific_work_areas/oceanography/'];
    MSSdataP = [disk,'MSS34/DATA/fasteps/'];
    CTDdataP = [disk,'CTD/BASproc/'];
    mssdataP = [disk,'MSS34/DATA/fasteps/'];
    figpath =[disk,'MSS34/Processing/Figures/'];
end    


%% to plot in a raw

nMSS = [4:6];
CTDfile = 42;

%%

% preallocate size of arrays for each variable
maxdepth = 300; % deepest cast (which will have greatest length)
temparray = zeros(maxdepth*2,length(nMSS))*NaN; % NaN array with no. columns equal to number of casts
% half step interval between values, so multiplied by two

myPress = temparray;
myT = temparray;
myS = temparray;
%%

for ii=1:length(nMSS) % select range of casts for this section

    cast = ii;

    mssname= ['SD63000',num2str(nMSS(cast)),'_eps.mat'];
    load ([mssdataP,mssname]);

    % populate NaN arrays with data from this cast
    % specify rows to write to according to length of data
    myPress(1:length(data.press),ii) = [data.press];
    myT(1:length(data.press),ii)     = [data.temp];
    myS(1:length(data.press),ii)     = [data.sal];

end

%% Remove NaNs in variable arrays

% concatenate vertically (add columns)
cast1 = [myPress(:,1) myT(:,1) myS(:,1)]; 
cast2 = [myPress(:,2) myT(:,2) myS(:,2)];
cast3 = [myPress(:,3) myT(:,3) myS(:,3)];

% remove any rows which have NaNs
clean1 = cast1(~any(isnan(cast1), 2), :);
clean2 = cast2(~any(isnan(cast2), 2), :);
clean3 = cast3(~any(isnan(cast3), 2), :);

%%

% averaging over all casts for this station
for r = 1:(maxdepth*2) % iterate over all rows in variable arrays
    pressMean(r,:) = nanmean(myPress(r,:));
    tMean(r,:) = nanmean(myT(r,:));
    sMean(r,:) = nanmean(myS(r,:));
end
%%
figsize=[440 363 369 335];
%% Retrieve CTD
load(fullfile(CTDdataP,sprintf('SD063_ctd_%03d_struct.mat',CTDfile)));

ctdPress = ctd.press;
ctdT = ctd.temp;
ctdS = ctd.salin;
%% profile plots

if profile==1
    f=figure;
%hold on
% Temp plot
% Does this need to be converted to theta?
subplot(1,2,1); hold on
plot(ctdT,ctdPress,'--k','linewidth',2)
plot(tMean,pressMean,'--r','linewidth',2)

hold on
% plot casts
plot(clean1(:,2),clean1(:,1),'-m','LineWidth',1.5) % col 2 is T, col 1 is Press
plot(clean2(:,2),clean2(:,1),'-g','LineWidth',1.5)
plot(clean3(:,2),clean3(:,1),'-b','LineWidth',1.5)

xlabel('Temperature (°C)')
ylabel('Pressure (dbar)')
ax = gca; ax.XAxisLocation = 'top'; 
ax.YMinorTick = 'on';
ax.YDir = 'reverse'; % Invert the y-axis
box on
% Invert the Y-axis
set(gca, 'YDir', 'reverse');
%legend({"CTD042","MSS004-006 mean","MSS004","MSS005","MSS006"})

% Salinity plot
subplot(1,2,2); hold on
plot(ctdS,ctdPress,'--k','LineWidth',2)
plot(sMean,pressMean,'--r','LineWidth',2)
% plot casts
plot(clean1(:,3),clean1(:,1),'-m') % col 3 is S, col 1 is Press
plot(clean2(:,3),clean2(:,1),'-g')
plot(clean3(:,3),clean3(:,1),'-b')

xlabel('Salinity (psu)')
ylabel('Pressure (dbar)')
ax = gca; ax.XAxisLocation = 'top';
ax.YMinorTick = 'on';
ax.YDir = 'reverse'; % Invert the y-axis
box on
% Invert the Y-axis
set(gca, 'YDir', 'reverse');
% Legend
legend({"CTD042","MSS004-006 mean","MSS004","MSS005","MSS006"},'Location','Best')

sgtitle('MSS-CTD cross-calibration - mean cast'); 
set(f,'Position',figsize)
exportgraphics(gcf,[figpath,'MSS-CTD-cross-calibration_allcasts.png'],'Resolution',300)

end
%% Downsample the MSS data to match resolution of CTD
% Interpolation to CTD pressure grid

pressRef = ctdPress;
% Concatenating sampled pressure, interpolated T + interpolated S
mssInterp1 = [pressRef,...
              interp1(clean1(:,1),clean1(:,2),pressRef,'nearest'),... % Interpolate temp
              interp1(clean1(:,1),clean1(:,3),pressRef,'nearest')]; % Interpolate pressure
mssInterp2 = [pressRef,...
              interp1(clean2(:,1),clean2(:,2),pressRef,'nearest'),...
              interp1(clean2(:,1),clean2(:,3),pressRef,'nearest')];
mssInterp3 = [pressRef,...
              interp1(clean3(:,1),clean3(:,2),pressRef,'nearest'),...
              interp1(clean3(:,1),clean3(:,3),pressRef,'nearest')];
% alternatively bin to match low depth resolution of the CTD 
% better choice is to bin to match density 
for ii=2:length(pressRef)
    nn1 = find(clean1(:,1)<=pressRef(ii));
    nn2 = find(clean1(:,1)<=pressRef(ii));
    nn3 = find(clean1(:,1)<=pressRef(ii));
    
end
%% Difference plot (using down-sampled MSS data)

Tdiff1 = ctdT-mssInterp1(:,2);
Tdiff2 = ctdT-mssInterp2(:,2);
Tdiff3 = ctdT-mssInterp3(:,2);

Sdiff1 = ctdS-mssInterp1(:,3);
Sdiff2 = ctdS-mssInterp2(:,3);
Sdiff3 = ctdS-mssInterp3(:,3);
% get the mean bias and RMSE from the deep section. This is the part of the
% profile with well mixed water and hence the best for the calibration 
meandiffS = nanmean([Sdiff2,Sdiff3,Sdiff1],2);
deepindx = find(ctdPress>=170);
bias = nanmean(meandiffS(deepindx)); % the mean of the bottom 150m of the profile (see below the plot to look at dZdz)
mssInterall = nanmean([mssInterp1(:,3), mssInterp2(:,3),mssInterp3(:,3)],2);
RMSE = sqrt(nanmean((ctdS-mssInterall).^2));

% mean difference below 

%% profile diff plots
if diffProfile==1
f=figure;

%hold on
% Temp plot
% Does this need to be converted to theta?
subplot(1,2,1); hold on
plot(Tdiff1,ctdPress,color="r",LineWidth=1.5) % col 2 is T, col 1 is Press
plot(Tdiff2,ctdPress,color="g",LineWidth=1.5)
plot(Tdiff3,ctdPress,color="b",LineWidth=1.5)
xlabel('Temperature difference (°C)')
ylabel('Pressure (dbar)')
% Vertical dashed line at zero diff
xline(0,color="k",LineStyle="--")
ax = gca; ax.XAxisLocation = 'top'; 
ax.YMinorTick = 'on';
ylim([20 inf])
ax.YDir = 'reverse'; % Invert the y-axis
box on
% Invert the Y-axis
set(gca, 'YDir', 'reverse');
% Legend
legend({"MSS004","MSS005","MSS006"})

% Salinity plot
subplot(1,2,2); hold on
plot(Sdiff1,ctdPress,'-r','LineWidth',1.5) % col 3 is S, col 1 is Press
plot(Sdiff2,ctdPress,'-g','LineWidth',1.5)
plot(Sdiff3,ctdPress,'-b','LineWidth',1.5)
xlabel('Salinity difference (psu)')
ylabel('Pressure (dbar)')
% Vertical dashed line at zero diff
xline(0,color="k",LineStyle="--")
ax = gca; ax.XAxisLocation = 'top';
ax.YMinorTick = 'on';
ylim([20 inf])
ax.YDir = 'reverse'; % Invert the y-axis
box on
% Invert the Y-axis
set(gca, 'YDir', 'reverse');
% Legend
legend({"MSS004","MSS005","MSS006"})
set(f,"Position",figsize)
sgtitle('MSS-CTD cross-calibration - difference plot'); 
exportgraphics(gcf,[figpath,'MSS-CTD-cross-calibration_difference.png'],'Resolution',300)

end
%% TS plot 
if TSplot==1
f=figure;
plot(ctdS,ctdT,'-k','LineWidth',2)
hold on 
% mss raw data 
plot(clean1(:,3),clean1(:,2),'-g','LineWidth',1.5)
plot(clean2(:,3),clean2(:,2),'-g','LineWidth',1.5)
plot(clean3(:,3),clean3(:,2),'-g','LineWidth',1.5)

% mss Add corrected values 
hold on 
% corrected mss (using the offsetor bias) 
plot(clean1(:,3)+bias,clean1(:,2),'-b','LineWidth',1.5)
plot(clean2(:,3)+bias,clean2(:,2),'-b','LineWidth',1.5)
plot(clean3(:,3)+bias,clean3(:,2),'-b','LineWidth',1.5)

legend('CTD42','MSS004','MSS005', 'MSS006','corrMSS004','corrMSS005', 'corrMSS006','Location','best')
set(f,"Position",figsize)
xlim([32.3 35]) % zoom into the region 
ylim([-1.5 1 ])% zoom into the region 
ylabel('Temperature ^\circC')
xlabel('Salinity')
exportgraphics(gcf,[figpath,'MSS-CTD-cross-calibration_TSplot.png'],'Resolution',300)

end
%% Scatter plot 
if scatterplot==1
f=figure;
% Temp scatter plot
subplot(1,2,1); hold on

scatter(ctdT,mssInterp1(:,2),"r","filled")
scatter(ctdT,mssInterp2(:,2),"g","filled")
scatter(ctdT,mssInterp3(:,2),"b","filled")

xlabel('CTD temp (deg C)')
ylabel('MSS temp (deg C)')

% 1:1 line (gradient = 1, y-intercept = 0)
plot(ctdT,ctdT,color="k")

% Legend
legend({"MSS004","MSS005","MSS006"})

%%%%%%%%%%%%%%%%%%%%%%%
% Salinity scatter plot

subplot(1,2,2); hold on

scatter(ctdS,mssInterp1(:,3),"r","filled")
scatter(ctdS,mssInterp2(:,3),"g","filled")
scatter(ctdS,mssInterp3(:,3),"b","filled")

xlabel('CTD salinity (psu)')
ylabel('MSS salinity (psu)')

% 1:1 line
plot(ctdS,ctdS,color="k")
% Legend
legend({"MSS004","MSS005","MSS006"})

sgtitle('MSS-CTD cross-calibration - correlation plot');

end
%% calibration thoughts
% if slope is close to 1 an offset is sufficient, but if slope is greater
% than one a regression is better for correction 
% dropping the profile 3 because it seems to be off by a lot relative to the second and third profiles.
mssS = nanmean([mssInterp2(:,3),mssInterp3(:,3)],2);

% Because the MSS casts and CTD where not done at the same time, it may be
% best to focus on parts of the profile that are well mixed. Areas with
% strong gradient may have be more likely to change over short timescales. 
dSdz = diff(ctdS);
meandSdz = nanmean(dSdz);
stdSdz = nanstd(dSdz);
dTdz = diff(ctdT);
meandTdz = nanmean(dTdz);
stdTdz = nanstd(dTdz);

displ(['Correction of MSS salinity add ',num2str(bias)])
