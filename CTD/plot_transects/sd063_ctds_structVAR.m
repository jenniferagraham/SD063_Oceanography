close all; clear all;
% need to create a structure variable with all CTD data 
% row must be a station 
% column are the variables
savename = 'sd063_ctd.mat'; 

%%
here=pwd;
if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    %sd063_CTD = [disk,'SDA063-GIANT\'];
     sd063_CTD = [disk,'CTD\BASproc\'];
     sd063_LADCP = [disk,'LADCP\Postprocessing_LDEO_IX_15beta\',...
         'processed_withVMADCP\'];
  %  skagerakCTD = [disk,'Skagerak_cruise_2025_Data\CTD\processed\final_mat\'];
  %  pathO18 = [disk,'KANG_GLAC\Povl_O-18scripts\'];
    figPb = [here,'\Figures\'];
 %   addpath([disk,'matlabF\']) % theta_sdiag function
%    addpath([disk,'matlabF\GSW\'])
    addpath([disk,'\GSWscripts\gsw_matlab_v3_06_16\'])
    tdrive=input('What letter is your temp drive, e.g., T or P?\n','s');
    tidefile=sprintf('%s:/SD063/Gr1kmTM/data/Gr1kmTM_v1.nc',...
        upper(tdrive));
%    addpath([disk,'matlabF\GSW\thermodynamics_from_t\'])
    FZ=12;
elseif ismac
    %%%NOT YET EDITED - ROSIE 25/07/2026
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    sd063_CTD = [disk,'/CTD/BASproc/'];
    figPb = [here,'/Figures/'];
    addpath([disk,'matlabF/']) % theta_sdiag function
    addpath([disk,'matlabF/m_map/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/library/'])
    addpath([disk,'CTD/GSWscripts/gsw_matlab_v3_06_16/thermodynamics_from_t/'])
    FZ=12;
end
% create the station list manually 
% !cd BASproc
% ! ls *2bd.mat > stationlist.txt
%sd063_CTDlist=[sd063_CTD,'stationlist.txt'];
%filepath = ' sd063_CTD';

stationlist = dir(fullfile(sd063_CTD, 'SD063_ctd_*_struct.mat'));

%filenames = readlines(sd063_CTDlist); 
filenames = stationlist.name;

for ii = 1:length(stationlist)
    
    currentName = stationlist(ii).name;
    load([sd063_CTD,currentName])
    stnid = sprintf('%03d',ctd.station);

    % Add LADCP data to structure... 
    % NB. Needs to be same size as CTD depths? (2db?)
    ladcpfile = fullfile(sd063_LADCP,stnid,...
        sprintf('SD063_data_%s.mat',stnid));
    if isfile(ladcpfile)
        load(ladcpfile)

        ladcp_vel = dr.u + 1j*dr.v;
        vel2db = interp1(dr.p, ladcp_vel, ctd.press); 
        ctd.ladcp_u = real(vel2db);
        ctd.ladcp_v = imag(vel2db);
    else
        fprintf('WARNING: LADCP missing for %s\n', stnid)
        ctd.ladcp_u = nan;
        ctd.ladcp_v = nan;

    end

    %%Day team needed this commented out line:
    %ctds(ctd.station) = ctd; % should I change the names?
   
    %Night team needed to use this one so that the structure of structures worked
    %with our plotting scripts when they use the "allstations" list to search
    %for the right station number....
    ctds(ii) = ctd; % should I change the names?

end

%Now add in tidal info based on the tidal model

% allstations=[ctds.station];
% stns=allstations;
% ind=zeros(size(stns));
% for n=1:length(stns)
%     try
%         ind(n)=find(allstations==stns(n));
%     catch
%         error('Cannot find %s station %d',cruise,stns(n));
%     end
% end
% ctds=ctds(ind);

%% All CTDs have a gtime number that needs converting to datenum:
ctds_times=[];
for ii=1:length(stationlist)
    ctd_time=datetime(ctds(ii).gtime);
    ctds_times=[ctds_times ctd_time];
end

%calculate tides for the range of interest:
t = datetime('jul 16, 2026'):seconds(1):datetime('aug 28, 2026');
z = tmd_predict(tidefile,68.2796,-30.7665,t);
dzhdt=diff(z)/datenum(t(2)-t(1));
time_at_deriv=t(:)+(t(2)-t(1))/2;


%Output tide height zh at the time of the ctd:
%% loop the sections 
for ii=1:length(stationlist)
    [~,index_zh]=min(abs(t-ctds_times(ii)));
    ctds(ii).tide_height_zh=z(index_zh);
    ctds(ii).tide_rising_rate_mpday=dzhdt(index_zh);
end


%Now find the first tide height
[pks, loc] = findpeaks(z);
peak_times=t(loc);
%plot(peak_times, pks, 'ro')

last_peak_time   = NaT(size(ctds_times));
next_peak_time = NaT(size(ctds_times));
last_peak_height = NaN(size(ctds_times));

for i = 1:numel(ctds_times)

    previous = find(peak_times < ctds_times(i));
    % Peaks after the CTD cast
    next = find(peak_times > ctds_times(i));

    if ~isempty(previous)
        idx = previous(end);
        last_peak_time(i)   = peak_times(idx);
        last_peak_height(i) = pks(idx);
    end

    if ~isempty(next)
        next_peak_time(i) = peak_times(next(1));
    end
end

% calculate peak duration:
peak_duration = next_peak_time - last_peak_time;

%Now calculate fraction of cycle the CDT cast was from the last maximum:
% Loop over each structure (cast)
for ii=1:length(stationlist)
    frac = (ctds_times(ii) - last_peak_time(ii)) / peak_duration(ii);
    ctds(ii).tide_phase_fraction=frac;
end

%save structure:
save(fullfile(sd063_CTD, 'SD063_ctd.mat'),'ctds')