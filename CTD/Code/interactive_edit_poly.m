function [ycurrent] = interactive_edit_poly(x,y,pres, varname)

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

close all

stopcode = 0;
while stopcode ~= 1
lc =lc+1;


    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    plot(x,ycurrent,'k.','markersize',6);
    title(varname)
    hold on;
    
     if blim>0&useb==1
        axis([xlimin(1) xlimin(2) ylimin(1) ylimin(2)]);  %use figure 3 axes as makeshift zoom
    end
    
    v = axis;
    xextent = v(2) - v(1);
    yextent = v(4) - v(3);
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    
    %% Inpolygon funciton
    
    % Initially, the list of points is empty.
    xy = [];
    n = 0;

    % Loop, picking up the points.
    disp('Left mouse button picks points.')
    disp('Right mouse button picks last point.')
    but = 1;
    while but == 1
        [xi,yi,but] = ginput(1);
        if isempty(xi)
            break;
        end
        plot(xi,yi,'ro')
        n = n+1;
        xy(n,:) = [xi yi];
        if n > 1
            plot(xy(:,1),xy(:,2),'g')
        end
    end

    % select points inside the polygon
    selected = inpolygon(x,ytemp,xy(:,1),xy(:,2));
    plot([xy(:,1);xy(1,1)], [xy(:,2); xy(1,2)],'r')

    plot(x(selected),ytemp(selected),'r.')
    
    %% end of inpolygon funciton

% 'Click top left and bottom right of points to remove'
% 
%     [xlimit,ylimit] = ginput(2);
%       if xlimit(2)<xlimit(1)   %in case first click doesn't work
%        xlimit=flipud(xlimit)
%        ylimit=flipud(ylimit)
%     end
%     close(1);
%     
%     % plot without selected points...
%     selected = find(x>xlimit(1) & x<xlimit(2) & ytemp<ylimit(1) ...
%         & ytemp>ylimit(2));

    % Set points within the polygon to NaN
    ytemp(selected) = NaN;
    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    clf;
    plot(x,ytemp,'k.','markersize',10);
    hold on;
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    %plot([xlimit(1) xlimit(1) xlimit(2) xlimit(2) xlimit(1)], ...
        %[ylimit(1) ylimit(2) ylimit(2) ylimit(1) ylimit(1)],'k--');   

    NUMSEL=num2str(length(find(selected>0)));
    disp(['',NUMSEL,' points selected'])
    
    prestemp(selected)=NaN;
    pressel=pres(selected);
    presmax=max(pressel);
    presmin=min(pressel);
    PRESMIN=num2str(presmin);
    PRESMAX=num2str(presmax);
    disp(['max pressure of selected points: ',PRESMAX,''])
    disp(['min pressure of selected points: ',PRESMIN,''])    
    acceptcode=say_what(input('Accept these edits (y = 1 / n = 0)? ','s'));
   
    if acceptcode == 1
        ycurrent = ytemp;
    end
    ytemp = ycurrent;
        
    h3 = figure(3);
    hold off
    plot(x,ytemp,'k.','markersize',6);

    v3=axis;
    xextent = v3(2) - v3(1);
    yextent = v3(4) - v3(3);
    axis([v3(1)-xextent/20 v3(2)+xextent/20 v3(3)-yextent/20 v3(4)+yextent/20]);
    
    stopcode=say_what(input('Finished editing (y = 1 / n = 0)? ','s'));

    if stopcode==0
        figure(3);
        drawnow;
        axischeck=input('New axis range for figure 1 selected on figure 3?');
        figure(3);
        v3=axis;
        xlimin=[v3(1) v3(2)];
        ylimin=[v3(3) v3(4)];
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
    
    close(1);
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
  
    