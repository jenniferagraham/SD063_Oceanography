function break_loop=editctdGEN(aaa,fileow)

% script to enable interactive despiking of CTD profiles and removal of
% surface soaking period of CTD
% HJV 12/07 - Major changes to make easier to use and remove data from all
% variables at beginning and end of the cast using pressure and
% conductivity. Also changed order to after offpress so that pressure
% offset found while pressure data still there and so pump-off data has
% already been removed.

if nargin<1
    aaa=input('Cast number?\n','s');
elseif ~ischar(aaa)
    aaa=num2str(aaa);
end


CTDvarn

if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
if exist(eventsave,'file')
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(aai,2);
eee=num2str(eec,'%03d')
eee=['_',eee,];
else 
    eee=input('CastEvent table oddity, enter event number or set incEvent to 0 in CTDvarn\n','s');  %new cast
end
else
    disp('If you do not want event numbers in your file names')
    disp('Change incEvent to 0 in CTDvarn')
     eec=input('Event number?\n'); %start of cruise
     eee=num2str(eec,'%03d');
eee=['_',eee,];
end
end

padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];
disp(['processing cast ',aaa])


ctdsave=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.edt'])

if nargin<2
    fileow=0;
end
if exist(ctdsave,'file')
    if fileow==0
    crow=say_what(input('Output file exists, start with previous edits? y/n \n','s'));
    if crow==1
        disp('Using previous edits as starting point')
        infile=ctdsave
    else
        crow=say_what(input('Warning: you are about to overwrite previous edits, proceed? y/n \n','s'));
        if crow==1
            disp('Output file will be overwritten')
            infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.red'])   %was .wat but skipping offpress
        else
            disp('Script already run')
            break_loop=true;
            return;
        end
    end
    end
else
    infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.red'])   %was .wat but skipping offpress
end

% read input file containing variables
load (infile,'-mat');


prdiff=diff(press);
prdiff=[NaN; prdiff];

k=0;
K=NaN*press;

[~,iimp]=max(press);
kk=0;
jj=1; % in case we don't have a pass before reaching our soak pressure, e.g. if the software is restarted during soak (EPA, SD041)
maxp=0;   %find end of initial soak
maxnegdiff=0; %by finding index of maximum difference between pressure and previous higher max(pressure)
for j=1:iimp  %search from start to deepest pressure (normally overkill but some initial soaks can be deep if trying to warm the CTD up in UCDW - JR165)
    maxp=max(maxp,press(j));
    if maxp-press(j)>=maxnegdiff
        if maxp>25&kk==0
            kk=jj; %save previous datacycle if reached a max pressure deeper than usual initial soak
        end
        jj=j;
        
    maxnegdiff=max(maxnegdiff,maxp-press(j));
    end
end

m=['Cast starts at datacycle ' ,num2str(jj),' at ',num2str(press(jj)),' dbar after initial soak'];
disp(m)
figure
plot(scan,press,'k.');
hold on
plot(scan(jj),press(jj),'g.','MarkerSize',20);
drawnow;
dataconf=input(['Is this datacycle correct? \n' ...
    'y = all is good!\n' ...
    'n = no, choose another start point\n' ...
    'e = no, edit the pressure profile\n'],'s');

% edit the pressure profile
if dataconf=='e'
var_name = 'Pressure'
    newpres = interactive_edit_nointerp(scan,press,press,var_name);
    press=newpres;
    close all
    figure
    plot(scan,press,'k.')
    hold on
    plot(scan(jj),press(jj),'r.')
end

%edit the start of the profile
if isempty(dataconf)||(dataconf~='1'&&dataconf~='y')
  if kk>0
    m=['In that case the cast might start at datacycle ' ,num2str(kk),' at ',num2str(press(kk)),' dbar?'];
    disp(m) 
    plot(scan(kk),press(kk),'r.')
    drawnow;
    dataconf=say_what(input('Is this datacycle correct? y/n?\n','s'));
    if dataconf==1
        jj=kk;
        close
    else
        plot(press,'k.')
        drawnow;
        jj = input('Enter datacycle of start of downcast after initial soak\n');
        close    
    end
  else
    plot(press,'k.');
    drawnow;
    jj = input('Enter datacycle of start of downcast after initial soak\n');
    close   
  end
else
    close
end

if jj~=1 %in case CTD switched on when already going down
  
iipremove=1:(jj-1);

iic=find(strcmp(columnuse,'edit_vars'));
sv=size(varnames);
     vpe=zeros(sv(1),1);
     for iv=1:sv(1)
         vpe(iv)=(varnames{iv,2}*varnames{iv,iic})>0;        
     end
   
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end


end
                                 %%data best removed from all variables due to start effects
% cond1(iipremove)=NaN;        %remove the 10 metre soaking using pressure, leaving data at surface
% cond2(iipremove)=NaN;        %remove data at surface before any low conductivities as most sensitive measurement of CTD package leaving the water
% temp1(iipremove)=NaN;        %do that at beginning and end of cast
% temp2(iipremove)=NaN;        %apply removal to all measured variables
% 
% 
% par(iipremove)=NaN;         %needs fixing for generalised variables
% fluor_ug_l(iipremove)=NaN;
% 
% oxy_ml_l(iipremove)=NaN;   
% oxy_umol_Kg(iipremove)=NaN;
% oxy_raw(iipremove)=NaN;
% BeamTrans(iipremove)=NaN;

clear iipremove
var_name = 'Conductivity 1'

newcond1 = interactive_edit_nointerp(scan,cond1,press,var_name); %wants press, can take pumps, but cond bad first anyway, hence not automated

iip1=isnan(newcond1);   %indices of points without cond1
iipstart=0*iip1;
% iipstarthold=iipstart;
iipstart(1)=1;
iipend=0*iip1;
% iipendhold=iipend;
iipend(end)=iip1(end);
lp=length(iip1);
for i=1:lp-1
    iipstart(i+1)=iipstart(i)*iip1(i+1);
    % if iipstart(i+1)==1&&press(i+1)>1
    %     iipstarthold=iipstart;
    %     iipstart=0*iipstart;
    % end
    iipend(lp-i)=iipend(lp-i+1)*iip1(lp-i);
    % if iipend(lp-i)==1&&press(lp-i)>1
    %     iipendhold=iipend;
    %     iipend=0*iipend;
    % end
    if iipstart(i+1)==0&iipend(lp-i)==0
        break
    end
end

 iipremove=(iipstart|iipend);  

iipend=iipend>0;
max(press(iipend))
 if max(press(iipend))>1 %data removed for pressure >1db - odd cast, deep soak or individually bad sensor?
    wipeflag=say_what(input('Large depth range edited, remove from other sensors? y/n \n','s'));
    if wipeflag==0
        iipremove=0*iipremove;
    end
 end
       
 

       
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end


%%%%%press(iipremove)=NaN;
%     cond2(iipremove)=NaN; 
% temp1(iipremove)=NaN;
% temp2(iipremove)=NaN;
% par(iipremove)=NaN;
% fluor_ug_l(iipremove)=NaN;
% oxy_ml_l(iipremove)=NaN;
% oxy_umol_Kg(iipremove)=NaN;
% oxy_raw(iipremove)=NaN;
% BeamTrans(iipremove)=NaN;

cond1 = newcond1; %this has to come after the iipremove bit (as cond1 included in loop)

clear newcond1;
close all
clear h h2 h3
clear iipstart iipend  iipremove

if exist('cond2','var')  %in case not present
    
var_name = 'Conductivity 2'
newcond2 = interactive_edit_nointerp(scan,cond2,press, var_name);

iip1=isnan(newcond2);   %indices of points without cond2
iipstart=0*iip1;
iipstart(1)=1;
iipend=0*iip1;
iipend(end)=iip1(end);
lp=length(iip1);
for i=1:lp-1
    iipstart(i+1)=iipstart(i)*iip1(i+1);
     if iipstart(i+1)==1&&press(i+1)>1
        iipstart=0*iipstart;
    end
    iipend(lp-i)=iipend(lp-i+1)*iip1(lp-i);
      if iipend(lp-i)==1&&press(lp-i)>1
        iipend=0*iipend;
    end
    if iipstart(i+1)==0&iipend(lp-i)==0
        break
    end
end
 iipremove=iipstart|iipend;

 iipend=iipend>0;
max(press(iipend))
 if max(press(iipend))>1 %data removed for pressure >1db - odd cast, deep soak or individually bad sensor?
    wipeflag=say_what(input('Large depth range edited, remove from other sensors? y/n \n','s'));
    if wipeflag==0
        iipremove=0*iipremove;
    end
 end
       
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end

cond2 = newcond2; %cond2 in above loop so this must come afterwards

%%%%press(iipremove)=NaN;
%    cond1(iipremove)=NaN; 
% temp1(iipremove)=NaN;
% temp2(iipremove)=NaN;
% par(iipremove)=NaN;
% fluor_ug_l(iipremove)=NaN;
% oxy_ml_l(iipremove)=NaN;
% oxy_umol_Kg(iipremove)=NaN;
% oxy_raw(iipremove)=NaN;
% BeamTrans(iipremove)=NaN;


clear newcond2;
close all
clear h h2 h3

disp('C1-C2')
figure;
plot(scan,cond1-cond2); 
title('C1-C2')
hold on
pause
plot([scan(1),scan(end)],[0 0],'k')
ylim([-0.01 0.01])
title('C1-C2 [zoomed in]')
pause
close all

end %exist(cond2)

var_name = 'Temperature 1'
figure;
plot(scan,temp1,'k.')
title(var_name)
drawnow
t1ok=say_what(input('data OK? y/n \n','s'));
if t1ok==1
close all
else

newtemp1 = interactive_edit_nointerp(scan,temp1,press, var_name);
temp1 = newtemp1;
clear newtemp1;
close all
clear h h2 h3
end

if exist('temp2','var')

    var_name = 'Temperature 2'
    figure;
    plot(scan,temp2,'k.');
    title(var_name)
    drawnow;
    t2ok=say_what(input('data OK? y/n \n','s'));
    if t2ok==1
        close all
    else
        newtemp2 = interactive_edit_nointerp(scan,temp2,press, var_name);
        temp2 = newtemp2;
        clear newtemp2;
        close all
        clear h h2 h3
    end
    
    disp('T1-T2')
    figure;
    plot(scan,temp1-temp2);
    title("T1 - T2")
    hold on
    pause
    plot([scan(1),scan(end)],[0 0],'k')
    ylim([-0.005 0.005])
    title("T1 - T2 [zoomed in]")
    pause
    close all

end %exist(temp2)

% Oxygen

if exist('oxygen1_umol_kg','var') % at least one oxygen sensor

    var_name = 'Oxygen 1'
    figure;
    plot(scan,oxygen1_umol_kg,'k.')
    title(var_name)
    drawnow
    t1ok=say_what(input('data OK? y/n \n','s'));
    if t1ok==1
    close all
    else
    
    newoxy1 = interactive_edit_nointerp(scan,oxygen1_umol_kg,press, var_name);
    oxygen1_umol_kg = newoxy1;
    clear newoxy1;
    close all
    clear h h2 h3
    end

elseif exist('oxygen_umol_kg','var') % only one oxygen sensor

    var_name = 'Oxygen 1'
    figure;
    plot(scan,oxygen_umol_kg,'k.')
    title(var_name)
    drawnow
    t1ok=say_what(input('data OK? y/n \n','s'));
    if t1ok==1
    close all
    else
    
    newoxy1 = interactive_edit_nointerp(scan,oxygen_umol_kg,press, var_name);
    oxygen_umol_kg = newoxy1;
    clear newoxy1;
    close all
    clear h h2 h3
    end

end

if exist('oxygen2_umol_kg','var') % we have a secondary oxygen sensor!

    var_name = 'Oxygen 2'
    figure;
    plot(scan,oxygen2_umol_kg,'k.');
    title(var_name)
    drawnow;
    t2ok=say_what(input('data OK? y/n \n','s'));
    if t2ok==1
        close all
    else
        newoxy2 = interactive_edit_nointerp(scan,oxygen2_umol_kg,press, var_name);
        oxygen2_umol_kg = newoxy2;
        clear newoxy2;
        close all
        clear h h2 h3
    end
    
    disp('Oxygen1 - Oxygen2')
    figure;
    plot(scan,oxygen1_umol_kg-oxygen2_umol_kg);
    title('Oxygen1 - Oxygen2')
    hold on
    pause
    % plot([scan(1),scan(end)],[0 0],'k')
    % ylim([-0.005 0.005])
    % pause
    close all

end %exist(oxygen2_umol_kg2)

% Apply oxygen hysteresis correction
% disp('Apply oxygen hysteresis correction (SBE default parameters)')
% ox1_hyst_nonan = oxygenhysteresis(time_elapsed(~isnan(oxygen1_umol_kg)),press(~isnan(oxygen1_umol_kg)),oxygen1_umol_kg(~isnan(oxygen1_umol_kg))) ; % using SBE default parameters for now
% ox2_hyst_nonan = oxygenhysteresis(time_elapsed(~isnan(oxygen2_umol_kg)),press(~isnan(oxygen2_umol_kg)),oxygen2_umol_kg(~isnan(oxygen2_umol_kg))) ;
% 
% ox1_hyst = NaN*zeros(size(oxygen1_umol_kg)) ;
% ox1_hyst(~isnan(oxygen_umol_kg)) = ox1_hyst_nonan ; clear ox1_hyst_nonan ;
% ox2_hyst = NaN*zeros(size(oxygen2_umol_kg)) ;
% ox2_hyst(~isnan(oxygen2_umol_kg)) = ox2_hyst_nonan ; clear ox2_hyst_nonan ;
% 
% disp('Oxygen 1');
% figure;
% plot(scan,oxygen_umol_kg,'k.')
% hold on; plot(scan,ox1_hyst,'r.')
% drawnow
% pause; hold off
% plot(scan,ox1_hyst-oxygen_umol_kg,'k.'); title('with hyst. corr. minus without')
% t1ok=input('Apply oxygen hysteresis? y/n \n','s');
% if t1ok=='y'
%     oxygen1_umol_kg = ox1_hyst ;
%     close all
% else
%     clear ox1_hyst;
%     close all
% end
% 
% disp('Oxygen 2');
% figure;
% plot(scan,oxygen2_umol_kg,'k.')
% hold on; plot(scan,ox2_hyst,'r.')
% drawnow
% pause; hold off
% plot(scan,ox2_hyst-oxygen2_umol_kg,'k.'); title('with hyst. corr. minus without')
% t1ok=input('Apply oxygen hysteresis? y/n \n','s');
% if t1ok=='y'
%     oxygen2_umol_kg = ox2_hyst ;
%     close all
% else
%     clear ox2_hyst;
%     close all
% end


%calculate salinity as spikes most obvious in T/S space
% C35=sw_c3515;
% salin1=sw_salt(cond1/C35,temp1,press);  %for cond in S/m need a 10*

salin1=gsw_SP_from_C(cond1,temp1,press);  %for cond in S/m need a 10*
if exist('cond2','var')  %in case not present
    salin2=gsw_SP_from_C(cond2,temp2,press); 
end
disp('T/S 1');
var_name = 'Temperature 1 Salinity 1';
figure;
plot(salin1,temp1,'k.');
title(var_name)
hold on
[~,ii]=max(press);
plot(salin1(1:ii),temp1(1:ii),'b.')
drawnow;
t1ok=say_what(input('data OK? y/n \n','s'));
if t1ok==1
    close all
else
    newtemp1 = interactive_edit_poly(salin1,temp1,press, var_name);
    rr1 = isnan(newtemp1); %don't want salin (yet) but want to know what isn't there
    cond1(rr1)=NaN;
    temp1(rr1)=NaN; %very likely, it will be cond spikes but tidier to remove temp as well
    clear newtemp1;
    close all
    clear h h2 h3
end

if exist('salin2','var') && exist('temp2','var')  %in case not present
    disp('T/S 2');
var_name = 'Temperature 2 Salinity 2';
figure;
plot(salin2,temp2,'k.');
hold on
[~,ii]=max(press);
plot(salin2(1:ii),temp2(1:ii),'b.')
title(var_name)
drawnow;
t1ok=say_what(input('data OK? y/n \n','s'));
if t1ok==1
    close all
else
    newtemp2 = interactive_edit_poly(salin2,temp2,press, var_name);
    rr2 = isnan(newtemp2); %don't want salin (yet) but want to know what isn't there
    cond2(rr2)=NaN;
    temp2(rr2)=NaN; %very likely, it will be cond spikes but tidier to remove temp
    clear newtemp2;
    close all
    clear h h2 h3
end
end

%HJV - does anything go wrong without this? Don't like creating numbers
%when removed a large chunk due to pumps going off mid cast. If just a
%3-point spike then can carry on without it anyway.
%Seems everything runs through, just with gaps.

% a= find(isfinite(temp1)& isnan(cond1));
% temp1new = interp1(scan(a),temp1(a),scan); 
% cond1new = interp1(scan(a),cond1(a),scan);   
% temp1 = temp1new;
% cond1 = cond1new;
% a = find(isfinite(temp2)& isnan(cond2));
% temp2new = interp1(scan(a),temp2(a),scan);   
% cond2new = interp1(scan(a),cond2(a),scan);   
% temp2 = temp2new;
% cond2 = cond2new;

% vars='alt bottles cond1 cond2 flag fluor_ug_l oxy_ml_l par trans press pumps scan temp1 temp2 time_elapsed';
% 
% eval(['save ' ctdsave ' ' vars ' sensors names gtime starttime bottomtime endtime latstart lonstart latbott lonbott latend lonend'])

save (ctdsave,'names','gtime','lat','lon',varnames{(vp==1),1})

if nargout>0
    break_loop=false;
end
