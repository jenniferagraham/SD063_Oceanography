% Generate a model tidal time series for 3-miippugut fjord, and compare
% this to GNSS observations of ship height
% Written by Ellie Fisher 16.8.2026 (SD063 GIANT)

close all; clear all;

addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
disk = 'L:\work\scientific_work_areas\';
addpath 'L:\work\scientific_work_areas\oceanography\Gr1kmTM\data\'; % path to tide model on leg drive
addpath 'L:\work\scientific_work_areas\oceanography\TMD3.0' % path to tmd_predict function on leg drive
tideModel = [disk,'oceanography\Gr1kmTM\data\Gr1kmTM_v1.nc'];

gnss = readtable('L:\work\scientific_work_areas\gnss\sda_gnss\tide_analysis\receiver2_5min_nofilter_median.csv');
atmP = readtable('L:\work\scientific_work_areas\gnss\sda_gnss\tide_analysis\atmospheric_pressure.csv','HeaderLines',11,'Delimiter',',');

%% Index for fjord 
gnssFjord = gnss(gnss.datetime >= "28-Jul-2026 00:00:00",:); 
fjordTimes = gnssFjord.datetime;

%% Predict the entire tide time series for this location:
z = tmd_predict(tideModel,mean(gnssFjord.latitude),mean(gnssFjord.longitude),fjordTimes);

%% Index atmos. pressure data
atmP.time = datetime(regexprep(atmP.time(:), '\+[0-9]{2}:[0.9]{2}$','')); % Remove trailing UTC timezone +00:00 and convert to datetime
fjordPress = atmP(atmP.time >= "28-Jul-2026 00:00:00",:);
fjordPress = fjordPress(1:height(gnssFjord),:); % trimming pressure data to match length of GNSS data (same resolution)

%% Atmospheric pressure anomaly through time series
meanPress = mean(fjordPress.atmospheric_pressure_hPa_);
pressAnomaly = fjordPress.atmospheric_pressure_hPa_-meanPress;

%% Calculate anomaly in ellipsoidal height (tidal variability)
%plot(times,gnss.ellipsoid_height_m,'k-')
stableGNSS = mean(gnssFjord(gnssFjord.datetime >"25-Jul-2026 07:00:00" & gnssFjord.datetime < "08-Aug-2026 18:00:00","ellipsoid_height_m"));
anomalyGNSS = gnssFjord.ellipsoid_height_m - table2array(stableGNSS);

%figure
%plot(fjordTimes,anomalyGNSS,'r-')
%ylabel("Ellipsoidal height anomaly (m)")

%% Moving average of GNSS anomaly
figure
plot(fjordTimes,movmean(anomalyGNSS,24),'r-') % 2-hourly (24x5min window) rolling mean
ylabel("Ellipsoisal height anomaly (m)")

%% Named checkpoints (cruise "chapters")
names = ["Melange 1";"Melange 2";"Sorgenfri 1";"Sorgenfri 2";"Sorgenfri 3";"Kivioq"];
starts = datetime(["25-Jul-2026 18:00:00";"8-Aug-2026 08:00:00";"28-Jul-2026 14:00:00";...
    "11-Aug-2026 08:00:00";"13-Aug-2026 04:00:00";"12-Aug-2026 14:00:00"]);
ends = datetime(["27-Jul-2026 18:00:00";"10-Aug-2026 10:00:00";"7-Aug-2026 21:00:00";...
    "12-Aug-2026 07:00:00";inf;"12-Aug-2026 20:00:00"]);

chapters = table(names,starts,ends);

%% Coordinate bounds for ship position
% can also do this by time indexing (look at checkpoints gpkg)
outerFjord = [68.0 68.24 -30.6 -30.4]; % minlat maxlat minlon maxlon
innerFjord = [68.23 68.3 -30.9 -30.6]; 

%iceFront = ;
%sill = ;
%doubleTrough = ;
%mouth = ;
%throat = ; 

%% Extract index locations of GNSS height for inner & outer fjord areas. 
maskOuter = find(gnssFjord.latitude > outerFjord(1) & ...
                 gnssFjord.latitude < outerFjord(2) &...
                 gnssFjord.longitude > outerFjord(3) &...
                 gnssFjord.longitude < outerFjord(4));

maskInner = find(gnssFjord.latitude > innerFjord(1) & ...
                 gnssFjord.latitude < innerFjord(2) &...
                 gnssFjord.longitude > innerFjord(3) &...
                 gnssFjord.longitude < innerFjord(4));

%fjordMasked = gnssFjord;

%% Plot tidal time series and GNSS height anomaly on same axes
% Shade inner fjord?
figure
subplot(2,1,1)
plot(fjordTimes,z,'b-')
hold on
plot(fjordTimes,movmean(anomalyGNSS,24),'k-')
ylabel("Height (m)")
xlabel("Time")
legend({'Tidal height','GNSS anomaly'})
% Shade time intervals where ship was in inner fjord (light), outer fjord (dark)
%shade()
subplot(2,1,2)
plot(fjordPress.time,pressAnomaly,'r-')
%plot(fjordPress.time,fjordPress.atmospheric_pressure_hPa_,'m-')
xlabel("Time")
ylabel("Pressure anomaly (hPa)")


%% Correlation of tidal height & GNSS height anomaly
figure
scatter(z,anomalyGNSS,'k','filled')
ylabel("GNSS anomaly")
xlabel("Tidal height")
hold on
% 1:1 line (gradient = 1, y-intercept = 0)
plot(z,z,color="r")

%% Correlation of ellipsoidal height anomaly and atmos. pressure (anomaly?)
figure
scatter(pressAnomaly,anomalyGNSS,"filled")
xlabel("Ellipsoidal height anomaly (m)")
ylabel("Atmospheric pressure anomaly (hPa)")
hold on

%% Draw best-fit regression through points (sinusoidal?)
% Consider linearized least squares if period is known?

% Fit sine wave using nonlinear regression (period unknown)
% -----------------------------
% Define fit type as sinusoidal
ft = fittype('A*sin(2*pi*f*x + phi) + C', ...
    'independent', 'atmospheric_pressure_hPa_', 'dependent', 'ellipsoid_height_m',... 
    'coefficients', {'A', 'f', 'phi', 'C'});
% do press and height need to be in the same dataset?

% Provide reasonable initial guesses to help convergence
A0 = (max(anomalyGNSS) - min(anomalyGNSS)) / 2; % Amplitude
f0 = 1; % Frequency
phi0 = 0; % Phase (radians)
C0 = mean(anomalyGNSS); % vertical offset?

% Perform the fit
[fitresult, gof] = fit(fjordTimes, anomalyGNSS, ft,'StartPoint', [A0, f0, phi0, C0]);

% -----------------------------
% Display results
% -----------------------------
disp('Fitted parameters:');
disp(fitresult);
disp('Goodness of fit:');
disp(gof);

% -----------------------------
% Plot original data and fitted curve
% -----------------------------
figure;
plot(fjordTimes, anomalyGNSS, 'b.', 'DisplayName', 'Noisy Data'); hold on;
plot(fitresult, 'r-', 'DisplayName', 'Fitted Sine Wave');
xlabel('Time (s)');
ylabel('Signal');
legend('show');
grid on;
title('Sinusoidal Regression in MATLAB');


%% Detrend ellipsoidal height anomaly with respect to atmos. pressure?


%% Isolate M2 tidal signal?

%% GNSS height coloured by time (approximates position in fjord)
% Define colour ramp

% Scatter plot
scatter(,,,)