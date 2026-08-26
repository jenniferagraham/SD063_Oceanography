function [ycurrent] = interactive_edit(x,y,pres)

%HJV 03/09 Removed 'final version looks like this' as the figure 3 'zoom'
%plot does that

ytemp = y;
prestemp=pres;
ycurrent = ytemp;
lc=0;
blim=0;
useb=0;
xlimin=[];
ylimin=[];
stopcode = 0;

close all;

while stopcode ~= 1
    
    iip=pres<1;  %to show near surface
    
    
    lc =lc+1;
    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    plot(x,ycurrent,'k.','markersize',6); hold on
    plot(x(iip),ycurrent(iip),'g.','markersize',6);
    
    if blim>0&useb==1
        axis([xlimin(1) xlimin(2) ylimin(1) ylimin(2)]);  %use figure 3 axes as makeshift zoom
    end
    hold on;
    v = axis;
    if lc==1
        v1=v;
    end
    xextent = v(2) - v(1);
    yextent = v(4) - v(3);
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    
    disp('Click top left and bottom right of points to remove')
    figure(h);
    [xlimit,ylimit] = ginput(2);
    if length(xlimit)>1
    if xlimit(2)<xlimit(1)   %in case first click doesn't work
        xlimit=flipud(xlimit);
        ylimit=flipud(ylimit);
    end
    % plot without selected points...
    selected = find(x>xlimit(1) & x<xlimit(2) & ytemp<ylimit(1) ...
        & ytemp>ylimit(2));
    ytemp(selected) = NaN;
    prestemp(selected)=NaN;
    pressel=pres(selected);
    presmax=max(pressel);
    presmin=min(pressel);
    h2 = figure(2);
    set(h2,'position',[10 300 1000 400]);
    clf; % necessary after first edit...
    plot(x,ytemp,'k.','markersize',6)
    hold on;
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    plot([xlimit(1) xlimit(1) xlimit(2) xlimit(2) xlimit(1)], ...
        [ylimit(1) ylimit(2) ylimit(2) ylimit(1) ylimit(1)],'k--');
    NUMSEL=num2str(length(selected));
    disp(['',NUMSEL,' points selected'])
    PRESMIN=num2str(presmin);
    PRESMAX=num2str(presmax);
    disp(['max pressure of selected points: ',PRESMAX,''])
    disp(['min pressure of selected points: ',PRESMIN,''])
    acceptcode = input('Accept edits? (y = 1 / n = 0)\n');
    if acceptcode == 1
        ycurrent = ytemp;
    end
    end
    ytemp = ycurrent;
    h3 = figure(3);
    plot(x,ytemp,'k.','markersize',6); hold on
    plot(x(iip),ytemp(iip),'g.','markersize',6); hold off
    v3=axis;
    xextent = v3(2) - v3(1);
    yextent = v3(4) - v3(3);
    axis([v3(1)-xextent/20 v3(2)+xextent/20 v3(3)-yextent/20 v3(4)+yextent/20]);
    stopcode = input('Finished editing? (y = 1 / n = 0)\n');
    if isempty(stopcode)   %so default is to continue
        stopcode=0;
    end
    if stopcode~=1&stopcode~=2
        figure(3);
        drawnow;
        axischeck=input('New axis range for figure 1 selected on figure 3?');
        figure(3)
        v3=axis;
        xlimin=[v3(1) v3(2)];
        ylimin=[v3(3) v3(4)];
        blim=1;
    elseif stopcode==2
        %this should use the old axes limits
        blim=1;
        close
    else
        blim=0;
    end
    if isempty (xlimin)
        useb=0;
    else
        useb=1;
    end
    figure(1)
    close
    %         close(h2);
    %     close(h);
    %  close(h3);
end

% 'Final version looks like this...'
%     missing = find(isnan(ycurrent)~=1);
%
%     h = figure;
%     set(h,'position',[10 300 1000 400]);
%     plot(x,y,'k.','markersize',6);
%     hold on
%     plot(x,ycurrent,'r.','markersize',6);
%
%     axis([v1(1)-xextent/20 v1(2)+xextent/20 v1(3)-yextent/20 v1(4)+yextent/20]); %original axes
%     title('Black = original points discarded; Red = kept');
%
%     h2 = figure(2);
%     set(h2,'position',[10 300 1000 400]);
%      plot(x,ycurrent,'r.','markersize',4);  %to create desired axis
%       v = axis;
%     xextent = v(2) - v(1);
%     yextent = v(4) - v(3);
%     plot(x,y,'k.','markersize',4);
%
%     hold on
%     plot(x,ycurrent,'r.','markersize',4);
%     title('Black = original points discarded; Red = kept');
%     user_entry=input('hit return...');

%    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);  %axes for new profile

