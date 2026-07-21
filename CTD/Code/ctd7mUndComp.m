clear
CTDvarn
%pull out 7m CTD temperature and pull out matching underway temperature for comparison.
%doesn't do salts as no TSG yet for SD020, easy to add

k=0;
monthlist=[31 28 31 30 31 30 31 31 30 31 30 31];
%monthlist=[31 29 31 30 31 30 31 31 30 31 30 31]; %leap year

if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');

else
    error('incEvent selected but no lookup table for event numbers')
end
else
    eee='';
end

sc=input('Enter first cast\n');
ec=input('Enter last cast\n');


for stn=[sc:ec]


aaa=num2str(stn,'%03d');

if incEvent
aai=find(CastEvent(:,1)==stn);
if ~isempty(aai)
eec=CastEvent(aai,2);
eee=num2str(eec,'%03d');
eee=['_',eee,];
end
else
    eee='';
end
    
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_cal_2db_up.mat']);
if exist(infile,'file') %currently assumes that both 2db files will either exist or neither
 load (infile,'-mat');
 
%h = m_read_header(file);
   % lat=h.latitude;
   % lon=h.longitude;
    timeorig=gtime; %h.data_time_origin;
    
    pressure=press; %nc_varget(file,'press');
    %temp=nc_varget(file,'temp1_cal');
    sal=salin; %nc_varget(file,'psal_cal');
    time=time_elapsed; %nc_varget(file,'time');
    
    ii=find(pressure==7);  %do want for 7m looping
    if isfinite(ii)
       k=k+1;
   temp7m(k)=temp(ii);
        sal7m(k)=sal(ii);
        time7m(k)=time(ii);
        lat7m(k)=lat;
        lon7m(k)=lon;
        year7m(k)=timeorig(1);
        month7m(k)=timeorig(2);
        day7m(k)=timeorig(3);
        hour7m(k)=timeorig(4);
        minute7m(k)=timeorig(5);
        seconds7m(k)=timeorig(6);
        jday=sum(monthlist(1:month7m(k)-1))+day7m(k)-1;
        secyear(k)=jday*86400+hour7m(k)*3600+minute7m(k)*60+seconds7m(k)+time7m(k);
    end


   
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'_cal_2db.mat']);
 load (infile,'-mat');
 
%h = m_read_header(file);
   % lat=h.latitude;
   % lon=h.longitude;
    timeorig=gtime; %h.data_time_origin;
    
    pressure=press; %nc_varget(file,'press');
    %temp=nc_varget(file,'temp1_cal');
    sal=salin; %nc_varget(file,'psal_cal');
    time=time_elapsed; %nc_varget(file,'time');
    
    ii=find(pressure==7);  %do want for 7m looping
    
    if isfinite(ii)
       k=k+1;
   temp7m(k)=temp(ii);
        sal7m(k)=sal(ii);
        time7m(k)=time(ii);
        lat7m(k)=lat;
        lon7m(k)=lon;
        year7m(k)=timeorig(1);
        month7m(k)=timeorig(2);
        day7m(k)=timeorig(3);
        hour7m(k)=timeorig(4);
        minute7m(k)=timeorig(5);
        seconds7m(k)=timeorig(6);
        jday=sum(monthlist(1:month7m(k)-1))+day7m(k)-1;
        secyear(k)=jday*86400+hour7m(k)*3600+minute7m(k)*60+seconds7m(k)+time7m(k);
    end
end
    end
filesst=fullfile(dir_und,'thermometer_seabird_sbe38_ucsw1_psbsst1','thermometer_seabird_sbe38_ucsw1_psbsst1_all');
% filesst='L:\work\scientific_work_areas\physics\Underway\ocl\thermometer_seabird_sbe38_ucsw1_psbsst1\thermometer_seabird_sbe38_ucsw1_psbsst1_all';
load (filesst,'-mat');

%jdaysst=thermometer_seabird_sbe38_ucsw1_psbsst1.jday1;
sst=thermometer_seabird_sbe38_ucsw1_psbsst1.temperature;
secyearSST=thermometer_seabird_sbe38_ucsw1_psbsst1.time_secs;

for ik=1:length(secyear)
  secnear=find(secyearSST-secyear(ik)>0,1,'first');
% secnear=nearest(secyearSST,secyear(ik));
if ~isempty(secnear)  %CTD after latest underway
 secSST_7m(ik)=secyearSST(secnear);
 sst_7m(ik)=sst(secnear);
end
end

figure
plot(secyear/86400,temp7m,'k.','MarkerSize',15); hold on
plot(secSST_7m/86400,sst_7m,'b.','MarkerSize',15)


filesst2=fullfile(dir_und,'thermometer_seabird_sbe38_ucsw2_psbsst1','thermometer_seabird_sbe38_ucsw2_psbsst1_all');
% filesst2='L:\work\scientific_work_areas\physics\Underway\ocl\thermometer_seabird_sbe38_ucsw2_psbsst1\thermometer_seabird_sbe38_ucsw2_psbsst1_all';
load (filesst2,'-mat');

%jdaysst=thermometer_seabird_sbe38_ucsw1_psbsst1.jday1;
sst2=thermometer_seabird_sbe38_ucsw2_psbsst1.temperature;
secyearSST2=thermometer_seabird_sbe38_ucsw2_psbsst1.time_secs;

for ik=1:length(secyear)
  secnear=find(secyearSST2-secyear(ik)>0,1,'first');
% secnear=nearest(secyearSST,secyear(ik));
if ~isempty(secnear)  %CTD after latest underway
 secSST2_7m(ik)=secyearSST2(secnear);
 sst2_7m(ik)=sst2(secnear);
end
end

plot(secSST2_7m/86400,sst2_7m,'m.','MarkerSize',15)

xlabel('Day of Year')
ylabel('Temperature')
legend('CTD','UwSST1','UwSST2','Location','SouthEast')

h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);
  
    
%file='C:\Users\hjv\SD030\CTD7m_SST.png';
%eval(['print -r300  -dpng ',file,])

figure
plot(secyear/86400,temp7m-sst_7m,'k.','MarkerSize',15); hold on
plot(secyear/86400,temp7m-sst2_7m,'g.','MarkerSize',15); 

xlabel('Day of Year')
ylabel('Temperature Difference (CTD-Und)')
legend('CTD-SST1','CTD-SST2','Location','NorthEast')

h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);
%file='C:\Users\hjv\SD030\CTD7m_SST_offset.png';
%eval(['print -r300  -dpng ',file,])

figure
plot(temp7m,temp7m-sst_7m,'k.','MarkerSize',15); hold on
plot(temp7m,temp7m-sst2_7m,'g.','MarkerSize',15); 

xlabel('CTD Temperature')
ylabel('Temperature Difference (CTD-Und)')
legend('CTD-SST1','CTD-SST2','Location','NorthWest')

h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);
%file='C:\Users\hjv\SD030\CTD7m_SST_offset_Temp.png';
%eval(['print -r300  -dpng ',file,])

%%underway salinity

filetsg=fullfile(dir_und,'thermosalinograph_seabird_sbe45_ucsw1_psbtsg1','thermosalinograph_seabird_sbe45_ucsw1_psbtsg1_all');
% filetsg='L:\work\scientific_work_areas\physics\Underway\ocl\thermosalinograph_seabird_sbe45_ucsw1_psbtsg1\thermosalinograph_seabird_sbe45_ucsw1_psbtsg1_all';
load (filetsg,'-mat');

%jdaysst=thermometer_seabird_sbe38_ucsw1_psbsst1.jday1;
salOCL=thermosalinograph_seabird_sbe45_ucsw1_psbtsg1.salinity;
secyearsalOCL=thermosalinograph_seabird_sbe45_ucsw1_psbtsg1.time_secs;

for ik=1:length(secyear)
  secnear=find(secyearsalOCL-secyear(ik)>0,1,'first');
% secnear=nearest(secyearSST,secyear(ik));
if ~isempty(secnear)
 secsalOCL_7m(ik)=secyearsalOCL(secnear);
 salOCL_7m(ik)=salOCL(secnear);
else
     secsalOCL_7m(ik)=NaN;
 salOCL_7m(ik)=NaN;
end
end

figure
plot(secyear/86400,sal7m,'k.','MarkerSize',15); hold on
plot(secsalOCL_7m/86400,salOCL_7m,'b.','MarkerSize',15)

xlabel('Day of Year')
ylabel('Salinity')
legend('CTD','UwSalin','Location','SouthEast')

h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);


  figure
plot(sal7m,sal7m-salOCL_7m,'k.','MarkerSize',15); hold on
xlabel('CTD Salinity')
ylabel('Salinity Difference (CTD-Und)')

h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);

  figure
plot(secyear/86400,sal7m-salOCL_7m,'k.','MarkerSize',15); hold on

xlabel('Day of Year')
ylabel('Salinity Difference (CTD-Und)')
h = findobj('Type','axes');
  set(h,'FontSize',13);
h = findobj('Type','text');
  set(h,'FontSize',13);



%% pull out underway bottle salts to add to plots as extra data and independent comparisons (from pre sd020 code)

        databott=readmatrix('L:\work\scientific_work_areas\ctd\Salinometry\salinities\output_sal_SD046_underway_001.csv');
        salbott=databott(:,4);
        secbott=databott(:,1)*86400;

         for js=1:length(salbott)
          
            ii=min(find((secbott(js)-secyearsalOCL)>0,1,'last'));
            saloclbott(js)=salOCL(ii);            
           
            % latoclbott(js)=latocl(ii);
            % lonoclbott(js)=lonocl(ii);

            % if ii+6<length(salocl)&ii-6>0
            % saloclbottAv(js)=nanmean(salocl(ii-6:ii+6));            
            % sstoclbottAv(js)=nanmean(sstocl(ii-6:ii+6)); 
            % else
            %  saloclbottAv(js)=NaN;            
            % sstoclbottAv(js)=NaN;    
            % end
         end

%          save 'C:\hjv\jr239\UnderwayData\SamplesOCL.mat' salbott secbott saloclbott sstoclbott latoclbott lonoclbott
%          figure
          plot(secbott/86400,salbott'-saloclbott,'k.'); hold on
%         plot(secyear,sal7m-salocl7m,'r.')

figure
plot(salbott',salbott'-saloclbott,'k.'); hold on
%         
% 

%% Find calibration fits

%temperature against water temperature

%salinity against time, with step
% save files to edit in cruise specific script
ctd_files.time_ctd = secyear/86400;
ctd_files.temp_ctd = temp7m;
ctd_files.salt_ctd = sal7m;

uw_files.time_temp = secSST_7m/86400;
uw_files.time_salt = secsalOCL_7m/86400;
uw_files.temp_1 = sst_7m;
uw_files.temp_2 = sst2_7m;
uw_files.salt = salOCL_7m;

bottle_files.time = secbott/86400;
bottle_files.salt_measured = salbott';
bottle_files.salt_uw = saloclbott;

save(fullfile('..','..','physics','Underway/','ctd_cals.m'),"ctd_files");
save(fullfile('..','..','physics','Underway/','uw_cals.m'),"uw_files");
save(fullfile('..','..','physics','Underway/','bottle_cals.m'),"bottle_files");