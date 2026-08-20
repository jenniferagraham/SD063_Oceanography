
%%% Script to take each CTD station with repeats and plot which phase of of
%%% the tide phase that station was taken in,
%%% Can also plot today's tidal cycle.
%%% This code was created on the SDA for cruise planning purposes.

%%% Created by Rosie Williams August 2026

%% add path
addpath L:\work\scientific_work_areas\oceanography\matlabF\
%addpath([disk,'\GSWscripts\gsw_matlab_v3_06_16\'])
close all; clear all;

%plot today's tides?
today=1;
subplot_plotting=0;

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

    tdrive=input('What letter is your temp drive, e.g., T or P?\n','s');
    tidemodel = fullfile(sprintf('%s:/SD063/Gr1kmTM/data/Gr1kmTM_v1.nc',...
        tdrive));

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

%sectionfilename={'repeat_3m_icefront','yoyo_3meastsill','repeat_3moutermouth'};
%sectionfilename={'repeat_3micefront', 'repeat_3micefrontSouth', '3mdoubletrough'};%,'repeat_3meastsill','repeat_3msillnorthpeak','repeat_3mwestsill','repeat_3mmouth','repeat_3mbeak'};
sectionfilename={'repeat_3micefront', 'repeat_3mwestsill','repeat_3msillnorthpeak','repeat_3meastsill','repeat_3mmouth','repeat_3mbeak'};

sectionfilename={'3micefront_section-2','3micefronttowyo','3mhead','3mdoubletrough','3mdoubletrough-2'}
%sectionfilename={'repeat_3micefrontsouthyoyoonly'};

%sectionfilename={'3mshelfnorth'};

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

figure;

for m=1:length(sectionfilename)
    %for m=1

    P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder

    ncasts = length(P.sectionlist);
    stns=P.sectionlist;

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


    theta=0:1:360;
    %  name = sprintf(sectionfilename{m})
    if subplot_plotting
        for ii=1:ncasts
            if m==1
                subplot(2,3,1)
                title('ice front [43 81]')
            elseif m==2 
                subplot(2,3,2)
                title({'Repeat stations: timing of stations relative to tides','west sill [76]'})
            elseif m==3 
                subplot(2,3,3)
                title('sill north peak [33]')
            elseif m==4
                subplot(2,3,4)
                title('east sill [51]')
            elseif m==5
                subplot(2,3,5)
                title('mouth [29]')
            elseif m==6
                subplot(2,3,6)
                title('beak [28]')
            else
                error('You have run out of panels - exiting!')
            end
            plot(ctds_plot(ii).tide_phase_fraction,cosd(ctds_plot(ii).tide_phase_fraction*360),'r o','MarkerSize',6,'LineWidth', 1.5);
            hold on
            plot(theta/360,cosd(theta),'b-','LineWidth',1.5);
        end
    else
        clf
        plot(theta/360,cosd(theta),'b-','LineWidth',1.5);
        hold on
        for ii=1:ncasts 
            plot(ctds_plot(ii).tide_phase_fraction,cosd(ctds_plot(ii).tide_phase_fraction*360),'r o', 'MarkerSize', 6);
        end
        title(P.sectionname)
        name = sprintf('_%s.png',sectionfilename{m});
        exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300);

    end
      
 set(gcf, 'Color', 'w')   
end

if subplot_plotting
    name = sprintf('_tides_at ctd_repeats.png');
    exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300);
end

%plot today's tides:
if today==1
    figure;
    today = datetime('today');
    tmw=datetime('tomorrow');
    % t =  today:hours(1):tmw;
    t = today + hours(12):hours(1):today + days(1) + hours(12);

    z = tmd_predict(tidemodel,68.2796,-30.7665,t);
  %  figure
    plot(t,z)
    box off
    ylabel('tide height (m)')
    grid on
    %xline(datetime(2026,8,5)+[0:40],'k--')
    % xline(datetime(2026,8,5)+[0:40],ctd_time,'k --')
    % xlim([t(1),t(end)])
    % set(gcf,'color','w')

    %xline(t, 'k--')
    xlim([t(1), t(end)])
    set(gcf,'color','w')
    hold on

    % Hourly vertical lines
    xline(t, '--', 'Color', [0.85 0.85 0.85], 'LineWidth', 0.5)

    % Hourly date + time labels
    xticks(t)
    xticklabels(datestr(t,'dd-mmm HH:MM'))

    title('Tides today')
set(gcf, 'Color', 'w')
    name = sprintf('_tides_today_%s.png', today);
    exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300);

end






