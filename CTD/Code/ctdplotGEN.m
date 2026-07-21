function break_loop=ctdplotGEN(aaa)

%assumes basic variables exist, choice of more to plot, selected in
%CTDvarn as ctd_plot 1:n

if nargin<1
    aaa=input('Station number?\n','s');
elseif ~ischar(aaa)
    aaa=num2str(aaa);
end
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];

    CTDvarn

if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(find(CastEvent(:,1)==aac),2);
eee=num2str(eec,'%03d');
else 
    eee=input('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n','s');  %new cast
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end

padzeros=max([3-length(eee),4-strfind(eee,'.')]);
eee=[repmat('0',1,padzeros),eee];
eee(eee=='.')=[];
eee=['_',eee,];
end

    infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_cal_2db.mat']);
    if ~exist(infile,'file')
        infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_2db.mat']);
    end
    dn=load(infile,'-mat');
    infile_up=[infile(1:end-4),'_up.mat'];
    up=load(infile_up,'-mat');
    disp (['Plotting ',infile,' and ',infile_up])
    
    if ~exist(dir_plots,'dir')
        mkdir(dir_plots);
    end
    
    close all

    aaa_title=strrep(aaa,'_','\_'); % escape any underscores in title
    
    ax=gobjects(1,3);
    for i=1:3
        figure(i)
        orient landscape
        ax(1)=subplot(131);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        ylabel(gca,'Pressure (dbar)')
        xlabel('\theta (^oC)')
        h=plot(dn.potemp1,dn.press,'k','LineWidth',2);
        plot(up.potemp1,up.press,'LineWidth',2,'color',lighten_color(h));
        if isfield(dn,'potemp2')
            h(2)=plot(dn.potemp2,dn.press,'g','LineWidth',2);
            plot(up.potemp2,up.press,'LineWidth',2,'color',lighten_color(h(2)));
        end
        
        ax(2)=subplot(132);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        xlabel('Salinity')
        h=plot(dn.salin1,dn.press,'k','LineWidth',2);
        plot(up.salin1,up.press,'LineWidth',2,'color',lighten_color(h));
        if isfield(dn,'salin2')
            h(2)=plot(dn.salin2,dn.press,'g','LineWidth',2);
            plot(up.salin2,up.press,'LineWidth',2,'color',lighten_color(h(2)));
            legend(h,{'1','2'},'location','southwest')
        end

        ax(3)=subplot(133);
        set(gca,'ydir','reverse','xaxislocation','top')
        box on
        hold on
        xlabel('\sigma_0 (kg m^{-3})')
        h=plot(dn.sigma0,dn.press,'k','LineWidth',2);
        plot(up.sigma0,up.press,'LineWidth',2,'color',lighten_color(h));

        if i==1
            TITLE=['CTD ',aaa_title,''];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            
            file=fullfile(dir_plots,['CTDtsd',aaa,'.png']);
            print('-dpng','-r300',file)
            
        elseif i==2
            shallow=200;
            ylim(ax,[0 shallow]);
            TITLE=['CTD ',aaa_title,' top ',num2str(shallow),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDSURFtsd',aaa,'.png']);
            print('-dpng','-r300',file)
            
        elseif i==3
            deep=150;
            ylim(ax,[max(dn.press)-deep max(dn.press)+2])
            legend (ax(2),'off');
            TITLE=['CTD ',aaa_title,' bottom ',num2str(deep),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDBOTTtsd',aaa,'.png']);
            print('-dpng','-r300',file)
        end
    end
    
    iic=find(strcmp(columnuse,'ctd_plot'));
    iiu=find(strcmp(columnuse,'plot_title'));
    
    sv=size(varnames);
    vpp=zeros(sv(1),1);
    for iv=1:sv(1)
        vpp(iv)=varnames{iv,iic}*((varnames{iv,2}*varnames{iv,iic})>0);
    end
    
    colorsequence='kgm';
    for i=4:6
        figure(i)
        orient landscape
        nfigs=max(vpp);

        ax=gobjects(1,nfigs);
        for j=1:nfigs

            ax(j)=subplot(1,nfigs,j);
            set(gca,'ydir','reverse','xaxislocation','top')
            box on
            hold on
            if j==1
                ylabel(gca,'Pressure (dbar)')
            end
            
            ivp=find(vpp==j);
            thelabel=varnames{ivp(1),iiu};
            if numel(ivp)>1
                thelabel=[thelabel,sprintf('\n%s',varnames{ivp(2:end),iiu})];
            end
            xlabel(thelabel)
            h=gobjects(1,length(ivp));
            for k=1:length(ivp)
                h(k)=plot(dn.(varnames{ivp(k),1}),dn.press,'color',colorsequence(k),'LineWidth',2);
                plot(up.(varnames{ivp(k),1}),up.press,'color',lighten_color(h(k)),'LineWidth',2);
            end

        end
        
        if i==4
            TITLE=['CTD ',aaa_title,''];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            
            file=fullfile(dir_plots,['CTDftop',aaa,'.png']);
            print('-dpng','-r300',file)
        elseif i==5
            shallow=200;
            ylim(ax,[0 shallow])
            TITLE=['CTD ',aaa_title,' top 200m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDSURFftop',aaa,'.png']);
            print('-dpng','-r300',file)
            
        elseif i==6
            deep=150;
            ylim(ax,[max(dn.press)-deep max(dn.press)+2])
            TITLE=['CTD ',aaa_title,' bottom ',num2str(deep),'m'];
            h=suptitle(TITLE);
            set(h,'fontsize',16)
            file=fullfile(dir_plots,['CTDBOTTftop',aaa,'.png']);
            print('-dpng','-r300',file)
        end
    end
    
    figure(7)
    h=plot(dn.salin1,dn.potemp1,'k','LineWidth',2);
    hold on
    plot(up.salin1,up.potemp1,'color',lighten_color(h),'LineWidth',2)
    if isfield(dn,'potemp2')
        h(2)=plot(dn.salin2,dn.potemp2,'g','LineWidth',2);
        plot(up.salin2,up.potemp2,'color',lighten_color(h(2)),'LineWidth',2);
        legend(h,{'1','2'},'location','northwest')
    end
    xlabel('Salinity')
    ylabel('\theta (^oC)')
    TITLE=['CTD ',aaa_title,' \theta/S'];
    title(TITLE)
    file=fullfile(dir_plots,['CTDts',aaa,'.png']);
    print('-dpng','-r300',file)
    
    %  close all
    
if nargout>0
    break_loop=false;
end
end


function color_out=lighten_color(h_in)
    color_out=.6+get(h_in,'color').*.4;
end