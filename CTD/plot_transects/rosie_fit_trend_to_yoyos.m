%Script to plot all casts from ice front section for comparison, and where
%multiple sections exist, find the mean and std and make envelope...
%Rosie Williams 14/08/2026

%%%% Don't edit! Not it fit state - Rosie half way through something below :-)
%Editing in progress - rush at end. Take a copy to play with if desired.

%% add path
close all; clear all;

%cchoice=input('What cmap do you want: phase or jet?\n','s');
c_jet=1; % if 0, uses phase

plot_casts_and_tides=1;
% within that, would you like me to plot the isopycnals?
plot_isopycnal=1;
plot_tide_metrics=0;

RosieScale =[
    0.00 0.35 0.75   % blue
    0.00 0.60 0.30   % green
    0.00 0.75 0.75   % turquoise
    % 0.00 0.00 0.00   % black
    0.85 0.05 0.05   % red
    0.90 0.45 0.05    % orange
     0.00 0.00 0.00   % black
    ];


if ispc
    addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
    disk = ['L:\work\scientific_work_areas\'];
    ctddata = [disk,'oceanography\CTD\BASproc\'];
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\matlabF\']) % for cmocean
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\library\'])
    addpath([disk,'oceanography\CTD\GSWscripts\gsw_matlab_v3_06_16\thermodynamics_from_t\'])
    addpath([disk,'oceanography\CTD\plot_transects\']) % directory with section parameter function
else
    addpath '/Volumes/legwork/scientific_work_areas/oceanography/CTD/Code/'
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    ctddata = [disk,'CTD/BASproc/'];
end
%% load CTD structure data
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

%% select the yoyos:
sectionfilename={'repeat_3micefrontsouthyoyoonly','repeat_3micefrontnorthyoyoonly'};

sectionfilename={'repeat_3micefrontsouthyoyoonly'};

sectionfilename={'repeat_3micefrontsouthyoyoonly','repeat_3micefrontnorthyoyoonly','repeat_3msouthtroughyoyoonly','repeat_3mwestsillyoyoonly','repeat_3msillsouthpeakyoyoonly','repeat_3meastsillyoyoonly'};

%sectionfilename={'repeat_3micefrontall'};

%sectionfilename={'3micefrontnorth-fjord1'};
%sectionfilename={'repeat_3micefrontnorthyoyoonly'};


grey  = [0.55 0.55 0.55];

alpha = 0.6;

ctds_times=[];
cast_number=[];



%figure(1);
%figure('Position', [50, 50, 700, 700]);

%fig2=figure('Position', [50, 50, 700, 700]);

R2_vals=[];
for m=1:length(sectionfilename)
    %Add in ice front repeat
    P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder
    ncasts = length(P.sectionlist);
    stns=P.sectionlist;

    allstations=[ctds.station];
    ind=zeros(size(stns));
    for n=1:length(stns)
        try
            ind(n)=find(allstations==stns(n));
        catch
            error('Cannot find %s station %d',cruise,stns(n));
        end
    end
    ctds_n=ctds(ind);

    ncolours=100;
    if c_jet
        cmap=jet(ncolours);
    else
        cmap=flipud(cmocean('phase',ncolours));
    end


    tidestep=1/(ncolours-1);
    tidebounds=[0:tidestep:1];

    theta=0:1:360;
    press_at_TC=NaN(size(ncasts));
    press_at_iso=NaN(size(ncasts));
    tidal_phase_idealised=NaN(size(ncasts));
    %
    tidal_height=NaN(size(ncasts));
    tidal_speed=NaN(size(ncasts));
    %% loop the sections, now plotting
    for ii=1:ncasts
        line_style='-';

        ctd_time=datetime(ctds_n(ii).gtime);
        ctds_times=[ctds_times ctd_time];
        cast_number=[cast_number P.sectionlist(ii)];

        %Calculate the depth at which temp=TC for each cast:
        TC=-0.2;
        temp_below=80/2;
        % all_sigma0 = [ctds_n.sigma0];
        %  max_sigma0 = max(all_sigma0);
        max_common_sigma0 = min(arrayfun(@(x) max(x.sigma0), ctds_n));
        %isopycnal_level= max_common_sigma0;
        isopycnal_level= 26.3;
        iso_below=1;
        % For the isotherm:
        [~,index_TC]=min(abs(ctds_n(ii).Ctemp(temp_below:end) - (TC)));
        index_TC=index_TC+temp_below-1;
        ctds_n(ii).Ctemp(index_TC);
        press_at_TC(ii)=ctds_n(ii).press(index_TC);
        tidal_phase_idealised(ii)=ctds_n(ii).tide_phase_fraction*360;
        zh(ii)= ctds_n(ii).tide_height_zh;
        dzhdt(ii)= ctds_n(ii).tide_rising_rate_mpday;
        %
        [~,index_iso]=min(abs(ctds_n(ii).sigma0(iso_below:end) - (isopycnal_level)));
        index_iso=index_iso+iso_below-1;
        ctds_n(ii).sigma0(index_iso);
        press_at_iso(ii)=ctds_n(ii).press(index_iso);

        %   for ii=1:ncasts
        cnumbertide=zeros(ncasts,1);
        for c=1:ncasts
            [junk,ind]=min(ctds_n(ii).tide_phase_fraction>tidebounds);
            cnumbertide(c)=ind;
        end
        % yyaxis left
        % figure(1);plot(ctds_n(ii).tide_phase_fraction,cosd(ctds_n(ii).tide_phase_fraction*360),'Marker','o','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5,'HandleVisibility', 'off');
        % hold on
        % figure(1);plot(theta/360,cosd(theta),'k-','LineWidth',1.5,'HandleVisibility', 'off');
        % xlabel('Idealised tidal phase');
        % ylabel(gca,'Illustrative tidal wave');
        % title("CTDs timings in tidal cycle ")
        % yyaxis right
        % plot(tidal_phase_idealised(ii)/360,press_at_iso(ii),'Marker','+','Color',cmap(cnumbertide(ii),:),'LineStyle','none','MarkerSize',6,'LineWidth', 1.5,'HandleVisibility', 'off');
        % hold on
        % ylabel(gca,'Isopycnal depth');
        % xlim([0 1]);
    end

    snap = [];
    for ii = 2:length(tidal_phase_idealised)
        if isempty(snap) && (tidal_phase_idealised(ii)/360) < (tidal_phase_idealised(ii-1)/360)
            snap = ii - 1;
        end
    end
    if isempty(snap)
        snap=ncasts;
    end

    % figure(1);
    % plot(tidal_phase_idealised(1:snap)/360,press_at_iso(1:snap),'LineWidth', 1.5,'Color',RosieScale(m,:),'LineStyle','-','Marker','none');
    % if snap+1==ncasts
    %     press_at_iso_av=(press_at_iso(snap)+press_at_iso(snap+1))/2
    %     plot([0 tidal_phase_idealised(snap+1:end)/360],[press_at_iso_av press_at_iso(snap+1)],'LineWidth', 1.5,'Color',RosieScale(m,:),'LineStyle','-','Marker','none','HandleVisibility', 'off');
    % else
    %     plot(tidal_phase_idealised(snap+1:end)/360,press_at_iso(snap+1:end),'LineWidth', 1.5,'Color',RosieScale(m,:),'LineStyle','-','Marker','none','HandleVisibility', 'off');
    % end

    %fit model to these tidal cycles separately:

    [junk indexes_sorted]=sort(tidal_phase_idealised);
    tidal_phase_idealised_ordered=tidal_phase_idealised(indexes_sorted)/360;
    press_at_iso_ordered=press_at_iso(indexes_sorted);
    ctds_times_ordered = ctds_times(indexes_sorted);
%    f = fit( tidal_phase_idealised_ordered(:),press_at_iso_ordered(:),'sin1');
 
    % figure;
    % plot(f,tidal_phase_idealised_ordered,press_at_iso_ordered)

    name = sprintf('_yoyo_isophycs_%s.png', sectionfilename{m});
    exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 200)
    % set(gca,'ydir','reverse','xaxislocation','top')


phase = tidal_phase_idealised_ordered(:);
iso = press_at_iso_ordered(:);

% Remove any NaNs
good = ~isnan(phase) & ~isnan(iso);
phase = phase(good);
iso = iso(good);

% One complete tidal cycle = 1
theperiods = [1,0,1];

% Harmonic fit
[b_iso,x_iso,r_iso,f_iso,v_iso] = harmfit( ...
    iso,phase,theperiods,0.8);

% Smooth phase grid
phasefit = linspace(0,1,500);

Xfit = harmcrv(phasefit,theperiods);
 
isotherm_fit = Xfit*b_iso;

% Fitted values at the actual observation points
Xobs = harmcrv(phase,theperiods);
iso_fit_obs = Xobs*b_iso;

% R-squared
SSres = sum((iso - iso_fit_obs).^2);
SStot = sum((iso - mean(iso)).^2);

R2 = 1 - SSres/SStot

R2_vals=[R2_vals real(R2)];


figure(2)
plot(phase,iso,'LineWidth', 1.0,'Color',RosieScale(m,:),'LineStyle','none','Marker','o','HandleVisibility', 'off')
hold on
plot(phasefit,isotherm_fit,'LineWidth', 1.0,'Color',RosieScale(m,:),'LineWidth',2)

set(gca,'YDir','reverse')
xlabel('Tidal phase')
ylabel('Pressure of 26.3 isopycnal')
xlim([0 1])
xticks(0:0.25:1)
grid on

legend('ice front yoyo south','ice front yoyo north', 'trough south yoyo', 'west sill yoyo','south sill yoyo','east sill yoyo','Location','southwest')

%find peak of isothem fit:
[pks, loc] = findpeaks(real(isotherm_fit));
phase_peak=phasefit(loc);

%find the corresponding time:
time_peak = interp1(phase, ctds_times_ordered, phase_peak);
1;

end

name = sprintf('_sinusoidal_fit_yoyos.png');
exportgraphics(gcf, fullfile('Figures', [cruise name]), 'Resolution', 200);

%Now we have a lovely fit for the yoyo, we can look at temporal
%variability at the other sites in the same region.


%Load up all stations at ice front:
sectionfilename={'repeat_3micefrontnorthall'};

%% load CTD structure data
cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

clear ctds_n
ctds_times=[];
cast_number=[];
press_at_iso=[];
for m=1:length(sectionfilename)
    %Add in ice front repeat
    P = sdaSectionParams(sectionfilename{m}); % function that needs to be in the same folder
    ncasts = length(P.sectionlist);
    stns=P.sectionlist;

    allstations=[ctds.station];
    ind=zeros(size(stns));
    for n=1:length(stns)
        try
            ind(n)=find(allstations==stns(n));
        catch
            error('Cannot find %s station %d',cruise,stns(n));
        end
    end
    ctds_n=ctds(ind);

    for ii=1:ncasts
        line_style='-';

        ctd_time=datetime(ctds_n(ii).gtime);
        ctds_times=[ctds_times ctd_time];
        cast_number=[cast_number P.sectionlist(ii)];

        %Calculate the depth at which temp=TC for each cast:
        TC=-0.2;
        temp_below=80/2;
        % all_sigma0 = [ctds_n.sigma0];
        %  max_sigma0 = max(all_sigma0);
        max_common_sigma0 = min(arrayfun(@(x) max(x.sigma0), ctds_n));
        %isopycnal_level= max_common_sigma0;
        isopycnal_level= 26.3;
        iso_below=1;
        % For the isotherm:
        [~,index_TC]=min(abs(ctds_n(ii).Ctemp(temp_below:end) - (TC)));
        index_TC=index_TC+temp_below-1;
        ctds_n(ii).Ctemp(index_TC);
        press_at_TC(ii)=ctds_n(ii).press(index_TC);
        tidal_phase_idealised(ii)=ctds_n(ii).tide_phase_fraction*360;
        zh(ii)= ctds_n(ii).tide_height_zh;
        dzhdt(ii)= ctds_n(ii).tide_rising_rate_mpday;
        %
        [~,index_iso]=min(abs(ctds_n(ii).sigma0(iso_below:end) - (isopycnal_level)));
        index_iso=index_iso+iso_below-1;
        ctds_n(ii).sigma0(index_iso);
        press_at_iso(ii)=ctds_n(ii).press(index_iso);
    end

    %Now plot times versus isophc:
start_time = datetime(2026,8,2);
end_time   = datetime(2026,8,16);

time_plot = start_time:minutes(10):end_time;

hours_from_peak = hours(time_plot - time_peak);

phase_plot = mod(phase_peak + hours_from_peak/12.25,1);

Xplot = harmcrv(phase_plot,theperiods);
isotherm_plot = Xplot*b_iso;

figure(43)
plot(time_plot,real(isotherm_plot),'r-','LineWidth',2)
hold on
xline(time_peak,'k--','Peak','LineWidth',1.5)

set(gca,'YDir','reverse')
xlabel('Date')
ylabel('Pressure of -0.2 ^oC isotherm (dbar)')
xlim([start_time end_time])
grid on

%add in CTD times;
plot(ctds_times,press_at_iso,'b+');
ylim([80 110])


end
