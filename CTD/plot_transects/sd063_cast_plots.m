function break_loop=sd063_cast_plots(ctds,color_set,ref_station,plot_envelope)


if nargin<4
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
        xlim([-1.5 2.0])
        grid on
        set(ax(1),'XTick',-5:0.5:5.0);   

        %if it has a ref_station, it plots anomalies instead of
        %temps/salins...
        if ~isempty(ref_station)
        h=plot(ctds.Ctemp-ctds_ref.Ctemp,ctds.press,'Color',color_set,'LineWidth',2);
        elseif plot_envelope
        h=plot(ctds.Ctemp_mean,ctds.pressS,'Color',color_set,'LineWidth',2);
        else
        h=plot(ctds.Ctemp,ctds.press,'Color',color_set,'LineWidth',2);
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
   
    % file=fullfile(dir_plots,['CTDts',ctds,'.png']);
    % print('-dpng','-r300',file)
    
    %  close all
    end
if nargout>0
    break_loop=false;
end
end


function color_out=lighten_color(h_in)
    color_out=.6+get(h_in,'color').*.4;
end