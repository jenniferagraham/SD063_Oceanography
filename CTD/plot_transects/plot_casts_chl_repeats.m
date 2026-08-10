%Script to plot all casts from ice front section for comparison
addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
close all; clear all;

%% choices 
cruise='SD063';
sectionfilename='repeat_3m_icefront';%'repeat_3m_icefront';
%sectionfilename='repeat_3msillpeak'; [N or peak?]

%%
if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    ctddata = [disk,'CTD\BASproc\'];
elseif ismac
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
     ctddata = [disk,'CTD/BASproc/'];

end

%%
load([ctddata,cruise,'_ctd.mat']);

P = sdaSectionParams(sectionfilename);

ncasts = length(P.sectionlist);

blueScale = abyss(3); 
orangeScale = autumn(ncasts-3);
grey  = [0.55 0.55 0.55];

ctds_times=[];

%Add in ice front repeat
for ii=1:ncasts
    if ii<=3
        cols=blueScale(ii,:);
    else
        cols=orangeScale(ii-3,:);
    end
    ax= sd063_cast_plots_Chl(P.sectionlist(ii),cols);
    hold on;
    ctd_time=datetime(ctds(P.sectionlist(ii)).gtime);
    ctds_times=[ctds_times ctd_time];
end

subplot(1,4,2)
lgd=legend(string(ctds_times),'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts_Chl_%s.png', sectionfilename);
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
