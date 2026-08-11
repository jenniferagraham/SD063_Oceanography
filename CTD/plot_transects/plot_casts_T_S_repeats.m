%Script to plot all casts from ice front section for comparison
%% add path 
addpath L:\work\scientific_work_areas\oceanography\matlabF\
close all; clear all;

%if reF_station=[], it plots casts. If you give it a ref station, it plots
%anomolies.
ref_station=[];
%turn off here as this is only used to plot envelope (using means and stds)
plot_envelope=1;
use_tides=0;

if ispc 
    addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    ctddata = [disk,'CTD\BASproc\'];
    ctddata_old = [disk,'\Notes\PreviousDataProcessing\KANGGLAC_CTD_data\'];
   
else
    addpath '/Volumes/legwork/scientific_work_areas/oceanography/CTD/Code/'
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    ctddata = [disk,'CTD/BASproc/'];
end
addpath([disk,'\CTD\GSWscripts\gsw_matlab_v3_06_16\'])

%run through different cruises
cruises={'SD063','SK2514','SD041'};

%% load CTD structure data 
 cruise='SD063';
%cruise='SD041_edited';
% cruise='SD063';
% load([ctddata_old,cruise,'_ctd.mat']);

if strcmp(cruise,'SD063')
    if use_tides 
        load([ctddata,cruise,'_tides_ctd.mat']);
    else
        load([ctddata,cruise,'_ctd.mat']);
    end
elseif strcmp(cruise,'SK2514')
    load([ctddata_old,cruise,'_edited_ctd.mat']);
elseif strcmp(cruise,'SD041')
    load([ctddata_old,cruise,'_edited_ctd.mat']);
else
    error("no section lists for that cruise, sorry!")
end

%% select the sections 
%sectionfilename={'quick_comp'};
%sectionfilename={'deception_trough'};
sectionfilename={'repeat_3mmelangetrough'};
%sectionfilename={'aw_comp'};
% sectionfilename={'repeat_3mmmouthsectionrepeats'};
%sectionfilename={'kgtrough-1','kgtrough-2'};
sectionfilename={'kangglac_kgtrough'};
sectionfilename={'skag_kgtrough-1'};

sectionfilename={'repeat_3m_icefront','yoyo_3meastsill','repeat_3moutermouth'};

sectionfilename={'repeat_3m_icefront'};
%sectionfilename={'quick_comp'};

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

for m=1:length(sectionfilename)
%    for m=1
%Add in ice front repeat
%if strcmp(cruise, 'SD063')
P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder 
%elseif strcmp(cruise, 'SK2514_edited')
 %   P = sda041SectionParams(sectionfilename{m}); % function that needs to be in the same folder 
%elseif strcmp(cruise, 'SD041_edited')
%    P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder 
%else
%    error("no section lists for that cruise, sorry!")
%end
ncasts = length(P.sectionlist);
stns=P.sectionlist;
blueScale = abyss(ncasts); 
orangeScale = autumn(ncasts);
greenScale = summer(ncasts);
phaseScale=hsv(ncasts);
RosieScale =[
    0.00 0.35 0.75   % blue
    0.00 0.60 0.30   % green
    0.00 0.75 0.75   % turquoise
    0.00 0.00 0.00   % black
    0.90 0.45 0.05    % pink
    0.85 0.05 0.05   % red
];

% Make lighter versions for the repeats
phaseScale_light = 0.5 + 0.5*phaseScale;
RosieScale_light = 0.5 + 0.5*RosieScale;

%ncasts = length(ctds);
% Tidal phase for each CTD
%tidal_phase = [ctds.tidal_phase];

% Cyclic rainbow colormap
ncol = 256;
nhalf = ncol/2;
cmap1 = turbo(nhalf);
cmap_tides = [cmap1; flipud(cmap1)];


% Blue -> white -> red
blue = [linspace(0,1,ncol/2)', ...
    linspace(0,1,ncol/2)', ...
    ones(ncol/2,1)];
red = [ones(ncol/2,1), ...
    linspace(1,0,ncol/2)', ...
    linspace(1,0,ncol/2)'];
cmap_tides_rb = [blue; red];

n = ncol/2;

% Red -> blue
r = linspace(1, 0, n)';
g = zeros(n,1);
b = linspace(0, 1, n)';

half = [r g b];

% Blue -> red
cmap = [half; flipud(half)];

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
 %   for ii=4
    if m==1
      %  if ii<6
            %cols=RosieScale(m,:);  
%            cols=cmap_tides(ii,:);
       % end
        cols=orangeScale(ii,:);
        line_style='-';
    elseif m==2
             cols=RosieScale(m,:);
             line_style='-';
    elseif m==3
        cols=RosieScale(6,:);
        line_style='-'
    end

    if use_tides 
        col = interp1(linspace(0,180,ncol), cmap_tides, ctds(ii).tidal_phase);
        ax= sd063_cast_plots(ctds_plot(ii),col,line_style,ref_station,plot_envelope);
    else
        ax= sd063_cast_plots(ctds_plot(ii),cols,line_style);
    end
    hold on;
    ctd_time=datetime(ctds_plot(ii).gtime);
    ctds_times=[ctds_times ctd_time];
    cast_number=[cast_number P.sectionlist(ii)];
end
1;

end

subplot(1,4,3:4)
labels = string(ctds_times) + " (" + string(cast_number) + ")";
legend(labels,'Location','northeast','FontSize',8);

ax1 = subplot(1,4,1);
xlim(ax1, [P.tcaxis]); 
ylim(ax1, [0, P.maxy]); 

ax2 = subplot(1,4,2);
ylim(ax2, [0, P.maxy]); 

%lgd=legend([string(ctds_times),(cast_number)],'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts_%s.png', sectionfilename{1});
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
