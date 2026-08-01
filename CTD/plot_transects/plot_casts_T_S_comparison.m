%Script to plot all casts from two different sections for comparison
addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
close all; clear all;

disk = ['L:\work\scientific_work_areas\oceanography\'];
ctddata = [disk,'CTD\BASproc\'];
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%sectionfilenames={'3msill','3mhead','3mdoubletrough'}

sectionfilenames={'3minnermouthrepeats','3moutermouthrepeats'}

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

for m=1:length(sectionfilenames)
     P = sdaSectionParams(sectionfilenames{m});
for ii=1:length(P.sectionlist)
    if m==1
        if ii==3
            cols='r';
        else
        cols=greenScale(ii,:);
        end
    elseif m==2
        cols=blueScale(ii,:);
    elseif m==3
        cols=orangeScale(ii,:);
    end

    sd063_cast_plots(P.sectionlist(ii),cols);
    hold on;
end
end
