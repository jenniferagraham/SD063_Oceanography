function break_loop=editctdGEN2(aaa,fileow)

% script to enable interactive despiking of CTD profiles and removal of
% surface soaking period of CTD
% HJV 12/07 - Major changes to make easier to use and remove data from all
% variables at beginning and end of the cast using pressure and
% conductivity. Also changed order to after offpress so that pressure
% offset found while pressure data still there and so pump-off data has
% already been removed.

if nargin<1
    aaa=input('Station number?\n','s');
elseif ~ischar(aaa)
    aaa=num2str(aaa);
end
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];
disp(['processing cast ',aaa])

CTDvarn

ctdsave=fullfile(dir_out,[cruise,'_ctd_',aaa,'.edt'])

if nargin<2
    fileow=0;
end
if exist(ctdsave,'file')
    if fileow==0
    crow=input('Output file exists, proceed? y/n \n','s');
    if crow~='y'
        disp('Script already run')
        break_loop=true;
        return;
    else
        disp('Output file will be overwritten')
    end
    end
end

% read input file containing variables
infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'.red'])   %was .wat but skipping offpress
load (infile,'-mat');


prdiff=diff(press);
prdiff=[NaN; prdiff];

k=0;
K=NaN*press;
%comment out if no intial soak e.g. tow yo

iimp=find(press==max(press));
kk=0;
maxp=0;   %find end of initial soak
maxnegdiff=0; %by finding index of maximum difference between pressure and previous higher max(pressure)
for j=1:iimp  %search from start to deepest pressure (normally overkill but some initial soaks can be deep if trying to warm the CTD up in UCDW - JR165)
    maxp=max(maxp,press(j));
    if maxp-press(j)>maxnegdiff
        if maxp>20&kk==0
            %jj=1 %as no intail soak
            kk=jj; %save previous datacycle if reached a max pressure deeper than usual initial soak
        end
        jj=j;
        %jj=1
    maxnegdiff=max(maxnegdiff,maxp-press(j));
    end
end

m=['Cast starts at datacycle ' ,num2str(jj),' at ',num2str(press(jj)),' dbar after initial soak'];
disp(m)
figure
plot(scan,press,'k.')
hold on
plot(scan(jj),press(jj),'g.')
dataconf=input('Is this datacycle correct or do you want to edit pressure? y/n/e?\n','s');
if dataconf=='e'
    newpres = interactive_edit_nointerp(scan,press,press);
    press=newpres;
    close all
    figure
 plot(scan,press,'k.')
hold on
plot(scan(jj),press(jj),'r.')
end

if isempty(dataconf)||(dataconf~='1'&&dataconf~='y')
    if kk>0
   m=['In that case the cast might start at datacycle ' ,num2str(kk),' at ',num2str(press(kk)),' dbar?'];
disp(m) 
plot(scan(kk),press(kk),'r.')
dataconf=input('Is this datacycle correct? y/n?\n','s');
if isempty(dataconf)||(dataconf=='1'||dataconf=='y')
    jj=kk;
    close
else
      plot(press,'k.')
     
jj = input('Enter datacycle of start of downcast after initial soak\n');
 close    
end
    else
      plot(press,'k.')
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
%added
if jj==1
    vpe=zeros(sv(1),1);
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

%} 
% stop inial soak check
clear iipremove


disp('Conductivity 1');
newcond1 = interactive_edit_nointerp(scan,cond1,press); %wants press, can take pumps, but cond bad first anyway, hence not automated

iip1=isnan(newcond1);   %indices of points without cond1
iipstart=0*iip1;
iipstart(1)=1;
iipend=0*iip1;
iipend(end)=iip1(end);
lp=length(iip1);
for i=1:lp-1
    iipstart(i+1)=iipstart(i)*iip1(i+1);
    iipend(lp-i)=iipend(lp-i+1)*iip1(lp-i);
    if iipstart(i+1)==0&iipend(lp-i)==0
        break
    end
end
 iipremove=iipstart|iipend;
       
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end

 %%%press(iipremove)=NaN; %probably ought to have been keeping press
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
    
disp('Conductivity 2');
newcond2 = interactive_edit_nointerp(scan,cond2,press);

iip1=isnan(newcond2);   %indices of points without cond2
iipstart=0*iip1;
iipstart(1)=1;
iipend=0*iip1;
iipend(end)=iip1(end);
lp=length(iip1);
for i=1:lp-1
    iipstart(i+1)=iipstart(i)*iip1(i+1);
    iipend(lp-i)=iipend(lp-i+1)*iip1(lp-i);
    if iipstart(i+1)==0&iipend(lp-i)==0
        break
    end
end
 iipremove=iipstart|iipend;
       
for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end

cond2 = newcond2; %cond2 in above loop so this must come afterwards

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
figure
plot(scan,cond1-cond2); hold on
pause
plot([scan(1),scan(end)],[0 0],'k')
ylim([-0.01 0.01])
pause
close all

end %exist(cond2)

%New oxygen edit section
if exist('oxygen_umol_kg','var')  %in case not present
%what abnout other oxygen vars? Nans out at end of section    
disp('Oxygen');
newoxygen_umol_kg = interactive_edit_nointerp(scan,oxygen_umol_kg,press);

iip1=isnan(newoxygen_umol_kg);   %indices of points without cond2
iipstart=0*iip1;
iipstart(1)=1;
iipend=0*iip1;
iipend(end)=iip1(end);
lp=length(iip1);
for i=1:lp-1
    iipstart(i+1)=iipstart(i)*iip1(i+1);
    iipend(lp-i)=iipend(lp-i+1)*iip1(lp-i);
    if iipstart(i+1)==0&iipend(lp-i)==0
        break
    end
end
 iipremove=iipstart|iipend;

for iv=1:length(vpe)
    if vpe(iv)==1
       eval([varnames{iv,1},'(iipremove)=NaN;']);
    end
end

oxygen_umol_kg = newoxygen_umol_kg; 

%    cond1(iipremove)=NaN; 
% temp1(iipremove)=NaN;
% temp2(iipremove)=NaN;
% par(iipremove)=NaN;
% fluor_ug_l(iipremove)=NaN;
 oxygen_ml_l(iipremove)=NaN; 
% oxy_umol_Kg(iipremove)=NaN;
 oxygen_V(iipremove)=NaN;
% BeamTrans(iipremove)=NaN;


clear newoxygen_umol_kg;
close all
clear h h2 h3
 
end
 


disp('Temperature 1');
plot(scan,temp1,'k.')
t1ok=input('data OK? y/n \n','s');
if t1ok=='y'
close all
else

newtemp1 = interactive_edit_nointerp(scan,temp1,press);
temp1 = newtemp1;
clear newtemp1;
close all
clear h h2 h3
end

if exist('temp2','var')
    
disp('Temperature 2');
plot(scan,temp2,'k.')
t2ok=input('data OK? y/n \n','s');
if t2ok=='y'
close all
else
    
newtemp2 = interactive_edit_nointerp(scan,temp2,press);
temp2 = newtemp2;
clear newtemp2;
close all
clear h h2 h3
end

disp('T1-T2')
figure
plot(scan,temp1-temp2); hold on
pause
plot([scan(1),scan(end)],[0 0],'k')
 ylim([-0.005 0.005])
 pause
close all
end %exist(temp2)

%calculate salinity as spikes most obvious in T/S space
C35=sw_c3515;
salin1=sw_salt(cond1/C35,temp1,press);  %for cond in S/m need a 10*
salin2=sw_salt(cond2/C35,temp2,press); 

disp('Temperature 1 Salinity 1');
plot(salin1,temp1,'k.'); hold on
ii=find(press==max(press));
plot(salin1(1:ii),temp1(1:ii),'b.')
t1ok=input('data OK? y/n \n','s');
if t1ok=='y'
close all
else

newtemp1 = interactive_edit_poly(salin1,temp1,press);
rr1 = isnan(newtemp1); %don't want salin (yet) but want to know what isn't there
cond2(rr1)=NaN;
temp2(rr1)=NaN; %very likely, it will be cond spikes but tidier to remove temp as well
clear newtemp1;
close all
clear h h2 h3
end

disp('Temperature 2 Salinity 2');
plot(salin2,temp2,'k.'); hold on
ii=find(press==max(press));
plot(salin2(1:ii),temp2(1:ii),'b.')
t1ok=input('data OK? y/n \n','s');
if t1ok=='y'
close all
else

newtemp2 = interactive_edit_poly(salin2,temp2,press);
rr2 = isnan(newtemp2); %don't want salin (yet) but want to know what isn't there
cond2(rr2)=NaN;
temp2(rr2)=NaN; %very likely, it will be cond spikes but tidier to remove temp
clear newtemp2;
close all
clear h h2 h3
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