function edit_daily_bathy(daynumber,yy)
%EDIT_DAILY_BATHY Clean echo sounder data interactively
%
%   Interactively clean up singlebeam (EA500/EA600/EA640) or multibeam
%   centre-beam (EM120/EM122/EM712) data
%
%   version 0.1 - 200408 - Mike Meredith, CD160 - initial version?
%   version 0.2 - 200512 - Mike Meredith, JR139
%   version 0.3 - ?????? - Hugh Venables, JRvarious - improved interactive 
%     editor, changed to ea600
%   version 1.0 - 20220814 - Povl Abrahamsen, SD020 - updated for RVDAS, 
%     changed to EA640/EM122/EM712 for SDA
%   version 1.1 - 20230116 - Povl Abrahamsen, DY158 - generalised for use on
%     different ships using parameters specified in SET_UNDERWAY_PARAMETERS

if nargin<2
    dt_now = datetime('now'); 
    yy = year(dt_now);        
    jday_now = day(dt_now, 'dayofyear');

    if nargin<1
        fprintf(1,'Today''s jday number is %d.\n',jday_now);
        daynumber=input('Input jday number = ');
    end
end

set_underway_params

for q=1:length(bathy_sensor_sets)

fprintf(1,'Cleaning echo sounder %s:\n',bathy_sensor_sets(q).set_name_long);

close all
lc=0;
blim=0;
useb=0;
xlimin=[];
ylimin=[];

% spikesize = 5; % minimum size of spikes to remove
%                % (program runs again with spikesize/2 after interactive bit)

filename_orig=fullfile('..','bathy',bathy_sensor_sets(q).bathy_table,...
    sprintf('%s_%.2d%.3d.mat',bathy_sensor_sets(q).bathy_table,...
    mod(yy,100),daynumber));
filename_clean=fullfile('..','bathy',bathy_sensor_sets(q).bathy_table,...
    sprintf('%s_%.2d%.3d_clean.mat',bathy_sensor_sets(q).bathy_table,...
    mod(yy,100),daynumber));
if exist(filename_clean,'file')
    disp ('Cleaned file already exists. Do you want to continue editing or start over?')
    restart=input('Type "discard" to discard edits, otherwise press any other key','s');
    if isempty(restart) || ~strcmp(restart,'discard')
        load(filename_clean);
    else
        load(filename_orig);
    end
elseif exist(filename_orig,'file')
    load(filename_orig);
else
    fprintf('No data for %s on day %.2d%.3d\n',...
        bathy_sensor_sets(q).bathy_table,mod(yy,100),daynumber);
    continue;
end

if ~isempty(bathy_sensor_sets(q).depth_below_surface_field)
    depth_field=bathy_sensor_sets(q).depth_below_surface_field;
else
    depth_field=bathy_sensor_sets(q).depth_below_transducer_field;
end
clean_depth_field=[depth_field,'_clean'];
data=eval(bathy_sensor_sets(q).bathy_table);

if ~isfield(data,clean_depth_field)
    data.(clean_depth_field)=data.(depth_field);
end

% a little range-checking

figure(3)
hold on
% TO DO: do we want to plot the other bathymetry sources here?
% plot(multibeam_kongsberg_em712_kodpt.time_secs,...
%     multibeam_kongsberg_em712_kodpt.waterdepthmetrefromtransducer,...
%     'g-','LineWidth',2);
plot(data.time_secs,data.(clean_depth_field),'k-');


amin=input('Enter minimum valid depth (default 0)\n');
if isempty(amin)
    amin=0;
end
a = find(data.(clean_depth_field) <=amin);
data.(clean_depth_field)(a) = NaN;

amax=input('Enter maximum valid depth\n');
if isempty(amax)
    amax=15000;
end
a = find(data.(clean_depth_field) >amax);
data.(clean_depth_field)(a) = NaN;
% b = find(isnan(ea600.uncdepth_clean)~=1);  %hold off the interpolation,
% only just getting started
% ea600.uncdepth_clean = interp1q(ea600.time_secs(b),ea600.uncdepth_clean(b),ea600.time_secs);

x = data.time_secs;
y = data.(clean_depth_field);

% quick run through with dspike; %which doesn't really help as leaves parts
% of the spikes in

% ynew = dspike(y,spikesize);
%     missing = find(isnan(ynew)~=1);
%     ynew = interp1q(x(missing),ynew(missing),x); 
%     
% ytemp = ynew;
% ycurrent = ytemp;
ytemp=y;  %setting up polygon interactive editor, having pruned off top and bottom
ycurrent=y;

stopcode = 0;
while stopcode ~= 1
lc =lc+1;

    h = figure(1);
    set(h,'position',[10 200 1000 400]);
    plot(x,ycurrent,'k.','markersize',10);
    hold on;
%     plot(em122_kidpt.time_secs,...
%         em122_kidpt.waterdepthmetre,...
%         'b-','LineWidth',1); % NaNs if no swath data
%     plot(multibeam_kongsberg_em712_kodpt.time_secs,...
%         multibeam_kongsberg_em712_kodpt.waterdepthmetrefromtransducer,...
%         'g-','LineWidth',1); % NaNs if no swath data
    if blim>0&useb==1
        axis([xlimin(1) xlimin(2) ylimin(1) ylimin(2)]);  %use figure 3 axes as makeshift zoom
    end
    
    v = axis;
    xextent = v(2) - v(1);
    yextent = v(4) - v(3);
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    
    %% Inpolygon function
    
    % Initially, the list of points is empty.
    xy = [];
    n = 0;

    % Loop, picking up the points.
    disp('Left mouse button picks points.')
    disp('Right mouse button picks last point.')
    figure(1);
    but = 1;
    while but == 1
        [xi,yi,but] = ginput(1);
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
    
    %% end of inpolygon function

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

    NUMSEL=num2str(length(find(selected>0)));
    disp(['',NUMSEL,' points selected'])
    
    % Set points within the polygon to NaN
    ytemp(selected) = NaN;
    h = figure(1);
    set(h,'position',[10 300 1000 400]);
    plot(x,ytemp,'k.','markersize',10);
    hold on;
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
    %plot([xlimit(1) xlimit(1) xlimit(2) xlimit(2) xlimit(1)], ...
        %[ylimit(1) ylimit(2) ylimit(2) ylimit(1) ylimit(1)],'k--');   

%     acceptcode = menu('Accept these edits?','Okaaaaay','Youre avin a larf incha?!');
    acceptcode=say_what(input('Accept these edits? yes or no\n', 's'));

    % Change string to a number
    
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
    
%     stopcode = menu('Finished editing?','Yup, thats me done','Gimme more');
%     save(fileout,'ea640_sddpt');
    stopcode=say_what(input('Finished editing? yes or no\n', 's'));
    
    if isempty(stopcode)   %so default is to continue
        stopcode=0;
    end

    if stopcode~=1&stopcode~=2
        figure(3)
        drawnow;
        axischeck=input('New axis range for figure 1 selected on figure 3?');
        figure(3)
        v3=axis;
        xlimin=[v3(1) v3(2)];
        ylimin=[v3(3) v3(4)];
        blim=1;
        close
    elseif stopcode==2
        % this should use the old axes limits
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

close all

    disp('Final version looks like this...')
%     missing = find(isnan(ycurrent)~=1);
    y2 = ycurrent;% interp1q(x(missing),ycurrent(missing),x);   %HJV, if we don't know, we don't know 
    
    h2 = figure;
    set(h2,'position',[10 300 1000 400]);
    plot(x,y,'k.','markersize',2);
    hold on
    plot(x,y2,'b.','markersize',2);
    plot(x,ycurrent,'r.','markersize',2);
    title('Depths after interactive editing....');
    
    axis([v(1)-xextent/20 v(2)+xextent/20 v(3)-yextent/20 v(4)+yextent/20]);
  
    title('Black = original points discarded; Red = kept'); %; Blue = interpolated');
    
    
% another quick whizz with dspike
% y3 = dspike(y2,spikesize/2);
%     missing = find(isnan(y3)~=1);
    data.(clean_depth_field)=y2;%y3; % interp1q(ea600.time_secs(missing),y3(missing),ea600.time_secs); 
     
% % now 101-point median filter
% for i = 51:length(ea600.time_secs)-50;
% med = nanmedian(ea600.uncdepth_clean(i-50:i+50));
% if ea600.uncdepth_clean(i) > med+5 | ea600.uncdepth_clean(i) < med-5;
% ea600.uncdepth_clean(i) = nan;
% end;
% end;
   % missing = find(isnan(ea600.uncdepth_clean)~=1);
   % ea600.uncdepth_clean = interp1q(ea600.time_secs(missing),ea600.uncdepth_clean(missing),ea600.time_secs); 

figure;
plot(data.time_secs,data.(clean_depth_field),'k.','markersize',2);
title('Depths after dspiking...');

eval([bathy_sensor_sets(q).bathy_table,'=data;']);

save(filename_clean,bathy_sensor_sets(q).bathy_table);

fprintf(1,'Press enter to continue...\n');
pause

end

plot_daily_bathy(daynumber,yy);