% harmonic analysis of CTD timeseries? 

time    % datetime array
ziso    % isopycnal depth (m)

%% For single constituent: 
% Time in hours since first cast
t = hours(time - time(1));

% M2 period (hours)
T_M2 = 12.4206;
omega = 2*pi/T_M2;

% Design matrix
G = [ones(size(t)) ...
    cos(omega*t) ...
    sin(omega*t)];

% Least-squares fit
m = G \ ziso(:);

mean_depth = m(1);
Acos = m(2);
Asin = m(3);

% Amplitude and phase
amp = hypot(Acos,Asin);
phase = atan2(Asin,Acos);

% Fitted time series
zfit = G*m;

fprintf('Amplitude = %.2f m\n',amp)
fprintf('Phase = %.2f deg\n',rad2deg(phase))

figure
plot(time,ziso,'ko')
hold on
plot(time,zfit,'r-','LineWidth',2)
set(gca,'YDir','reverse')
ylabel('Isopycnal depth (m)')
legend('Observed','M2 fit')

%% or multiple constituents

omega_M2 = 2*pi/12.4206;
omega_S2 = 2*pi/12.0000;

G = [ones(size(t)) ...
    cos(omega_M2*t) sin(omega_M2*t) ...
    cos(omega_S2*t) sin(omega_S2*t)];

m = G \ ziso(:);

zfit = G*m;

%%

rho_list = [26.8 27.0 27.2 27.4];
ziso(time,isopycnal)

%
%% Fit M2 (or M2+S2) to each.
%Compare amplitudes and phases versus density/depth.
% If it's an internal tide, you'll often find all isopycnals in the pycnocline 
% oscillating with nearly the same phase and amplitudes of several metres to tens of metres. 
% That coherence is often more convincing than looking at a single density surface.

phaseM2 = mod((t - tref)/12.4206,1)*360;
theta = deg2rad(phaseM2);

G = [ones(size(theta)) ...
    cos(theta) ...
    sin(theta)];

m = G\ziso(:);

zfit = G*m;

amp = hypot(m(2),m(3));
phi = atan2(m(3),m(2));

%%
% Consider influence of mean vs tidal variability?? 

zanom = ziso - mean(ziso(survey_id==k));
bins = 0:30:360;

for i = 1:length(bins)-1
    idx = phase >= bins(i) & phase < bins(i+1);
    zbin(i) = mean(zanom(idx));
end

%% How to remove background variability? 

rho_mean = mean(rho_allcasts,2,'omitnan');

rho_anom = rho_cast - rho_mean;
% or 
zanom = ziso - mean(ziso);

%% recommended check? 
scatter(distance_along_fjord,ziso,[],phase)


%% 
% With ADCP data you're in a much stronger position than with CTDs alone. The key question becomes: are you trying to estimate the barotropic tide, the baroclinic tide, or the full tidal velocity field?
% 
% 1. Start by separating barotropic and baroclinic velocity
% 
% % For each profile u(z,t)u(z,t), v(z,t)v(z,t):
% 
% Barotropic component
% 
% Compute the depth-mean velocity:
% 
% uˉ(t)=1H∫−H0u(z,t) dz\bar{u}(t) = \frac{1}{H}\int_{-H}^0 u(z,t)\,dz vˉ(t)=1H∫−H0v(z,t) dz\bar{v}(t) = \frac{1}{H}\int_{-H}^0 v(z,t)\,dz
% 
% In practice:
% 
% ubar = mean(u,1,'omitnan');
% vbar = mean(v,1,'omitnan');
% 
% 
% (or depth-weighted averaging if bin spacing varies).
% 
% This is your best estimate of the barotropic tidal current.
% 
% Baroclinic component
% 
% Subtract the depth mean:
% 
% u_bc = u - ubar;
% v_bc = v - vbar;
% 
% 
% These residuals contain:
% 
% internal tides,
% estuarine circulation,
% shear-driven flows,
% other depth-varying motions.
% 2. Fit tidal constituents to the depth-mean flow
% 
% If your observations span multiple days, use UTide or t_tide.
% 
% For example:
% 
% coef_u = ut_solv(datenum(time),ubar,[],latitude,'auto');
% coef_v = ut_solv(datenum(time),vbar,[],latitude,'auto');
% 
% 
% or fit the complex velocity:
% 
% U = ubar + 1i*vbar;
% 
% coef = ut_solv(datenum(time),U,[],latitude,'auto');
% 
% 
% Then extract:
% 
% coef.name
% coef.A
% coef.g
% 
% 
% for M2, S2, K1, O1, etc.
% 
% 3. If sampling is sparse
% 
% Your sampling sounds unconventional:
% 
% VMADCP along ship tracks,
% LADCP during CTD stations,
% repeated occupations during discrete surveys.
% 
% You may not have sufficiently continuous time series for a classical harmonic analysis.
% 
% In that case I'd do something closer to what we discussed for isopycnals.
% 
% Assign tidal phase
% 
% For each profile:
% 
% theta = tidal_phase_from_TPXO;
% 
% 
% Then fit
% 
% u(z,θ)=u0(z)+Au(z)cos⁡θ+Bu(z)sin⁡θ.u(z,\theta) = u_0(z) + A_u(z)\cos\theta + B_u(z)\sin\theta .
% 
% At each depth:
% 
% G = [ones(size(theta)) cos(theta) sin(theta)];
% 
% for k = 1:nz
% 
%     m = G \ u(k,:)';
% 
%     amp(k) = hypot(m(2),m(3));
%     phase(k) = atan2(m(3),m(2));
% 
% end
% 
% 
% Repeat for vv.
% 
% 4. A better fjord-specific approach: EOFs + tidal phase
% 
% Greenland fjords often have:
% 
% u(z,t)=uestuary+utide+uinternalu(z,t) = u_{\rm estuary} + u_{\rm tide} + u_{\rm internal}
% 
% The dominant depth structure is frequently low-dimensional.
% 
% I would strongly consider:
% 
% [EOFs,PCs] = pca(u');
% 
% 
% Then fit M2 to the leading principal components.
% 
% For example:
% 
% PC1 = PCs(:,1);
% 
% G = [ones(size(theta)) cos(theta) sin(theta)];
% 
% m = G\PC1;
% 
% 
% If PC1 is strongly tidal, you'll recover a clear semidiurnal signal.
% 
% This is frequently more robust than fitting every depth bin independently.
% 
% 5. Looking for internal tidal currents
% 
% After removing the depth mean:
% 
% u_bc = u - ubar;
% 
% 
% fit the tidal constituents at each depth.
% 
% An internal tide will often appear as:
% 
% near-zero amplitude at some depth (a modal node),
% phase reversal across the node,
% maximum velocity near pycnocline depths.
% 
% For a mode-1 internal tide you might see:
% 
% surface     --->
% 
% mid-depth      0
% 
% deep       <---
% 
% 
% or vice versa.
% 
% The phase structure is often more informative than the amplitude.
% 
% 6. With LADCP specifically
% 
% LADCP profiles are snapshots, not continuous time series.
% 
% I'd use them as follows:
% 
% Rotate velocities into along-fjord/cross-fjord coordinates.
% Remove a mean spatial circulation.
% Assign each profile a tidal phase from TPXO/FES.
% Bin by tidal phase:
% 0-90°
% 90-180°
% 180-270°
% 270-360°
% 
% Compare mean velocity structures.
% 
% This often reveals tidal shear surprisingly clearly.
% 
% What I would do in your fjord
% 
% Given:
% 
% repeated CTDs,
% LADCP on CTD stations,
% VMADCP underway sections,
% 
% I'd:
% 
% Rotate all velocities into along-fjord coordinates.
% Calculate depth-averaged velocity from LADCP and VMADCP.
% Use TPXO/FES to assign M2 phase.
% Fit M2 to:
% isopycnal-heave anomalies,
% depth-mean current,
% depth-dependent velocity.
% Examine whether the isopycnal-heave phase lags or leads the depth-mean tidal current.
% 
% That last comparison is often the most physically meaningful test of internal-tide behaviour, since internal-tide generation is usually tied more closely to the oscillatory barotropic flow than to sea-surface high or low water.