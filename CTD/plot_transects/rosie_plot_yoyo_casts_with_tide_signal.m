%Script to plot all casts from ice front section for comparison, and where
%multiple sections exist, find the mean and std and make envelope...

%% add path
close all; clear all;

if ispc
    addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    ctddata = [disk,'CTD\BASproc\'];
    addpath([disk,'CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'matlabF\']) % for cmocean
else
    addpath '/Volumes/legwork/scientific_work_areas/oceanography/CTD/Code/'
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    ctddata = [disk,'CTD/BASproc/'];
end
%% load CTD structure data
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%% select the sections
%sectionfilename={'repeat_3m_icefront','yoyo_3meastsill','yoyo_3mwestsillouter','repeat_3moutermouth'};
%'repeat_3m_icefront';
%sectionfilename='repeat_3msillpeak';
sectionfilename={'repeat_3micefrontsouthyoyoonly'};

grey  = [0.55 0.55 0.55];

ctds_times=[];
cast_number=[];

for m=1
    %Add in ice front repeat
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
    ctds_n=ctds(ind);

    ncolours=100;
    cmap=cmocean('phase',ncolours);

    tidestep=1/(ncolours-1);
    tidebounds=[0:tidestep:1];

    theta=0:1:360;
    %% loop the sections, now plotting
    for ii=1:ncasts
        line_style='-';

        cnumbertide=zeros(ncasts,1);
        for c=1:ncasts
            [junk,ind]=min(ctds_n(ii).tide_phase_fraction>tidebounds);
            cnumbertide(c)=ind;
        end


        ax=gobjects(1,2);
        figure(1)
        orient landscape
        ax(1)=subplot(2,3,[1,4]);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        ylabel(gca,'Pressure (dbar)')
        xlabel('\theta (^oC)')
        xlim([-1.5 1.5])

        grid on
        set(ax(1),'XTick',-5:0.5:5.0);
        h=plot(ctds_n(ii).Ctemp,ctds_n(ii).press,'Color',cmap(cnumbertide(ii),:),'LineWidth',2,'LineStyle',line_style);


        ax(3)=subplot(2,3,[2,5]);
        set(ax(3),'XTick',-10:1:100);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        xlabel('Salinity');
        ylabel(gca,'Pressure (dbar)')
        xlim([28 36])
        h=plot(ctds_n(ii).asalin,ctds_n(ii).press,'Color',cmap(cnumbertide(ii),:),'LineWidth',2);
        grid on;
        hold on;
        %
        ctd_time=datetime(ctds_n(ii).gtime);
        ctds_times=[ctds_times ctd_time];
        cast_number=[cast_number P.sectionlist(ii)];

        ax(5)=subplot(2,3,3);
        h=plot(ctds_n(ii).asalin,ctds_n(ii).Ctemp, 'Color',cmap(cnumbertide(ii),:),'LineWidth',1.5,'LineStyle',':');
        hold on
        xlabel('Salinity')
        ylabel('\theta (^oC)')

        grid on 

        % add density contours 
        thetaTS=[-1.5:0.1:1.5];
        s=[30:0.5:35];

        smin=min(s)-0.01.*min(s);
        smax=max(s)+0.01.*max(s);
        thetamin=min(thetaTS)-0.1*max(thetaTS);
        thetamax=max(thetaTS)+0.1*max(thetaTS);
        xdim=round((smax-smin)./0.1+1);
        ydim=round((thetamax-thetamin)+1);
        dens=zeros(ydim,xdim);
        thetai=((1:ydim)-1)*1+thetamin;
        si=((1:xdim)-1)*0.1+smin;
        for j=1:ydim
            for i=1:xdim
                dens(j,i)=gsw_sigma0(si(i),thetai(j)); % LC modified potential density anomaly
            end
        end
        [c,h] = contour(si, thetai, dens, 20:1:28, ...
            'Color', [0.6 0.6 0.6], ...
            'LineWidth', 0.3);

        clabel(c,h, ...
            'Color', [0.4 0.4 0.4], ...
            'FontWeight', 'normal', ...
            'FontSize', 8, ...
            'LabelSpacing', Inf );
        h.HandleVisibility = 'off';

        hold on;

        ax(4)=subplot(2,3,6);
        plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
        hold on
        plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
        xlabel('Idealised tidal phase');
        ylabel(gca,'Illustrative tidal wave');
        title("CTDs timings in tidal cycle ")
    end
end

subplot(2,3,[2,5])
labels = string(ctds_times) + " (" + string(cast_number) + ")";
legend(labels,'Location','southwest','FontSize',8);

set(gcf, 'Color', 'w')

name = sprintf('_ctd_casts_tides_frontsouthyoyo%s.png', sectionfilename{1});
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)
