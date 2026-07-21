function [ycurrent] = interactive_edit(x,y,pres);

ytemp = y;
ycurrent = ytemp;
lc=0;
blim=0;
useb=0;
xlimin=[];
ylimin=[];
stopcode = 0;

while stopcode ~= 1;
    
    
lc =lc+1;
    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    plot(x,ycurrent,'k.','markersize',6);

    if blim>0&useb==1
        axis([xlimin(1) xlimin(2) ylimin(1) ylimin(2)]);
    end
    hold on;
    v = axis;
    if lc==1
    v1=v;
    end
    xextent = v(2) - v(1);
    yextent = v(4) - v(3);
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);

'Click top left and bottom right of points to remove'

    [xlimit,ylimit] = ginput(2);
    
 if xlimit(2)<xlimit(1)  %in case first click doesn't work
      xlimit=flipud(xlimit);
      ylimit=flipud(ylimit);
    end
    % plot without selected points...
    selected = find(x>xlimit(1) & x<xlimit(2) & ytemp<ylimit(1) ...
        & ytemp>ylimit(2));
    ytemp(selected) = NaN;
    pressel=pres(selected);
    presmax=max(pressel);
    presmin=min(pressel);
    h2 = figure(2);
    set(h2,'position',[10 300 1000 400]);
    plot(x,ytemp,'k.','markersize',6)
    hold on;
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    plot([xlimit(1) xlimit(1) xlimit(2) xlimit(2) xlimit(1)], ...
        [ylimit(1) ylimit(2) ylimit(2) ylimit(1) ylimit(1)],'k--');   
    NUMSEL=num2str(length(selected));
    PRESMIN=num2str(presmin);
    PRESMAX=num2str(presmax);
disp(['',NUMSEL,' points selected'])
disp(['max pressure of selected points: ',PRESMAX,''])
disp(['min pressure of selected points: ',PRESMIN,''])
    acceptcode = input('Accept edits? (y = 1 / n = 0)\n');
    if acceptcode == 1;
        ycurrent = ytemp;
    end;
        ytemp = ycurrent;
         h3 = figure(3);
    plot(x,ycurrent,'k.','markersize',6);

    
    stopcode = input('Finished editing? (y = 1 / n = 0)\n');
    if isempty(stopcode)   %so default is to continue
stopcode=0;
end
     if stopcode~=1
        axischeck=input('New axis range for figure 1 selected on figure 3?'); 
       figure(3)
    v3=axis;
        xlimin=[v3(1) v3(2)];
        ylimin=[v3(3) v3(4)];
        blim=1;
    else
        blim=0;
    end
    if isempty (xlimin)
        useb=0;
    else
        useb=1;
    end
        close(h2);
    close(h);
    close(h3);
end;

%'Final version looks like this...'
    missing = find(isnan(ycurrent)~=1);
    y2 = interp1(x(missing),ycurrent(missing),x);    
    
%     h2 = figure(4);
%     set(h2,'position',[10 300 1000 400]);
%     plot(x,y,'k.','markersize',4);
%     hold on
%     plot(x,y2,'g.','markersize',4);
%     plot(x,ycurrent,'r.','markersize',4);
%     title('Black = original points discarded; Red = kept; Green = interpolated');
%     user_entry=input('hit return...');
%     
%     axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
%   
%     
    
