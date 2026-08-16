% script to plot varying isopycnal depths with tidal phase

close all; clear all;

selectvisit=false;

%% add paths
if ispc
    addpath('../../matlabF/')

    disk = ['L:\work\scientific_work_areas\oceanography\'];
    Tdisk = ['P:\SD063\']; % JG T-drive = P-drive!
    %Tdisk = ['T:\SD063\'];
    ctddata = [disk,'CTD\BASproc\'];
    addpath('../../matlabF/')

elseif ismac
    disk = '/Volumes/legwork/scientific_work_areas/oceanography/';
    addpath('/Volumes/legwork/scientific_work_areas/oceanography/matlabF/')
    Tdisk = ['/Volumes/Scratch/SD063/']; 
    ctddata = [disk,'CTD/BASproc/'];

end
%%
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

% yoyo stations to compare? 
% repeat_3micefrontsouthyoyoonly ; repeat_3micefrontnorthyoyoonly ; 
% repeat_3msouthtroughyoyoonly ; repeat_3msouthtroughyoyosite
% repeat_3mwestsill ; 'all)
% repeat_3micefront ?? '3micefrontsouth-fjord2'
sectionfilename='repeat_3meastsill'; % repeat_3msill[n or peak]
fjordvisit=2; % 1, 2, or 'all'

P = sdaSectionParams(sectionfilename);
P.sectionlist = sort(P.sectionlist);

if selectvisit
    switch fjordvisit
        case 1
            P.sectionlist = P.sectionlist(P.sectionlist < 136);
        case 2
            P.sectionlist = P.sectionlist(P.sectionlist > 164);
        case 'all'
            disp('Using all available data ...')
    end
end

ncasts = length(P.sectionlist);
ctds_stns = ctds(P.sectionlist);

%%
nz = length(ctds(1).depth);
pressS=NaN(nz,ncasts);
sigma0=NaN(nz,ncasts);
phase=NaN(1,ncasts);

for ii=1:ncasts
    pressS(:,ii)=ctds_stns(ii).press;
    sigma0(:,ii)=ctds_stns(ii).sigma0;
    phase(ii) = ctds_stns(ii).tide_phase_fraction;
end

%% Consider subtracting mean profile? 
sigma0_mean = mean(sigma0,2,'omitnan');

%% isopycnal depths? 

targets = [26.1 26.3 26.5 26.7];

iso_depths = nan(length(targets),ncasts);

for k = 1:ncasts

    sig = sigma0(:,k);
    z   = pressS(:,k);

    ind = ~isnan(sig) & ~isnan(z);

    if sum(ind) > 1
        iso_depths(:,k) = interp1(sig(ind),z(ind), ...
            targets,'linear',NaN);
    end
end

ind = ~isnan(sigma0_mean) & ~isnan(z);
iso_depths_mean = interp1(sigma0_mean(ind),z(ind), ...
    targets,'linear',NaN);

%%
figure('Position', [100, 100, 1000, 800]);
subplot(2,1,1)
for n = 1:length(targets)
    scatter(phase, iso_depths(n,:), 'filled')
    hold on
end
grid on 
set(gca,'YDir','reverse')
ylabel('Isopycnal depth, m')
legend(string(targets))

subplot(2,1,2)
for n = 1:length(targets)
    scatter(phase, iso_depths(n,:)-iso_depths_mean(n), 'filled')
    hold on
end
ylabel('Isopycnal depth anomaly, m')
set(gca,'YDir','reverse')
grid on 

title(sprintf('Isopycnal depths - %s'),sectionfilename)

if selectvisit
    name = sprintf('Iso_depth_tides_%s-fjord%s.png', sectionfilename, ...
        string(fjordvisit));
else
    name = sprintf('Iso_depth_tides_%s.png', sectionfilename);
end
exportgraphics(gcf, fullfile('Figures','Isopyc_depths',...
    [cruise name]), 'Resolution', 300)
