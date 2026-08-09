%Script to plot all casts from ice front section for comparison
%% add path 
addpath L:\work\scientific_work_areas\oceanography\matlabF\
   addpath([disk,'\GSWscripts\gsw_matlab_v3_06_16\'])
close all; clear all;

%if reF_station=[], it plots casts. If you give it a ref station, it plots
%anomolies.
ref_station=[];
%turn off here as this is only used to plot envelope (using means and stds)
plot_envelope=0;

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

%run through different cruises
cruises={'SD063','SK2514','SD041'};

%% load CTD structure data 
 cruise='SD063';
%cruise='SD041_edited';
% cruise='SD063';
% load([ctddata_old,cruise,'_ctd.mat']);

if strcmp(cruise,'SD063')
    load([ctddata,cruise,'_ctd.mat']);
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

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

%for m=1:length(sectionfilename)
    for m=1
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
     %   if ii<6
        %    cols=orangeScale(ii,:);  
      %  else
        cols=RosieScale(m,:);
        line_style='-';
    elseif m==2
             cols=RosieScale(m,:);
             line_style='-';
    elseif m==3
        cols=RosieScale(6,:);
        line_style='-'
    end
    ax= sd063_cast_plots(ctds_plot(ii),cols,line_style,ref_station,plot_envelope);
    hold on;
    ctd_time=datetime(ctds_plot(ii).gtime);
    ctds_times=[ctds_times ctd_time];
    cast_number=[cast_number P.sectionlist(ii)];
end

end

subplot(1,4,3:4)
labels = string(ctds_times) + " (" + string(cast_number) + ")";
legend(labels,'Location','northeast','FontSize',8);

subplot(1,4,1)
xlim=[P.tcaxis]; 

%lgd=legend([string(ctds_times),(cast_number)],'Location','SouthWest','FontSize',8);
%,string(ctds_times(3)),string(ctds_times(4)),string(ctds_times(5)),string(ctds_times(6)),string(ctds_times(7)),'Location','SouthWest','FontSize',8)
lgd.ItemTokenSize = [12 10];

name = sprintf('_ctd_casts_%s.png', sectionfilename{1});
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
