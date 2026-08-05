%Script to plot all casts from ice front section for comparison
addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
close all; clear all;

disk = ['L:\work\scientific_work_areas\oceanography\'];
ctddata = [disk,'CTD\BASproc\'];
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

sectionfilename='repeat_3m_icefront';%'repeat_3m_icefront';
%sectionfilename='repeat_3msillpeak'; %{'3macrosssill-1','3macrosssill-2'};

%sectionfilename='yoyo_3meastsill';

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

%Add in ice front repeat
P = sdaSectionParams(sectionfilename);
ncasts = length(P.sectionlist);
blueScale = abyss(ncasts); 
orangeScale = autumn(ncasts);

for ii=1:ncasts
    if ii<3
        cols=blueScale(ii,:);
    else
        cols=orangeScale(ii,:);
    end

    ax= sd063_cast_plots(P.sectionlist(ii),cols);
    hold on;
    ctd_time=datetime(ctds(P.sectionlist(ii)).gtime);
    ctds_times=[ctds_times ctd_time];
    cast_number=[cast_number P.sectionlist(ii)];
end

subplot(1,4,3:4)
labels = string(ctds_times) + " (" + string(cast_number) + ")";
legend(labels,'Location','northeast','FontSize',8);

%lgd=legend([string(ctds_times),(cast_number)],'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts2_%s.png', sectionfilename);
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
