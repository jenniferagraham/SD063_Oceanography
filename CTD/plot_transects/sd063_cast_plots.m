%function used to plot cast data from CTD casts from SD063 cruise.

%Created by Rosie Williams, July 2026 on GIANT SD063.

function break_loop=sd063_cast_plots(ctds,color_set,line_style,ref_station,plot_envelope)


if nargin<5
    ref_station=[];
    plot_envelope=0;
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
    thetaTS=[-2:0.2:4];
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


    end
if nargout>0
    break_loop=false;
end
end


function color_out=lighten_color(h_in)
    color_out=.6+get(h_in,'color').*.4;
end