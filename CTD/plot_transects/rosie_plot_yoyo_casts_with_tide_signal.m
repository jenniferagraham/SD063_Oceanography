%Script to plot all casts from ice front section for comparison, and where
%multiple sections exist, find the mean and std and make envelope...
%Rosie Williams 14/08/2026

%Editing in progress - rush at end. Take a copy to play with if desired.

%% add path
close all; clear all;


%cchoice=input('What cmap do you want: phase or jet?\n','s');
c_jet=0; % if 0, uses phase

plot_casts_and_tides=1;
% within that, would you like me to plot the isopycnals?
plot_isopycnal=1;
plot_isopycnal=0;
plot_tide_metrics=0;


if ispc
    addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
    disk = ['L:\work\scientific_work_areas\'];
    ctddata = [disk,'oceanography\CTD\BASproc\'];
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\matlabF\']) % for cmocean
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter function
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
%sectionfilename={'repeat_3micefrontsouthyoyoonly'};

%sectionfilename={'repeat_3micefrontbothyoyo'};
sectionfilename={'3mdoubletroughsouth','3mdoubletroughnorth'};

sectionfilename={'3micefront_section-2','3micefronttowyo','3mhead','3mdoubletrough','3mdoubletrough-2'};

%sectionfilename={'repeat_3msouthtroughyoyosite'};

%sectionfilename={'all_inshore_of_sill'};

%sectionfilename={'repeat_3msouthtroughyoyoonly'}

%sectionfilename={'repeat_3micefrontsouthyoyoonly','repeat_3micefrontnorthyoyoonly','repeat_3msouthtroughyoyoonly','repeat_3msillsouthpeakyoyoonly','repeat_3mmouth'};

%sectionfilename={'3micefrontnorth-fjord2'}; 

%sectionfilename={'repeat_3micefrontnorthyoyoplus'};
sectionfilename={'quick_comp'};

grey  = [0.55 0.55 0.55];

alpha = 0.6;



for m=1:length(sectionfilename)
    ctds_times=[];
    cast_number=[];
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
    if c_jet
        cmap=jet(ncolours);
    else
        cmap=flipud(cmocean('phase',ncolours));
    end

    tidestep=1/(ncolours-1);
    tidebounds=[0:tidestep:1];

    theta=0:1:360;
    press_at_TC=NaN(size(ncasts));
     press_at_iso=NaN(size(ncasts));
    tidal_phase_idealised=NaN(size(ncasts));
    tidal_height=NaN(size(ncasts));
    tidal_speed=NaN(size(ncasts));
    %% loop the sections, now plotting
    for ii=1:ncasts
        line_style='-';

        ctd_time=datetime(ctds_n(ii).gtime);
        ctds_times=[ctds_times ctd_time];
        cast_number=[cast_number P.sectionlist(ii)];

        %Calculate the depth at which temp=TC for each cast:
        TC=-0.2;
        temp_below=80/2;
       % all_sigma0 = [ctds_n.sigma0];
      %  max_sigma0 = max(all_sigma0);
        max_common_sigma0 = min(arrayfun(@(x) max(x.sigma0), ctds_n));
        %isopycnal_level= max_common_sigma0;
        isopycnal_level= 26.3;
        iso_below=1;
        % For the isotherm:
        [~,index_TC]=min(abs(ctds_n(ii).Ctemp(temp_below:end) - (TC)));
        index_TC=index_TC+temp_below-1;
        ctds_n(ii).Ctemp(index_TC);
        press_at_TC(ii)=ctds_n(ii).press(index_TC);
        tidal_phase_idealised(ii)=ctds_n(ii).tide_phase_fraction*360;
        zh(ii)= ctds_n(ii).tide_height_zh;
        dzhdt(ii)= ctds_n(ii).tide_rising_rate_mpday;
        %
        [~,index_iso]=min(abs(ctds_n(ii).sigma0(iso_below:end) - (isopycnal_level)));
        index_iso=index_iso+iso_below-1;
        ctds_n(ii).sigma0(index_iso);
        press_at_iso(ii)=ctds_n(ii).press(index_iso);


    end

    if plot_casts_and_tides
        figure('Position', [100, 100, 1000, 600])
        for ii=1:ncasts
            cnumbertide=zeros(ncasts,1);
            for c=1:ncasts
                [junk,ind]=min(ctds_n(ii).tide_phase_fraction>tidebounds);
                cnumbertide(c)=ind;
            end

            ax=gobjects(1,2);
            orient landscape
            ax(1)=subplot(2,3,[1,4]);
            set(gca,'ydir','reverse','xaxislocation','top')
            box on
            hold on
            ylabel(gca,'Pressure (dbar)')
            xlabel('\theta (^oC)')
            xlim([-1.5 1.5])
            ylim([0 275])

            grid on
            set(ax(1),'XTick',-5:0.5:5.0);
            h=plot(ctds_n(ii).Ctemp,ctds_n(ii).press,'Color',[cmap(cnumbertide(ii),:) alpha],'LineWidth',2,'LineStyle',line_style);


            ax(3)=subplot(2,3,[2,5]);
            set(ax(3),'XTick',-10:1:100);
            set(gca,'ydir','reverse','xaxislocation','top')
            box on
            xlabel('Salinity');
            ylabel(gca,'Pressure (dbar)')
            xlim([28 36])
            ylim([0 275])
            h=plot(ctds_n(ii).asalin,ctds_n(ii).press,'Color',[cmap(cnumbertide(ii),:) alpha],'LineWidth',2);
            grid on;
            hold on;
            %

            subplot(2,3,[2,5])
            labels = string(ctds_times) + " (" + string(cast_number) + ")";
            legend(labels,'Location','southwest','FontSize',8);

            set(gcf, 'Color', 'w');

            ax(5)=subplot(2,3,3);
            h=plot(ctds_n(ii).asalin,ctds_n(ii).Ctemp, 'Color',[cmap(cnumbertide(ii),:) alpha],'LineWidth',1.5,'LineStyle',':');
            hold on
            xlabel('Salinity')
            ylabel('\theta (^oC)')

            grid on

            % add density contours
            thetaTS=[-1.5:0.1:2.0];
            s=[28:0.5:35];

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

            if plot_isopycnal
                ax(4)=subplot(2,3,6);
                yyaxis left
                plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
                hold on
                plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
                xlabel('Idealised tidal phase');
                ylabel(gca,'Illustrative tidal wave');
                title("CTDs timings in tidal cycle ")
                yyaxis right
                plot(tidal_phase_idealised(ii)/360,press_at_iso(ii),'Marker','+','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
                hold on
                ylabel(gca,'Isopycnal depth');
                xlim([0 1]);

            else
            ax(4)=subplot(2,3,6);
            yyaxis left
            plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
            xlabel('Idealised tidal phase');
            ylabel(gca,'Illustrative tidal wave');
            title("CTDs timings in tidal cycle ")
            yyaxis right
            plot(tidal_phase_idealised(ii)/360,press_at_TC(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            ylabel(gca,'Isotherm depth');
            xlim([0 1]);
            %ylim([75 115]);

            end
        end

        snap = [];
        for ii = 2:length(tidal_phase_idealised)
            if isempty(snap) && (tidal_phase_idealised(ii)/360) < (tidal_phase_idealised(ii-1)/360)
                snap = ii - 1;
            end
        end
if isempty(snap)
snap=ncasts;
end

        subplot(2,3,6)
        if plot_isopycnal
        plot(tidal_phase_idealised(1:snap)/360,press_at_iso(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
        plot(tidal_phase_idealised(snap+1:end)/360,press_at_iso(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        else
            plot(tidal_phase_idealised(1:snap)/360,press_at_TC(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
            plot(tidal_phase_idealised(snap+1:end)/360,press_at_TC(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        end

        %  plot(tidal_phase_idealised(7:end)/360,press_at_TC(7:12),'LineWidth', 1.5,'Color','k','Marker','none');
        %  ylim([min(press_at_TC)-5 min(press_at_TC)+5]);

        name = sprintf('_ctd_casts_tides_%s.png', sectionfilename{m});
        exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 200)
        % set(gca,'ydir','reverse','xaxislocation','top')

    end

    if plot_tide_metrics

        load([disk,'oceanography\VMADCP\virtual_mooring\virtualmooringdata_repeat_3micefrontsouthyoyoonly.mat']);

        figure('Position', [100, 100, 1200, 300]);

        for ii=1:ncasts
            cnumbertide=zeros(ncasts,1);
            for c=1:ncasts
                [junk,ind]=min(ctds_n(ii).tide_phase_fraction>tidebounds);
                cnumbertide(c)=ind;
            end

            % subplot(1,3,1)
            % %heat content
            % 
            % heatcontent = heat_content_layer(80,200,P.sectionlist,ctds);
            % yyaxis left
            % plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            % hold on
            % plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
            % xlabel('Idealised tidal phase');
            % ylabel(gca,'Illustrative tidal wave');
            % title("Heat content (J)")
            % %
            % yyaxis right
            % plot(tidal_phase_idealised(ii)/360,heatcontent.data(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            % ylabel(gca,'J');
            % hold on
            % xlim([0 1]);
            % 
            % %ylim([-180 180]);


            subplot(1,3,1)
            %isotherm depth
            yyaxis left
            plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
            xlabel('Idealised tidal phase');
            ylabel(gca,'Illustrative tidal wave');
            title("Heat content (J)")
            %
            yyaxis right
          %  plot(tidal_phase_idealised(ii)/360,virtualmooring.topanomang(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
          plot(tidal_phase_idealised(ii)/360,virtualmooring.heatcontent(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            ylabel(gca,'J');
            hold on
            xlim([0 1]);
                ylim([5.5e8 7.5e8]);
           % ylim([-180 180]);

            subplot(1,3,2)
            yyaxis left
            plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
            xlabel('Idealised tidal phase');
   %         ylabel(gca,'Illustrative tidal wave');
            title('Isotherm depth')
            %
            yyaxis right
            plot(tidal_phase_idealised(ii)/360,press_at_TC(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            ylabel(gca,'pressure at \theta =-0.2(^oC)');
            xlim([0 1]);
         

            subplot(1,3,3)
            yyaxis left
            plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            plot(theta/360,cosd(theta),'k-','LineWidth',1.5);
            xlabel('Idealised tidal phase');
      %      ylabel(gca,'Illustrative tidal wave');
            title('Isopycnal depth')
            %
            yyaxis right
            plot(tidal_phase_idealised(ii)/360,press_at_iso(ii),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5);
            hold on
            ylabel(gca,'pressure at \sigma =26.3');
            xlim([0 1]);

        end

        snap = [];
        for ii = 2:length(tidal_phase_idealised)
            if isempty(snap) && (tidal_phase_idealised(ii)/360) < (tidal_phase_idealised(ii-1)/360)
                snap = ii - 1;
            end
        end
        if isempty(snap)
            snap=ncasts;
        end

        % subplot(1,3,1)
        % %[junk tides_index]=sort(tidal_phase_idealised);
        % %plot(tidal_phase_idealised(tides_index)/360,virtualmooring.topanomang(tides_index),'LineWidth', 1.5,'Color','k','Marker','none');
        % %
        % plot(tidal_phase_idealised(1:snap)/360,heatcontent.data(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
        % plot(tidal_phase_idealised(snap+1:end)/360,heatcontent.data(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        % %
        subplot(1,3,1)
        %[junk tides_index]=sort(tidal_phase_idealised);
        %plot(tidal_phase_idealised(tides_index)/360,virtualmooring.topanomang(tides_index),'LineWidth', 1.5,'Color','k','Marker','none');
        %
        plot(tidal_phase_idealised(1:snap)/360,virtualmooring.heatcontent(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
        plot(tidal_phase_idealised(snap+1:end)/360,virtualmooring.heatcontent(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        subplot(1,3,2)
        plot(tidal_phase_idealised(1:snap)/360,press_at_TC(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
        plot(tidal_phase_idealised(snap+1:end)/360,press_at_TC(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        %
        subplot(1,3,3)
        plot(tidal_phase_idealised(1:snap)/360,press_at_iso(1:snap),'LineWidth', 1.5,'Color','k','Marker','none');
        plot(tidal_phase_idealised(snap+1:end)/360,press_at_iso(snap+1:end),'LineWidth', 1.5,'Color','k','Marker','none');
        %[junk tides_index]=sort(tidal_phase_idealised);

        %plot(tidal_phase_idealised(tides_index)/360,press_at_TC(tides_index),'LineWidth', 1.5,'Color','k','Marker','none');

      %  title(sprintf(sectionfilename{1}))

        set(gcf, 'Color', 'w');

        name = sprintf('ctds_tides_metrics_%s.png', sectionfilename{1});
        exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 300)

    end
end

%linkaxes(findall(gcf,'Type','axes'),'x');

