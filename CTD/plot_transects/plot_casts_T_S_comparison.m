%Script to plot all casts from two different sections for comparison
addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
close all; clear all;

disk = ['L:\work\scientific_work_areas\oceanography\'];
ctddata = [disk,'CTD\BASproc\'];
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%are you plotting repeats? if so
repeats=0;
sill_repeat=0;
front_repeat=0;
%otherwise
%repeats=0;

sectionfilenames={'3msill','3mhead','3mdoubletrough','3macrosssill'}

%sectionfilenames={'repeat_3moutermouth','repeat_3minnermouth','repeat_3m_3msillpeak','repeat_3m_icefront'};

%Set colours for lines:
col_setup={'k','b','r','k'};

greenScale = [
    0.00 0.25 0.00
    0.00 0.40 0.00
    0.10 0.55 0.10
    0.25 0.70 0.25
    0.50 0.85 0.50
    0.80 0.95 0.80
    ];

blueScale = [
    0.00 0.10 0.40
    0.00 0.25 0.60
    0.10 0.40 0.75
    0.25 0.55 0.90
    0.50 0.75 0.98
    0.80 0.92 1.00
    ];

orangeScale = [
    0.45 0.18 0.00   % Dark burnt orange
    0.65 0.30 0.02   % Burnt orange
    0.82 0.45 0.08   % Deep orange
    0.94 0.62 0.18   % Orange
    0.98 0.78 0.45   % Light orange
    1.00 0.93 0.75   % Very pale orange
    ];

repeatScale_cols = [
    0.65 0.30 0.02   % Burnt orange
    0.94 0.62 0.18   % Orange
    1.00 0.93 0.75   % Very pale orange
    ];

grey  = [0.55 0.55 0.55];

repeatScale={'c','r','g','k'};

ctds_times=[];
if repeats
    for m=2
        %    for m=1:length(sectionfilenames)
        P = sdaSectionParams(sectionfilenames{m});
        for ii=1:length(P.sectionlist)
            cols=repeatScale_cols(ii,:);
            sd063_cast_plots(P.sectionlist(ii),cols);
            ctd_time=datetime(ctds(P.sectionlist(ii)).gtime)
            ctds_times=[ctds_times ctd_time];
            hold on;
        end
    end

else
    %for m=1:length(sectionfilenames)
    for m=4
        P = sdaSectionParams(sectionfilenames{m});
        for ii=1:length(P.sectionlist)
            if m==1
                if ii==3
                 cols=grey(1,:);
                else
                cols=blueScale(ii,:);
                 end
            elseif m==2
                cols=blueScale(ii,:);
                
            elseif m==3 || m==4
                cols=orangeScale(ii,:);

            end
            ctd_time=datetime(ctds(P.sectionlist(ii)).gtime)
            ctds_times=[ctds_times ctd_time];
            sd063_cast_plots(P.sectionlist(ii),cols);
            hold on;
        end
    end

    %Now add in sill repeat:
    if sill_repeat
        sectionfilenames={'repeat_3m_3msillpeak'};
        P = sdaSectionParams(sectionfilenames{m});
        for ii=2
            cols=repeatScale_cols(ii,:)
            sd063_cast_plots(P.sectionlist(ii),cols);
            ctd_time=datetime(ctds(P.sectionlist(ii)).gtime)
            ctds_times=[ctds_times ctd_time];
            hold on;
        end

    end

    %Add in ice front repeat
    if front_repeat
        sectionfilenames={'repeat_3m_icefront'};
        P = sdaSectionParams(sectionfilenames{1});
        for ii=1:3
            cols=repeatScale_cols(ii,:);
            if ii==1
                cols=grey(1,:);
            else
                cols=repeatScale_cols(ii,:);
            end
            ax= sd063_cast_plots(P.sectionlist(ii),cols);
            hold on;
            ctd_time=datetime(ctds(P.sectionlist(ii)).gtime)
            ctds_times=[ctds_times ctd_time];
        end

    end
end

subplot(1,4,2)
lgd=legend(string(ctds_times),'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts_%s.png', sectionfilenames{m});
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
