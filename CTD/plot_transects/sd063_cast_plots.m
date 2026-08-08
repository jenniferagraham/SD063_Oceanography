function break_loop=sd063_cast_plots(ctds,color_set,line_style,ref_station,plot_envelope)


if nargin<5
    ref_station=[];
end

    ax=gobjects(1,2);
    for i=1
        figure(1)
        orient landscape
        ax(1)=subplot(1,4,1);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        ylabel(gca,'Pressure (dbar)')
        xlabel('\theta (^oC)')
        xlim([-2.0 4.5])
        grid on
        set(ax(1),'XTick',-5:0.5:5.0);   

        %if it has a ref_station, it plots anomalies instead of
        %temps/salins...
        if ~isempty(ref_station)
        h=plot(ctds.Ctemp-ctds_ref.Ctemp,ctds.press,'Color',color_set,'LineWidth',2,'LineStyle',line_style);
        elseif plot_envelope
        h=plot(ctds.Ctemp_mean,ctds.pressS,'Color',color_set,'LineWidth',2,'LineStyle',line_style);
        else
        h=plot(ctds.Ctemp,ctds.press,'Color',color_set,'LineWidth',2,'LineStyle',line_style);
        end

       % legend(string(datetime(ctds.gtime)),'Location','SouthEast')

        ax(2)=subplot(1,4,2);
        set(ax(2),'XTick',-10:1:100);   
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        xlabel('Salinity')
         xlim([28 36])
        if ~isempty(ref_station)
       h=plot(ctds.asalin-ctds_ref.asalin,ctds.press,'Color',color_set,'LineWidth',2);
        elseif plot_envelope
              h=plot(ctds.asalin_mean,ctds.pressS,'Color',color_set,'LineWidth',2);
        else
        h=plot(ctds.asalin,ctds.press,'Color',color_set,'LineWidth',2);
        end
       % h=plot(ctds.asalin,ctds.press,'Color',color_set,'LineWidth',2);
        grid on


        if i==1
          %  TITLE=['CTD ',ctds_title,''];
           % h=suptitle(TITLE);
         %   set(h,'fontsize',16)
            
      %       file=fullfile(dir_plots,['CTDtsd',aaa,'.png']);
       %     print('-dpng','-r300',file)
            hold on
            
        elseif i==2
            shallow=200;
            ylim(ax,[0 shallow]);
            TITLE=['CTD ',ctds_tiitle,' top ',num2str(shallow),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDSURFtsd',ctds,'.png']);
            print('-dpng','-r300',file)
            hold on
            
        elseif i==3
            deep=150;
            ylim(ax,[max(ctds.press)-deep max(ctds.press)+2])
            legend (ax(2),'off');
            TITLE=['CTD ',ctds_title,' bottom ',num2str(deep),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDBOTTtsd',aaa,'.png']);
            print('-dpng','-r300',file)
        end
    end
    
 %   iic=find(strcmp(columnuse,'ctd_plot'));
 %   iiu=find(strcmp(columnuse,'plot_title'));
    
    % sv=size(varnames);
    % vpp=zeros(sv(1),1);
    % for iv=1:sv(1)
    %     vpp(iv)=varnames{iv,iic}*((varnames{iv,2}*varnames{iv,iic})>0);
    % end
    
    colorsequence='kgm';

    if plot_envelope
    else
    ax(3)=subplot(1,4,3:4);
    h=plot(ctds.asalin,ctds.Ctemp,'Color',color_set,'LineStyle', ':','LineWidth',2);
    hold on
    xlabel('Salinity')
    ylabel('\theta (^oC)')

    grid on 
    set(ax(3),'XTick',0:1:100);     

    % add density contours 
    thetaTS=[-2:0.2:8];
    s=[28:0.5:36];

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
    [c,h]=contour(si,thetai,dens,[20:1:28],'k');
    clabel(c,h,'LabelSpacing',90);
    h.HandleVisibility = 'off';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % add the water masses LC
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FZ=12;   msize=20;
%     % I follow Rudels 2001 for all the definition, but I have made modifications to the density.
%     % Reduce it because on the shelf watermasses seem lighter
%     mysig0AWmin = 27.3; % adjusted from below 27.7 is Surface PW above it Arctic Atlantic Water
%     mysig0PW    = 26.5;      % adjusted from 27.7 to create an intermediate water mass between PW and AAW
%     mysig0AWmax = 29;   % adjusted from 27.97 above that likely Polar intermediate water
%     % plot water masses
%      PWt1    = [-1.1];  PWs1 = [32]; %
%      AWt1    = [2.5];  AWs1 = [34.8]; %
%      AWit1   = [-1.5];  AWis1 = [33.5]; % based on CTD16 this is AW modified by ice (sits exactly along the gade line) 
%      plot(AWs1, AWt1,'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
%      plot(PWs1 , PWt1, 'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
%      plot(AWis1 , AWit1, 'sk','markersize',msize,'MarkerEdgeColor','k','MarkerFaceColor','none')
%      text (AWs1+0.3, AWt1,'AW','FontSize',FZ)
%      text (AWis1-0.4,AWit1-0.4,'MAW','FontSize',FZ-1)
%      text (PWs1-0.5, PWt1+.8,'PW','FontSize',FZ)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    end
if nargout>0
    break_loop=false;
end
end


function color_out=lighten_color(h_in)
    color_out=.6+get(h_in,'color').*.4;
end