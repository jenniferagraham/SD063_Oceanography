function break_loop=sd063_cast_plots_Chl(aaa,color_set)

disk = ['L:\work\scientific_work_areas\oceanography\'];
ctddata = [disk,'CTD\BASproc\'];
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

ctds=ctds(aaa);

    ax=gobjects(1,2);
    for i=1
        figure(1)
        orient landscape
        ax(1)=subplot(1,4,1);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        ylabel(gca,'Pressure (dbar)')
        xlabel('PAR (log10)')
        grid on
        %set(ax(1),'XTick',-0.15:0.05:0.15);   
        h=plot(log10(ctds.par),ctds.press,'Color',color_set,'LineWidth',2);

       % legend(string(datetime(ctds.gtime)),'Location','SouthEast')

        ax(2)=subplot(1,4,2);
        %set(ax(2),'XTick',-0.15:0.05:0.15);   
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        xlabel('Chl (log10 ug/L)')
        h=plot(log10(ctds.fluor_ug_l),ctds.press,'Color',color_set,'LineWidth',2);
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
            TITLE=['CTD ',ctds_title,' top ',num2str(shallow),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDSURFuv',ctds,'.png']);
            print('-dpng','-r300',file)
            hold on
            
        elseif i==3
            deep=150;
            ylim(ax,[max(ctds.press)-deep max(ctds.press)+2])
            legend (ax(2),'off');
            TITLE=['CTD ',ctds_title,' bottom ',num2str(deep),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDBOTTuv',aaa,'.png']);
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

    ax(3)=subplot(1,4,3:4);
    h=plot(ctds.asalin,ctds.Ctemp,'Color',color_set,'LineStyle', ':',...
        'LineWidth',0.2, 'Marker','square');
    hold on
    xlabel('CT')
    ylabel('SA')

   grid on 
    set(ax(3),'XTick',26:0.5:35);     
   
    % file=fullfile(dir_plots,['CTDts',ctds,'.png']);
    % print('-dpng','-r300',file)
    
    %  close all
    
if nargout>0
    break_loop=false;
end
end


function color_out=lighten_color(h_in)
    color_out=.6+get(h_in,'color').*.4;
end