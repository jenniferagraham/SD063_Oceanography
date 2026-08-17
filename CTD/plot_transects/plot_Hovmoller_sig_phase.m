%Hovmoller plots

close all; clear all;

lowering_tide=false;
fjordvisit=2;

%% add paths
if ispc
addpath('../../matlabF/')

disk = ['L:\work\scientific_work_areas\oceanography\'];
Tdisk = ['P:\SD063\']; % JG T-drive = P-drive!
%Tdisk = ['T:\SD063\'];
ctddata = [disk,'CTD\BASproc\'];
addpath('../../matlabF/')
addpath T:/SD063/TMD3.0

elseif ismac
    disk = '/Volumes/legwork/scientific_work_areas/oceanography/';
    addpath('/Volumes/legwork/scientific_work_areas/oceanography/matlabF/')

    Tdisk = ['/Volumes/Scratch/SD063/']; % JG T-drive
    ctddata = [disk,'CTD/BASproc/'];

end
%%

cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%Option to zoom axes in on the ice front section yoyo:
yoyo_zoom=0;

%figure;
if yoyo_zoom
figure('Position', [100, 100, 800, 600])
else
 figure('Position', [10, 100, 1250, 600])
end

% yoyo stations to compare? 
% repeat_3micefrontsouthyoyoonly ; repeat_3micefrontnorthyoyoonly ; 
% repeat_3msouthtroughyoyoonly ; repeat_3msouthtroughyoyosite
% repeat_3mwestsill ; 
% repeat_3micefront ??
sectionfilename='repeat_3micefrontnorthyoyoonly'; % repeat_3msill[n or peak]

P = sdaSectionParams(sectionfilename);
P.sectionlist = sort(P.sectionlist);
%%
if strcmp(sectionfilename,'all_inshore_of_sill')
    switch fjordvisit
        case 1
            P.sectionlist = P.sectionlist(P.sectionlist < 136);
        case 2
            P.sectionlist = P.sectionlist(P.sectionlist > 164);
        case 'all'
            disp('Using all available data ...')
    end
end
%%
ncasts = length(P.sectionlist);

blueScale = abyss(3);
orangeScale = autumn(ncasts);
grey  = [0.55 0.55 0.55];

grid=NaN(ncasts,3500);

ctd_time=NaT(1,ncasts);
uS=NaN(size(grid,2),ncasts);
vS=NaN(size(grid,2),ncasts);
pressS=NaN(size(grid,2),ncasts);
sigma0=NaN(size(grid,2),ncasts);
phase=NaN(1,ncasts);

%%%JENNY CHECK here - this is what I added to deal with the missing CTDs
%%%issue.
allstations=[ctds.station];
ind=zeros(size(P.sectionlist));
for n=1:length(P.sectionlist)
    try
        ind(n)=find(allstations==P.sectionlist(n));
    catch
        error('Cannot find %s station %d',cruise,P.sectionlist(n));
    end
end
%Then make ctds_stns that just contains the selected stations:
ctds_stns=ctds(ind);

%So now it's not calling ones from the ctds structure by index, it's
%calling via the list above.
for ii=1:ncasts
    ctd_time(ii)=datetime(ctds_stns(ii).gtime);
    uS(:,ii)=ctds_stns(ii).ladcp_u;
    vS(:,ii)=ctds_stns(ii).ladcp_v;
    pressS(:,ii)=ctds_stns(ii).press;
    sigma0(:,ii)=ctds_stns(ii).sigma0;
    phase(ii) = ctds_stns(ii).tide_phase_fraction;
end

[phase_sorted, idx] = sort(phase);
uS_phase = uS(:,idx);
vS_phase = vS(:,idx);
sigma0_phase = sigma0(:,idx);

phase_array = repmat(phase_sorted, 3500, 1);

sig_levels = [23 24 25 25.8 26:0.1:27 27.5 28];
sig_lines = [23 24 25 25.8 26.1:0.2:27 27.5 28];
uv_lev = [-0.1:0.005:0.1];
uv_lines = [-0.1:0.02:0.1];

%%
figure;
subplot(3,1,3)
ha=tight_subplot(3,1,[0.015 0.01], [0.11 0.05], [0.08 0.05]);
axes(ha(1))
contourf(phase_array, pressS, sigma0_phase,sig_levels,'LineColor', 'none')
set(gca,'YDir','reverse')
shading flat
colormap(ha(1), cmocean('thermal'))
colorbar(gca, 'east')
xlim([0,1])
caxis([23 28]);
hold on
contour(phase_array, pressS, sigma0_phase,sig_lines,'k')
ha(1).XTickLabel = {};
ha(1).XTick={};

axes(ha(2))
contourf(phase_array, pressS, uS_phase, uv_lev,'LineColor', 'none')
set(gca,'YDir','reverse')
shading flat
colormap(ha(2), cmocean('balance'))
colorbar(gca, 'east')
hold on
contour(phase_array, pressS, uS_phase, uv_lines,'k')
xlim([0,1])
caxis([-0.1 0.1]);
ha(2).XTickLabel = {};
ha(2).XTick={};

axes(ha(3))
contourf(phase_array, pressS, vS_phase, uv_lev,'LineColor', 'none')
set(gca,'YDir','reverse')
shading flat
colormap(ha(3), cmocean('balance'))
colorbar(gca, 'east')
hold on
contour(phase_array, pressS, vS_phase, uv_lines,'k')
xlim([0,1])
caxis([-0.1 0.1]);
ha(3).XTickLabel = 0:0.1:1;
ha(3).XTick= 0:0.1:1;


%% 
if strcmp(sectionfilename,'all_inshore_of_sill')
    name = sprintf('_Hovmoller_anomolies_sig_%s_fjord%d.png', sectionfilename, fjordvisit);
end
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
