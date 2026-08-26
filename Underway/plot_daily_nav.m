function plot_daily_nav(daynumber,yy,load_from_caller)
%PLOT_DAILY_NAV Plot daily navigation data from RVDAS
%
%   PLOT_DAILY_NAV (daynumber, year, load_from_caller)
%
%   Plots daily navigation data:
%     - map (with each GPS sensor set plotted)
%     - heading
%     - heave/pitch/roll
%
%   If you do not specify the year, the current year will be used. 
%   If you do not specify the day, you will be prompted for this.
%   The third parameter specifies whether to load data from the calling
%   function or from disk. If omitted, data will be loaded from disk.
%
%   version 1.0 - 20220818 - Povl Abrahamsen, SD020 - initial version
%   version 1.1 - 20230109 - Povl Abrahamsen, DY158 - generalised for use on
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

for n=1:length(nav_tables)
    if nargin>2 && load_from_caller
        data=evalin('caller',nav_tables{n});
        eval([nav_tables{n},'=data;']);
    else
        load(fullfile('..','nav',nav_tables{n},...
            strcat(nav_tables{n},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'.mat')));
    end
end


%%

figure('name',[' ',sprintf('%s/',nav_sensor_sets(1:end-1).set_name),...
    nav_sensor_sets(end).set_name,' position ',num2str(daynumber,'%03d')]);

for q=1:length(nav_sensor_sets)

    gga=eval(nav_sensor_sets(q).gga_table);
    lon_temp=gga.(nav_sensor_sets(q).gga_lon_field);
    lon_temp(lon_temp<-990)=nan;
    lat_temp=gga.(nav_sensor_sets(q).gga_lat_field);
    lat_temp(lat_temp<-990)=nan;

    if q==1
        linestyle='-';

     %   m_proj('mercator','lon',minmax(lon_temp(:)')+[-2 2],...
            %'lat',minmax(lat_temp(:)')+[-2 2]);
       m_proj('mercator','lon', [min(lon_temp(:)) max(lon_temp(:))] +[-2 2],...
            'lat', [min(lat_temp(:)) max(lat_temp(:))] +[-2 2]);
       
        hold on;
    else
        linestyle=':';
    end
    m_plot(lon_temp,lat_temp,linestyle);

end

m_gshhs_i('color','k');
m_gebco2022_contour([-2000 -2000],'c-');
m_gebco2022_contour([-4000 -4000],'b-');
m_grid;
xlabel Longitude
ylabel Latitude
%legend(gca,{'cruise track','coast','2000m','4000m'},'location','southeast')

%%
figure('name',[' ',sprintf('%s/',hpr_sensor_sets(1:end-1).set_name),...
    hpr_sensor_sets(end).set_name,' heading ',num2str(daynumber,'%03d')]);

hold on;

colors=get(gca,'ColorOrder');

for q=1:length(hpr_sensor_sets)
    
    if isempty(hpr_sensor_sets(q).hpr_heading_field)
        continue;
    end
    hpr=eval(hpr_sensor_sets(q).hpr_table);
    if isfield(hpr_sensor_sets(q),'hpr_scale_factor')
        hpr_scale=hpr_sensor_sets(q).hpr_scale_factor;
    else
        hpr_scale=1;
    end
    plot(datetime(hpr.time, "ConvertFrom","datenum"),hpr.(hpr_sensor_sets(q).hpr_heading_field).*hpr_scale,...
        'color',colors(q,:),'DisplayName',hpr_sensor_sets(q).set_name);

end

set(gca,'ylim',[0 360],'ytick',0:45:360);
legend('location','best');
xlabel('Completed JDAYs since turn of year');
ylabel Heading

%%
figure('name',[' ',sprintf('%s/',hpr_sensor_sets(1:end-1).set_name),...
    hpr_sensor_sets(end).set_name,' HPR ',num2str(daynumber,'%03d')]);
orient tall
ax=subplot(3,1,1);
hold on;
ylabel Heave

ax(2)=subplot(3,1,2);
hold on;
ylabel Pitch

ax(3)=subplot(3,1,3);
hold on;
ylabel Roll
xlabel('Completed JDAYs since turn of year');

for q=1:length(hpr_sensor_sets)
    
    hpr=eval(hpr_sensor_sets(q).hpr_table);
    if isfield(hpr_sensor_sets(q),'hpr_scale_factor')
        hpr_scale=hpr_sensor_sets(q).hpr_scale_factor;
    else
        hpr_scale=1;
    end
    if ~isempty(hpr_sensor_sets(q).hpr_heave_field)
        plot(ax(1),datetime(hpr.time, "ConvertFrom","datenum"),hpr.(hpr_sensor_sets(q).hpr_heave_field).*hpr_scale,...
            'color',colors(q,:),'DisplayName',hpr_sensor_sets(q).set_name);
    end
    if ~isempty(hpr_sensor_sets(q).hpr_pitch_field)
        plot(ax(2),datetime(hpr.time, "ConvertFrom","datenum"),hpr.(hpr_sensor_sets(q).hpr_pitch_field).*hpr_scale,...
            'color',colors(q,:),'DisplayName',hpr_sensor_sets(q).set_name);
    end
    if ~isempty(hpr_sensor_sets(q).hpr_roll_field)
        plot(ax(3),datetime(hpr.time, "ConvertFrom","datenum"),hpr.(hpr_sensor_sets(q).hpr_roll_field).*hpr_scale,...
            'color',colors(q,:),'DisplayName',hpr_sensor_sets(q).set_name);
    end

end

linkaxes(ax,'x');
legend('location','best');
