%COMPARE_TSG_TO_CASTS Compare underway thermosalinograph to CTD casts
%
%   Compares underway thermosalinograph to CTD cast values at the depth of 
%   the hull intake. Requires BAS or MSTAR files (modification for Seabird 
%   CNV files should be trivial).
%
%   version 0.1 - 20200311 - Povl Abrahamsen, DY113 - initial version
%   version 1.0 - 20230109 - Povl Abrahamsen, DY158 - adapted for RVDAS
%   version 1.1 - 20240712 - Kat Turner/Povl Abrahamsen, after SD033 - generalise field names

set_underway_params

%% load TSG

tsg=load(fullfile('..',[cruisename,'_ocl_1s_ave.mat']));

% % on Discovery:
% fieldname_tsg_temp='temp_dropkeel';
% fieldname_tsg_celltemp='temp_cell';
% on SDA:
fieldname_tsg_temp='temp1';
fieldname_tsg_celltemp='housingwatertemperature';

%% load casts

% load BAS-processed files from "public" drive on RRS Discovery:
% onehertzfiles=dir('/Volumes/Public/DY158/Scientific work area/CTD/processed_data_BAS/*_cal.1hz');

% alternatively, load local BAS-processed files:
onehertzfiles=dir('../../CTD/cal/*_cal.1hz');

% alternatively, load MSTAR files:
% onehertzfiles=dir('../../CTD/mstar/*_psal.nc');

ctd_date=nan(1e4,1);
ctd_temp=ctd_date;
ctd_temp_std=ctd_date;
ctd_sal=ctd_date;
ctd_sal_std=ctd_date;
m=0;

inlet_press=5.5; % should be 5.5 on RRS Discovery - other ships will vary!

for n=1:length(onehertzfiles)

    if endsWith(onehertzfiles(n).name,'.nc') % MSTAR file
        ctd=struct('press',ncread(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'press'),...
            'temp',ncread(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'temp'),...
            'salin',ncread(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'psal'),...
            'pumps',ncread(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'pumps'),...
            'time_elapsed',ncread(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'time'),...
            'gtime',ncreadatt(fullfile(onehertzfiles(n).folder,onehertzfiles(n).name),'/','data_time_origin'));
    else % BAS/UEA file
        ctd=load('-mat',fullfile(onehertzfiles(n).folder,onehertzfiles(n).name));
    end

    ind=find(abs(ctd.press-inlet_press)<1 & ~isnan(ctd.temp) & ctd.pumps==1);
    range_start=[1;find(diff(ind)>15)+1];
    range_end=[find(diff(ind)>15);length(ind)];
    for o=1:length(range_start)
        range_ind=ind(range_start(o):range_end(o));
        ctd_date(m+o)=mean(ctd.time_elapsed(range_ind))./24./3600+datenum(ctd.gtime);
        ctd_temp(m+o)=nanmean(ctd.temp(range_ind));
        ctd_temp_std(m+o)=nanstd(ctd.temp(range_ind));
        ctd_sal(m+o)=nanmean(ctd.salin(range_ind));
        ctd_sal_std(m+o)=nanstd(ctd.salin(range_ind));
%         ctd_press_check(m+o)=nanmean(ctd.press(range_ind));
    end
    m=m+o;
%     ni=length(ind);
%     ctd_dates(m+[1:ni])=ctd.time_elapsed(ind)./24./3600+datenum(ctd.gtime);
%     ctd_temps(m+[1:ni])=ctd.temp(ind);
%     ctd_sals(m+[1:ni])=ctd.salin(ind);
%     m=m+ni;
end
ctd_date=ctd_date(1:m);
ctd_temp=ctd_temp(1:m);
ctd_temp_std=ctd_temp_std(1:m);
ctd_sal=ctd_sal(1:m);
ctd_sal_std=ctd_sal_std(1:m);


temp_std_limit=0.0025;
sal_std_limit=0.001; %was 0.0025;

%%

% figure;
% subplot(2,1,1);
% plot(tsg_dates,tsg.(fieldname_tsg_temp));
% hold on;
% plot(ctd_dates,ctd_temps,'r+');
% plot(ctd_dates(ctd_temp_std>temp_std_limit),ctd_temps(ctd_temp_std>temp_std_limit),'g+');
% title('Temperature');
% 
% subplot(2,1,2);
% plot(tsg_dates,tsg.salin_cal);
% hold on;
% plot(ctd_dates,ctd_sals,'r+');
% plot(ctd_dates(ctd_sal_std>sal_std_limit),ctd_sals(ctd_sal_std>sal_std_limit),'g+');
% title('Salinity')

tsg_keel_dt=interp1(tsg.time,tsg.(fieldname_tsg_temp),ctd_date,'nearest')-ctd_temp;
tsg_pump_dt=interp1(tsg.time,tsg.(fieldname_tsg_celltemp),ctd_date,'nearest')-ctd_temp;
tsg_ds=interp1(tsg.time,tsg.salin,ctd_date,'nearest')-ctd_sal;

% tsg_cleaning_dates=datenum([2023 1 1 21 12 24;...
%                             2023 1 8 15 22  3;...
%                             2023 1 14 13 54 50;...
%                             2023 1 22 16 34 19]);

%%
figure;
subplot(2,1,1);
plot(ctd_date,tsg_keel_dt,'r+');
hold on;
plot(ctd_date(ctd_temp_std>temp_std_limit|ctd_temp_std==0),tsg_keel_dt(ctd_temp_std>temp_std_limit|ctd_temp_std==0),'g+');
plot(ctd_date,tsg_pump_dt,'rx');
plot(ctd_date(ctd_temp_std>temp_std_limit|ctd_temp_std==0),tsg_pump_dt(ctd_temp_std>temp_std_limit|ctd_temp_std==0),'gx');
% h=plot(tsg.time,tsg.(fieldname_tsg_temp)-tsg.([fieldname_tsg_temp,'_cal']),'b-');
% h.XData(find(~isnan(h.YData),1))=datenum(2020,2,6);
% h.XData(end)=datenum(2020,3,12);
% plot(ctd_dates,ctd_temps,'r+');
ylabel('Temperature offset (^oC)');
title('SBE-38 remote (x) & dropkeel (+) temperature - CTD @ 5.5 dbar');
set(gca,'xlim',datenum(2022,[12 12],[20 60]),'xtick',datenum(2022,12,20:5:60),'XMinorTick',5);
datetick('x','dd mmm','keeplimits','keepticks');
plot(xlim,[0 0],'b--');
% ylim([0 0.6]);

subplot(2,1,2);
plot(ctd_date,tsg_ds,'r+');
hold on;
plot(ctd_date(ctd_sal_std>sal_std_limit|ctd_sal_std==0),tsg_ds(ctd_sal_std>sal_std_limit|ctd_sal_std==0),'g+');
% plot(tsg.times,tsg.salin-tsg.salin_cal,'b-');
% plot(ctd_dates,ctd_sals,'r+');
ylabel('Salinity offset');
title('Calibrated SBE-45 salinity - CTD @ 5.5 dbar')
set(gca,'xlim',datenum(2022,[12 12],[20 60]),'xtick',datenum(2022,12,20:5:60),'XMinorTick',5);
datetick('x','dd mmm','keeplimits','keepticks')
% ylim([-10e-3 15e-3])
% for n=1:length(tsg_cleaning_dates)
%     plot(tsg_cleaning_dates(n)+[0 0],ylim,'m--');
% end
plot(xlim,[0 0],'b--');

% set(gcf,'paperposition',[-5.4279    7.4417   31.8558   14.8167]);

%%
good_temp_ind=find(ctd_temp_std<temp_std_limit & ~isnan(tsg_keel_dt) & ctd_temp_std~=0);

% %%
% 
% 
% figure;
% subplot(2,1,1);
% plot(tsg_dates,tsg.([fieldname_tsg_temp,'_cal']));
% hold on;
% plot(ctd_dates,ctd_temps,'r+');
% plot(ctd_dates(ctd_temp_std>temp_std_limit),ctd_temps(ctd_temp_std>temp_std_limit),'g+');
% title('TSG temp corrected on mstar server');
% 
% tsg_dt_cal=interp1(tsg.time,tsg.([fieldname_tsg_temp,'_cal']),ctd_date,'nearest')-ctd_temp;
% subplot(2,1,2);
% plot(ctd_dates,tsg_dt_cal,'r+');
% hold on;
% plot(ctd_dates(ctd_temp_std>temp_std_limit),tsg_dt_cal(ctd_temp_std>temp_std_limit),'g+');
% % plot(tsg_dates,tsg.([fieldname_tsg_temp,'_cal'])-tsg.(fieldname_tsg_temp),'b-');

%%
% 
% figure;
% plot(15-ctd_temps(good_temp_ind)-tsg_dt(good_temp_ind),-tsg_dt(good_temp_ind),'r+');
% set(gca,'XScale','log');
% 
% testpoly=polyfit(log(15-ctd_temps(good_temp_ind)-tsg_dt(good_temp_ind)),-tsg_dt(good_temp_ind),1)
% 
% hold on;
% plot(xlim,polyval(testpoly,log(xlim)),'k--');
% 
% dt_to_apply=polyval(testpoly,log(15-tsg.(fieldname_tsg_temp)));
% tsg.([fieldname_tsg_temp,'_cal'])=tsg.(fieldname_tsg_temp)+dt_to_apply;
% 
% figure;
% subplot(2,1,1);
% plot(tsg_dates,tsg.([fieldname_tsg_temp,'_cal']));
% hold on;
% plot(ctd_dates,ctd_temps,'r+');
% plot(ctd_dates(ctd_temp_std>temp_std_limit),ctd_temps(ctd_temp_std>temp_std_limit),'g+');
% title('TSG temp corrected in script');
% 
% tsg_dt_cal=interp1(tsg_dates,tsg.([fieldname_tsg_temp,'_cal']),ctd_dates,'nearest')-ctd_temps;
% subplot(2,1,2);
% plot(ctd_dates,tsg_dt_cal,'r+');
% hold on;
% plot(ctd_dates(ctd_temp_std>temp_std_limit),tsg_dt_cal(ctd_temp_std>temp_std_limit),'g+');

%%

% fprintf(1,'Stats:\n');
% fprintf(1,'Before Stanley:\n mean: %.4f, median: %.4f, std.dev.: %.4f\n',...
%     nanmean(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)<datenum(2020,3,4)))),...
%     nanmedian(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)<datenum(2020,3,4)))),...
%     nanstd(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)<datenum(2020,3,4)))));
% fprintf(1,'After Stanley:\n mean: %.4f, median: %.4f, std.dev.: %.4f\n',...
%     nanmean(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)>datenum(2020,3,4)))),...
%     nanmedian(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)>datenum(2020,3,4)))),...
%     nanstd(tsg_dt(good_temp_ind(ctd_date(good_temp_ind)>datenum(2020,3,4)))));
% fprintf(1,'After correction:\n mean: %.4f, median: %.4f, std.dev.: %.4f\n',...
%     nanmean(tsg_dt_cal(good_temp_ind)),...
%     nanmedian(tsg_dt_cal(good_temp_ind)),...
%     nanstd(tsg_dt_cal(good_temp_ind)));

%%

% save data for intercomparison

tsg_temp=interp1(tsg.time,tsg.(fieldname_tsg_temp),ctd_date,'nearest');
% tsg_temp_cal=interp1(tsg.time,tsg.([fieldname_tsg_temp,'_cal']),ctd_date,'nearest');
tsg_sal=interp1(tsg.time,tsg.salin,ctd_date,'nearest');
% tsg_sal_cal=interp1(tsg.time,tsg.salin_cal,ctd_date,'nearest');
tsg_celltemp=interp1(tsg.time,tsg.(fieldname_tsg_celltemp),ctd_date,'nearest');

% save dy158_underway_ctd_comparison ctd_date ctd_temp ctd_temp_std ...
%     ctd_sal ctd_sal_std tsg_temp tsg_temp_cal tsg_sal tsg_sal_cal tsg_celltemp
% 

