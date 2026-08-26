function [ycleaned] = interactive_edit_poly(x, y, pres, varargin)
% INTERACTIVE_EDIT_POLY allows interactive selection and removal of points
% from a dataset. Users draw a polygon around points to be removed, and the
% script iterates until the user confirms the edits.

% script provided by Hugh Venables and edited by Kat Turner to work on
% SD046

% Initialize variables
ycleaned = y;
ytemp = y;
flowtemp = pres;
lc=0;
blim=0;
useb=0;
xlimin=[];
ylimin=[];
stopcode = 0;
close all;

while stopcode ~= 1
    lc =lc+1;

    % Plot dataset
    figure(1);
    set(gcf, 'Position', [10 300 1000 400]);
    a = plot(x, ycleaned, 'k.', 'MarkerSize', 6);
    set(a,'DisplayName',varargin{:});
    title(varargin)
    hold on;

    % Highlight points where pres < 1
    low_flow = pres < 700;
    b=plot(x(low_flow), ycleaned(low_flow), 'r.', 'MarkerSize', 6);
    set(b,'DisplayName','flow < 0.7L/min');
    
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

    % Set points within the polygon to NaN
    ytemp(selected) = NaN;
    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    clf;
    plot(x,ytemp,'k.','markersize',10);
    hold on;
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);   

    NUMSEL=num2str(length(find(selected>0)));
    disp(['',NUMSEL,' points selected'])
    
    flowtemp(selected)=NaN;
    pressel=pres(selected);
    presmax=max(pressel);
    presmin=min(pressel);
    PRESMIN=num2str(presmin);
    PRESMAX=num2str(presmax);
    disp(['max pressure of selected points: ',PRESMAX,''])
    disp(['min pressure of selected points: ',PRESMIN,''])    
    acceptcode=say_what(input('Accept these edits (y = 1 / n = 0)? ','s'));
    
    if acceptcode == 1
        ycleaned = ytemp;
    end
    ytemp = ycleaned;
        
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