function break_loop=ctdreadGEN(aaa,eee)

% ctdcal... invokes cnv2mat to read CTD files...
% use after running through to "loopedit" stage in SBE software
%
% mmm, CD160, August 2004
%
% modified for reprocessing of JR161 CTD data, Feb 2007

CTDvarn;  %set up directory paths and variable names/positions

if nargin<1
    aaa=input('Cast number?\n','s');
    if incEvent
        eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if ~exist(eventsave,'file')  %first cast
     disp('Welcome to the ship(/reprocessing job)')
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
end

    eee=input('Event number?\n','s');
    else
        eee='';
    end

elseif nargin==1  %just cast number
    if ~ischar(aaa)
    aaa=num2str(aaa);
    end
    if incEvent
eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(find(CastEvent(:,1)==aac),2);
eee=num2str(eec,'%03d')
else 
    eee=input('Event number?\n','s');  %new cast
end
else
    disp('Welcome to the ship(/reprocessing job)')
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eee=input('Event number?\n','s'); %start of cruise
end
    else
    eee='';
    end
else             %cast and event number given
     if ~ischar(aaa)
    aaa=num2str(aaa);
     end
    if ~ischar(eee)
    eee=num2str(eee);
    end

end
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];

if incEvent
padzeros=max([3-length(eee),4-strfind(eee,'.')]);
eee=[repmat('0',1,padzeros),eee];
eee(eee=='.')=[];
eee=['_',eee,];

eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
eec=str2num(eee(2:4));

iia=find(CastEvent(:,1)==aac);
iie=find(CastEvent(:,2)==eec);

if isempty(iia)&&isempty(iie)  %no sign of this cast, add to list and carry on
CastEvent(end+1,1:2)=[str2num(aaa),str2num(eee(2:4))];
save (eventsave, 'CastEvent')
elseif (isempty(iia)||isempty(iie))|(iia~=iie)
    warning('Something awry with values entered or *cruise*_ctd_CastEventList')
    warning('Check current values or edit CastEventList')
    crow=input('Are you sure you want to proceed? y/n \n','s');
    if crow=='y'
        disp('Output file will be written...')
        CastEvent(end+1,1:2)=[str2num(aaa),str2num(eee(2:4))];
        save (eventsave, 'CastEvent')
    else
        disp('See you later')  %stop
            break_loop=true;
            return
    end
elseif iia==iie
      crow=input('File has already been read (or at least attempted), proceed? y/n \n','s');
     if crow=='y'
            disp('Output file will be overwritten')  %carry on, don't add again to CastEvent
         
        else
            disp('Script already run')  %stop
            break_loop=true;
            return;
        end
end

else
     disp('Welcome to the ship(/reprocessing job)')
    CastEvent=[str2num(aaa),str2num(eee(2:4))];  %start a matched list of cast and event number
    
    save (eventsave, 'CastEvent')
end

end

disp(['processing cast ',aaa])



ctdfile=fullfile(dir_sb,[,cruise,'_',sb_prefix,aaa,frame_fileadd,sb_fileadd,'.cnv']) %extra comma is necessary if also doing LADCP preocessing
ctdsave=fullfile(dir_out,[,cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.red'])  %was .cal but that looks like finalised calibrated data
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

disp('reading data...')
[gtime,data,names,lat,lon]=cnv2matGEN(ctdfile);
%gtime(end+1)=aae; %add event number to gtime

for iv=1:length(vp)
    if vp(iv)==1
        eval([,varnames{iv,1},'=data(:,',num2str(varnames{iv,2}),');'])
        fprintf(1,'Our variable name: %s; SBE name: %s\n',varnames{iv,1},...
            names(varnames{iv,2},(find(names(varnames{iv,2},:)=='=',1)+2):end));
    end
end

save (ctdsave,'names','gtime','lat','lon',varnames{(vp==1),1})

if nargout>0
    break_loop=false;
end
%end

%clear

%if needed, on JCR, use 't2pos -d seatex YYDDDHHMMSS' in terminal to get corresponding lat and lon in
%format expected below (' lat lon')
% starttime=input('enter start time YYDDDHHMMSS ','s');
% latlon=input('enter start location: lat lon ','s');
% while latlon(1)==' '   %strip first space
% latlon=latlon(2:end);
% end
% i=1;
% latstart=[];
% while latlon(i)~=' '
% latstart=['',latstart,'',latlon(i),''];
% i=i+1;
% end
% lonstart=str2num(latlon(i:end));
% latstart=str2num(latstart);
% 
% bottomtime=input('enter bottom time YYDDDHHMMSS ','s');
% latlon=input('enter bottom location: lat lon ','s');
% while latlon(1)==' '   %strip first space
% latlon=latlon(2:end);
% end
% i=1;
% latbott=[];
% while latlon(i)~=' '
% latbott=['',latbott,'',latlon(i),''];
% i=i+1;
% end
% lonbott=str2num(latlon(i:end));
% latbott=str2num(latbott);
% 
% endtime=input('enter end time YYDDDHHMMSS ','s');
% latlon=input('enter end location: lat lon ','s');
% while latlon(1)==' '   %strip first space
% latlon=latlon(2:end);
% end
% i=1;
% latend=[];
% while latlon(i)~=' '
% latend=['',latend,'',latlon(i),''];
% i=i+1;
% end
% lonend=str2num(latlon(i:end));
% latend=str2num(latend);
% 
% startyear=str2num(starttime(1:2));
% bottyear=str2num(bottomtime(1:2));
% endyear=str2num(endtime(1:2));
% startday=str2num(starttime(3:5));
% bottday=str2num(bottomtime(3:5));
% endday=str2num(endtime(3:5));
% starthour=str2num(starttime(6:7));
% botthour=str2num(bottomtime(6:7));
% endhour=str2num(endtime(6:7));
% startmin=str2num(starttime(8:9));
% bottmin=str2num(bottomtime(8:9));
% endmin=str2num(endtime(8:9));
% 
% dbyear=bottyear-startyear;
% deyear=endyear-startyear;
% dbday=bottday-startday;
% deday=endday-startday;
% dbhour=botthour-starthour;
% dehour=endhour-starthour;
% dbmin=bottmin-startmin;
% demin=endmin-startmin;
% 
% btime=dbyear*365*24+dbday*24+dbhour+dbmin/60;
% etime=deyear*365*24+deday*24+dehour+demin/60;
% 
% 
% 
% %check on positions. Won't work for tow-yos - comment out
% dist1=sw_dist([latstart latbott],[lonstart lonbott]);
% dist2=sw_dist([latstart latend],[lonstart lonend]);
% eval(['disp(''',num2str(dist1),'nm covered during downcast in ',num2str(btime),' hours'')'])
% eval(['disp(''',num2str(dist2),'nm covered during whole cast in ',num2str(etime),' hours'')'])
% if dist1>0.5|dist2>0.5
%     disp('**warning! drift of over half a mile during cast, check positions**')
%     poscheck=input('Enter 1 if you believe positions ');
%     if poscheck==1
%         if dist1>3|dist2>3
%     disp('**warning! drift is over 3 miles, are you really sure about the positions?!')
%     poscheck=input('Enter 1 if you still believe positions ');
%         end
%     end
%         if poscheck~=1
%             error('positions wrong, try again (no output file created)')
%         end
% end
%     
% if btime>2|etime>5
%     disp('**warning! very long cast, check times**')
%     poscheck=input('Enter 1 if you believe times ');
%     if poscheck==1
%         if btime>3|etime>7
%     disp('**warning!very very long cast, are you really sure about the times?!')
%     poscheck=input('Enter 1 if you still believe times ');
%         end
%     end
%         if poscheck~=1
%             error('times wrong, try again (no output file created)')
%         end
%     end

%latd=input('enter start latitude - degrees south\n');   %not in NMEA so has to be entered from log/posinfo
%latm=input('enter start latitude - minutes\n'); 
%lat=-latd-latm/60;    %note hard-wired minus signs!!!!!
%lond=input('enter start longitude - degrees west\n');
%lonm=input('enter start longitude - minutes\n'); 
%lon=-lond-lonm/60;
