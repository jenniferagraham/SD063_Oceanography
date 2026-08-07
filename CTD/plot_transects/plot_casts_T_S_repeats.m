%Script to plot all casts from ice front section for comparison
%% add path 
close all; clear all;

%Need to specify mac or not
mac=0; % macusers use mac=1;window users use mac=0

%if reF_station=[], it plots casts. If you give it a ref station, it plots
%anomolies.
ref_station=[];

%turn off here as this is only used to plot envelope (using means and stds)
plot_envelope=0;

if mac==0
    addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    ctddata = [disk,'CTD\BASproc\'];
   
elseif mac==1
     addpath '/Volumes/legwork/scientific_work_areas/oceanography/CTD/Code/'
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    ctddata = [disk,'CTD/BASproc/'];
end
%% load CTD structure data 
 cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%% select the sections 
%sectionfilename='repeat_3m_icefront';%'repeat_3m_icefront';
 sectionfilename={'repeat_3moutermouth'};
 sectionfilename={'repeat_3mmmouthsectionrepeats'};

%sectionfilename={'3mbeaksouth-1','3mbeaksouth-2'};

% sectionfilename='3mtransect';
% sectionfilename='3mtransect_anomalies'; 
% sectionfilename='3micefronttest';
% sectionfilename ='3micefronttowyo';

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

for m=1
%Add in ice front repeat
P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder 
ncasts = length(P.sectionlist);
stns=P.sectionlist;
blueScale = abyss(ncasts); 
orangeScale = autumn(ncasts);
phaseScale=hsv(ncasts);

allstations=[ctds.station];
ind=zeros(size(stns));
for n=1:length(stns)
    try
        ind(n)=find(allstations==stns(n));
    catch
        error('Cannot find %s station %d',cruise,stns(n));
    end
end
ctds_plot=ctds(ind);


%% loop the sections 
for ii=1:ncasts
    if m==1
        cols=blueScale(ii,:);
    elseif m==2
             cols=orangeScale(ii,:);
    end
   % else
    %    cols=[0.0 0.0 0.0];  
    %end

    ax= sd063_cast_plots(ctds_plot(ii),cols,ref_station,plot_envelope);
    hold on;

    ctd_time=datetime(ctds_plot(ii).gtime);
    ctds_times=[ctds_times ctd_time];
    cast_number=[cast_number P.sectionlist(ii)];
end

end

subplot(1,4,3:4)
labels = string(ctds_times) + " (" + string(cast_number) + ")";
legend(labels,'Location','northeast','FontSize',8);

%lgd=legend([string(ctds_times),(cast_number)],'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts2_%s.png', sectionfilename);
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
