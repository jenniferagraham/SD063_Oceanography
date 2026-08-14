function break_loop=salcalappGEN(aaa)

% salcal has already calculated the adjustment to nominally calibrated CTD salinity
% required to get best fit to bottle data
% salcalapp reads the offsets already in the botnnn.sal files and
% adds them to the ctdconductivities in the ctdnnn.int and bot files.
%
% modified mmm, Feb 2007

if nargin<1
    aaa=input('Station number?\n','s');
elseif ~ischar(aaa)
    aaa=num2str(aaa);
end
stano=floor(str2double(aaa)); % integer station number
padzeros=max([3-length(aaa),4-strfind(aaa,'.')]);
aaa=[repmat('0',1,padzeros),aaa];
aaa(aaa=='.')=[];
disp(['processing cast ',aaa])

CTDvarn
if ~(strcmp(ctchoice,'1')||strcmp(ctchoice,'2'))
    error('ctchoice must be set in CTDvarn, and must be ''1'' or ''2''.');
end

if incEvent
    eventsave=fullfile(dir_out,[,cruise,'_ctd_CastEventList.mat']);
load (eventsave,'-mat');
aac=str2num(aaa);
aai=find(CastEvent(:,1)==aac);
if ~isempty(aai)
eec=CastEvent(aai,2);
eee=num2str(eec,'%03d');
eee=['_',eee,];
else
   disp('Cast missing or CastEvent table missing/wrong')
   eee=''; %so can write a filename, and then find it doesn't exist
end

end

%% define the offsets for our cruise

%if function handle points to a full function rather than being in-line, 
%copy and paste function into calibration text file
%temperature fits should be copied from tempcalbottGEN

switch(cruise)
    case 'SD046'
        condoffset1fcn =  @Condoffset2_sd046;
        condoffset2fcn = @(press,temp,cond,stano,gtime) interp1([0 2750 5000 6200],[0.0008 -0.0009 -0.0009 -0.0003],press);
         tempoffset1fcn = @(press,temp,cond,stano,gtime) interp1([0 2000 6200],[0.00055 -0.00065 -0.00065],press);
        tempoffset2fcn = @(press,temp,cond,stano,gtime) interp1([0 2000 6200],[-0.00025 -0.00125 -0.00125],press); 
        oxygenoffset1fcn = @oxygenoffset1_sd046;
        oxygenoffset2fcn = @oxygenoffset2_sd046;
        
    case 'SD041' 
        condoffset1fcn = @(press,temp,cond,stano,gtime) +0.0013;
        condoffset2fcn = @(press,temp,cond,stano,gtime) +0.0074;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.0008;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.0020;
        oxygenoffset1fcn = @(press,temp,oxygen,stano,gtime) oxygen*(0.9944-1)-7.8717; % from SD035
        oxygenoffset2fcn = @oxygenoffset2_sd041; % from SD035 (with further offsets for sn 3634)
        % oxygenoffset2fcn = @(press,temp,oxygen,stano,gtime) +2;
    case 'ER041' %
        condoffset1fcn = @(press,temp,cond,stano,gtime) -0.005;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) 0;
        oxygenoffset1fcn = @(press,temp,oxygen,stano,gtime) 0;
        phcalfcn = @(pH_orig,temp) ((pH_orig-7).*4.6340.*(temp+273.15).*1.98416e-4+2.5440-2.6512)./(3.4905*(temp+273.15).*1.98416e-4)+7;
        fluoroffsetfcn = @(fluor) 0.05;
    case 'SD033' % MB wrote separate scripts "apply_cal_C/O/T", but including here for reference
                 % note that MB's offsets are in the other direction - subtracted rather than added!
        condoffset1fcn = @(press,temp,cond,stano,gtime) -2.3059e-4;
        condoffset2fcn = @(press,temp,cond,stano,gtime) -0.0011;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.0038;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.0012;
        oxygenoffset1fcn = @(press,temp,oxygen,stano,gtime) 0; % no offset applied in MB's scripts from cruise?!
        oxygenoffset2fcn = @(press,temp,oxygen,stano,gtime) 0; % no offset applied in MB's scripts from cruise?!
    case 'DY158'
%        condoffset1fcn = @(press,temp,cond,stano,gtime) -0.0011037 - 5.2542e-07*press;  %DY158
%        condoffset2fcn = @(press,temp,cond,stano,gtime) -0.00023016 - 3.8973e-07*press;
        condoffset1fcn = @(press,temp,cond,stano,gtime) -0.001899 - 5.801e-07*press;  %DY158
        condoffset2fcn = @(press,temp,cond,stano,gtime) -0.0010264 - 4.4412e-07*press;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.00092111 - 6.8736e-08*press;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.00068805 - 2.63e-07*press;      
    case 'DY113'
        condoffset1fcn = @(press,temp,cond,stano,gtime) (interp1([0 5000],[-1.8e-3 -6.5e-3],press) - 7.2e-4).*cond./35;
        condoffset2fcn = @(press,temp,cond,stano,gtime) (interp1([0 5000],[1.4e-3 -2e-3],press) - 7e-4).*cond./35;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -1.5e-5*stano - (1.5e-3/5000)*press - 1.1e-4;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -1e-5*stano - 3.8e-4;
        oxygenoffset1fcn = @(press,temp,oxygen,stano,gtime) 0.025*oxygen + interp1([0 5000],[1.5 12.5],press) - 2e-2*stano - 0.1;
        oxygenoffset2fcn = @(press,temp,oxygen,stano,gtime) 0.029*oxygen + interp1([0 500 5000],[1.5 1.8 10],press) - 1.4;

%         condoffset1fcn = @(press,temp,cond,stano,gtime) -0.001-(0.0055/5000)*press-(datenum(gtime)-datenum(2020,2,8))*.00012;  % DY113 preliminary cal on 22 Feb 2020
%         condoffset2fcn = @(press,temp,cond,stano,gtime) 0.001-(0.0034/5000)*press-(datenum(gtime)-datenum(2020,2,8))*.0001;  % DY113 preliminary cal on 22 Feb 2020
%         tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.00075-(0.00125/5000)*press;
%         tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.0006;
    case 'JR18004'
        condoffset1fcn = @condoffset1_jr18004;
        condoffset2fcn = @condoffset2_jr18004;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) +0.00054004;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.0011;
    case 'JR17003'
        condoffset1fcn = @(press,temp,cond,stano,gtime) -0.0012-(0.0032/5000)*press;  %JR17003
        condoffset2fcn = @(press,temp,cond,stano,gtime) 0.000-(0.0024/5000)*press;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.001357;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.0004895;
    case 'JR310'
        condoffset1fcn = @condoffset1_jr310;  %JR310
        condoffset2fcn = @condoffset2_jr310;
        tempoffset1fcn = @(press,temp,cond,stano,gtime) -0.00086;
        tempoffset2fcn = @(press,temp,cond,stano,gtime) -0.00073;
    otherwise
        error('Cruise %s not defined in salcalapp!',cruise)
end

% check if dual T/C sensors are installed, and adjust output variables appropriately...

if exist('condoffset2fcn','var') && exist('tempoffset2fcn','var')
    disp('Two bottle sensor mode')
    botcalvars={'condoffset1','condoffset2','tempoffset1','tempoffset2',...
        'ctdcond1_uncal','ctdcond2_uncal','ctdtemp1_uncal','ctdtemp2_uncal'};
    castcalvars={'condoffset1','condoffset2','tempoffset1','tempoffset2',...
        'cond1_uncal','cond2_uncal','temp1_uncal','temp2_uncal'};
else
    disp('One bottle sensor mode')
    botcalvars={'condoffset1','tempoffset1','ctdcond1_uncal','ctdtemp1_uncal'};
    castcalvars={'condoffset1','tempoffset1','cond1_uncal','temp1_uncal'};
end    
if exist('oxygenoffset1fcn','var')
    botcalvars={botcalvars{:},'oxygenoffset1','ctdoxygen1_umol_kg_uncal'};
    castcalvars={castcalvars{:},'oxygenoffset1','oxygen1_umol_kg_uncal'};
    if exist('oxygenoffset2fcn','var')
        botcalvars={botcalvars{:},'oxygenoffset2','ctdoxygen2_umol_kg_uncal'};
        castcalvars={castcalvars{:},'oxygenoffset2','oxygen2_umol_kg_uncal'};
    end
end
if exist('phcalfcn','var')
    botcalvars={botcalvars{:},'phoffset','ctdph_uncal'};
    castcalvars={castcalvars{:},'phoffset','ph_uncal'};
end
if exist('fluoroffsetfcn','var')
    botcalvars={botcalvars{:},'fluoroffset','ctdfluor_ug_l_uncal'};
    castcalvars={castcalvars{:},'fluoroffset','fluor_ug_l_uncal'};
end

%% apply calibrations to bottle file

disp('applying calibrations to bottle file')

% load file containing bottle salinity, CTD conductivity, CTD temperature,
% and CTD pressure data
infile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.all'])
otfile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.cal'])


if exist(infile,'file') %skip bottle section if salcal & mergebot not run (no bottle file)
    
    load (infile,'-mat');

    ctdcond1_uncal=ctdcond1;  %keep original values
    ctdtemp1_uncal=ctdtemp1;

     condoffset1=feval(condoffset1fcn,ctdpress,ctdtemp1,ctdcond1,stano,gtime);
    if isscalar(condoffset1)
        condoffset1=repmat(condoffset1,size(ctdcond1));
    end
    ctdcond1=ctdcond1+condoffset1;

     tempoffset1=feval(tempoffset1fcn,ctdpress,ctdtemp1,ctdcond1,stano,gtime);
    if isscalar(tempoffset1)
        tempoffset1=repmat(tempoffset1,size(ctdtemp1));
    end
    ctdtemp1=ctdtemp1+tempoffset1;

    if exist('ctdtemp2','var') && exist('ctdcond2','var')
    ctdtemp2_uncal=ctdtemp2;
    ctdcond2_uncal=ctdcond2;

    condoffset2=feval(condoffset2fcn,ctdpress,ctdtemp2,ctdcond2,stano,gtime);
    if isscalar(condoffset2)
        condoffset2=repmat(condoffset2,size(ctdcond2));
    end
    ctdcond2=ctdcond2+condoffset2;

     tempoffset2=feval(tempoffset2fcn,ctdpress,ctdtemp2,ctdcond2,stano,gtime);
    if isscalar(tempoffset2)
        tempoffset2=repmat(tempoffset2,size(ctdtemp2));
    end
    ctdtemp2=ctdtemp2+tempoffset2;

    end
       
    ctdtemp=eval(['ctdtemp',ctchoice]); %if you choose 2 when only one sensor you deserve the code crashing


ctdsalin1=gsw_SP_from_C(ctdcond1,ctdtemp1,ctdpress);  %for cond in S/m need a 10*

% ii=press<-1.5;  %bottle pressure of <-1.5 is something you should probably worry about
% press(ii)=-1.5; %These are out of the water (probably)
% if sum(isfinite(cond1(ii)))
% warning('pressure <-1.5 in water, adjusted')
% end
ctdasalin1 = gsw_SA_from_SP(ctdsalin1,ctdpress,blon,blat);
if exist('ctdtemp2','var') && exist('ctdcond2','var')
    ctdsalin2=gsw_SP_from_C(ctdcond2,ctdtemp2,ctdpress);
ctdasalin2 = gsw_SA_from_SP(ctdsalin2,ctdpress,blon,blat);
end
ctdsalin=eval(['ctdsalin',ctchoice]);
ctdasalin=eval(['ctdasalin',ctchoice]);

%potemp1=sw_ptmp(salin1,temp1,press,0);
ctdpotemp1 = gsw_pt_from_t(ctdasalin1,ctdtemp1,ctdpress,0);
 ctdCtemp1 = gsw_CT_from_t(ctdasalin1,ctdtemp1,ctdpress);
if exist('ctdtemp2','var') && exist('ctdcond2','var')
    %potemp2=sw_ptmp(salin2,temp2,press,0);
    ctdpotemp2 = gsw_pt_from_t(ctdasalin2,ctdtemp2,ctdpress,0);

 ctdCtemp2 = gsw_CT_from_t(ctdasalin2,ctdtemp2,ctdpress);
end
ctdpotemp=eval(['ctdpotemp',ctchoice]);
ctdCtemp=eval(['ctdCtemp',ctchoice]);

ctdsig0= gsw_sigma0(ctdasalin,ctdCtemp);
ctdsig2= gsw_sigma2(ctdasalin,ctdCtemp);
ctdsig4= gsw_sigma4(ctdasalin,ctdCtemp);

     
    if exist('oxygenoffset1fcn','var')
        oxygenoffset1=feval(oxygenoffset1fcn,ctdpress,ctdtemp1,ctdoxygen1_umol_kg,stano,gtime);
        if isscalar(oxygenoffset1)
            oxygenoffset1=repmat(oxygenoffset1,size(ctdoxygen1_umol_kg));
        end
        ctdoxygen1_umol_kg_uncal=ctdoxygen1_umol_kg;
        ctdoxygen1_umol_kg=ctdoxygen1_umol_kg+oxygenoffset1;
        if exist('oxygenoffset2fcn','var')
            oxygenoffset2=feval(oxygenoffset2fcn,ctdpress,ctdtemp2,ctdoxygen2_umol_kg,stano,gtime);
            if isscalar(oxygenoffset2)
                oxygenoffset2=repmat(oxygenoffset2,size(ctdoxygen2_umol_kg));
            end
            ctdoxygen2_umol_kg_uncal=ctdoxygen2_umol_kg;
            ctdoxygen2_umol_kg=ctdoxygen2_umol_kg+oxygenoffset2;
        end
        ctdoxygen_umol_kg=eval(['ctdoxygen',ctchoice,'_umol_kg']);
    end

    if exist('ctdph','var') && exist('ph_calfcn','var')
        ctdph_uncal=ctdph;
        ph=feval(phcalfcn,ph,ctdtemp);
    end
    if exist('ctdfluor_ug_l','var') && exist('fluoroffsetfcn','var')
        ctdfluor_ug_l_uncal=ctdfluor_ug_l;
        fluoroffset=feval(fluoroffsetfcn,ctdfluor_ug_l);
        ctdfluor_ug_l=ctdfluor_ug_l+fluoroffset;
    end

    save(otfile,'botno','lat','lon','gtime',botcalvars{:},...
        varbotnames{(vpd_bot==1),1});

end %skip bottle section if salcal not run (no bottle file)

%% apply calibrations to CTD file

disp('applying calibrations to CTD file')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load file containing CTD data

infile=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.var'])  %was .edt before, but this is problematic, as hysteresis correction is applied in derive, after .edt!
ctdsave=fullfile(dir_out,[cruise,'_ctd_',aaa,'',frame_fileadd,'',eee,'.clb'])
txtfile=fullfile(dir_out,[cruise,'_ctd',frame_fileadd,'_calibrations.txt'])
if exist(infile, 'file') 
load (infile,'-mat');

cond1_uncal=cond1;  %keep original values
temp1_uncal=temp1;

condoffset1=feval(condoffset1fcn,press,temp1,cond1,stano,gtime);
if isscalar(condoffset1)
    condoffset1=repmat(condoffset1,size(cond1));
end
cond1=cond1+condoffset1;

tempoffset1=feval(tempoffset1fcn,press,temp1,cond1,stano,gtime);
if isscalar(tempoffset1)
    tempoffset1=repmat(tempoffset1,size(temp1));
end
temp1=temp1+tempoffset1;

if exist('temp2','var') && exist('cond2','var')
disp('two CTD T/C sensors')
    cond2_uncal=cond2;
    temp2_uncal=temp2;
    condoffset2=feval(condoffset2fcn,press,temp2,cond2,stano,gtime);
    if isscalar(condoffset2)
        condoffset2=repmat(condoffset2,size(cond2));
    end
    cond2=cond2+condoffset2;
    tempoffset2=feval(tempoffset2fcn,press,temp2,cond2,stano,gtime);
    if isscalar(tempoffset2)
        tempoffset2=repmat(tempoffset2,size(temp2));
    end
    temp2=temp2+tempoffset2;
end
temp=eval(['temp',ctchoice]);

salin1=gsw_SP_from_C(cond1,temp1,press);  %for cond in S/m need a 10*
ii=press<-1.5;
press(ii)=-1.5; %These are out of the water (probably)
if sum(isfinite(cond1(ii)))
warning('pressure <-1.5 in water, adjusted')
end
asalin1 = gsw_SA_from_SP(salin1,press,lon,lat);
if exist('temp2','var') && exist('cond2','var')
    salin2=gsw_SP_from_C(cond2,temp2,press);
asalin2 = gsw_SA_from_SP(salin2,press,lon,lat);
end
salin=eval(['salin',ctchoice]);
asalin=eval(['asalin',ctchoice]);

%potemp1=sw_ptmp(salin1,temp1,press,0);
potemp1 = gsw_pt_from_t(asalin1,temp1,press,0);
 Ctemp1 = gsw_CT_from_t(asalin1,temp1,press);
if exist('temp2','var') && exist('cond2','var')
    %potemp2=sw_ptmp(salin2,temp2,press,0);
    potemp2 = gsw_pt_from_t(asalin2,temp2,press,0);

 Ctemp2 = gsw_CT_from_t(asalin2,temp2,press);
end
potemp=eval(['potemp',ctchoice]);
Ctemp=eval(['Ctemp',ctchoice]);


if exist('oxygen_umol_kg','var') && ~exist('oxygen1_umol_kg','var')
    oxygen1_umol_kg=oxygen_umol_kg;
    % oxygen1_V=oxygen_V;
end

if exist('oxygenoffset1fcn','var')
    oxygenoffset1=feval(oxygenoffset1fcn,press,temp1,oxygen1_umol_kg,stano,gtime);
    if length(oxygenoffset1)==1
        oxygenoffset1=repmat(oxygenoffset1,size(oxygen1_umol_kg));
    end
    oxygen1_umol_kg_uncal=oxygen1_umol_kg;
    oxygen1_umol_kg=oxygen1_umol_kg+oxygenoffset1;
    if exist('oxygenoffset2fcn','var')
        oxygenoffset2=feval(oxygenoffset2fcn,press,temp2,oxygen2_umol_kg,stano,gtime);
        if length(oxygenoffset2)==1
            oxygenoffset2=repmat(oxygenoffset2,size(oxygen2_umol_kg));
        end
        oxygen2_umol_kg_uncal=oxygen2_umol_kg;
        oxygen2_umol_kg=oxygen2_umol_kg+oxygenoffset2;
    end
end

if exist('oxygen1_umol_kg','var') % && exist('oxygen2_umol_kg','var')
    oxygen_umol_kg=eval(['oxygen',ctchoice,'_umol_kg']);
end

if exist('ph','var') && exist('phcalfcn','var')
    ph_uncal=ph;
    ph=feval(phcalfcn,ph,temp);
    phoffset=ph-ph_uncal;
end

if exist('fluor_ug_l','var') && exist('fluoroffsetfcn','var')
    fluor_ug_l_uncal=fluor_ug_l;
    fluoroffset=feval(fluoroffsetfcn,fluor_ug_l);
    fluor_ug_l=fluor_ug_l+fluoroffset;
    if length(fluoroffset)==1
        fluoroffset=repmat(fluoroffset,size(fluor_ug_l));
    end
end

sigma0 = gsw_sigma0(asalin,Ctemp);
sigma2 = gsw_sigma2(asalin,Ctemp);
sigma4 = gsw_sigma4(asalin,Ctemp);

% sig0=sw_pden(salin,temp,press,0)-1000;
% sig2=sw_pden(salin,temp,press,2000)-1000;
% sig4=sw_pden(salin,temp,press,4000)-1000;

if ~exist('depth','var')
    depth=sw_dpth(press,lat);
end
 
save (ctdsave,'names','gtime','lat','lon',castcalvars{:},...
    varnames{(vpd==1),1})

if nargout>0
    break_loop=false;
end

%write offsets to an ascii file
%for the record, and use existence of ascii file as flag to run scripts in
%calibration mode
%one per cruise, could make it one per cast but you'd need to change every
%script as filename used as test of whether we are dealing with calibrated
%files
if exist(txtfile,'file')
   delete (txtfile); %start fresh each time.
end

str1='CTD calibration offsets';
str2=['for cruise ',cruise,''];
str3=' ';

str4='All offsets are Calibration Value minus CTD Values';
str5='so add them to CTD values to get calibrated values';
str5a='';

str6=['Temp1 offset: ',func2str(tempoffset1fcn),''];
str7=['Cond1 offset: ',func2str(condoffset1fcn),''];
if exist('temp2','var') && exist('cond2','var')
str8=['Temp2 offset: ',func2str(tempoffset2fcn),''];
str9=['Cond2 offset: ',func2str(condoffset2fcn),''];
end

if exist('oxygenoffset1','var')
str10=['Oxygen1 offset: ',func2str(oxygenoffset1fcn),''];
end
if exist('oxygenoffset2','var')
str11=['Oxygen2 offset: ',func2str(oxygenoffset2fcn),''];
end



eval(['fid = fopen(''',txtfile,''', ''w'');']);
fprintf(fid, '%s\r\n', str1);
fprintf(fid, '%s\r\n', str2);
fprintf(fid, '%s\r\n', str3);
fprintf(fid, '%s\r\n', str4);
fprintf(fid, '%s\r\n', str5);
fprintf(fid, '%s\r\n', str5a);
fprintf(fid, '%s\r\n', str6);
fprintf(fid, '%s\r\n', str7);
if exist('temp2','var') && exist('cond2','var')
fprintf(fid, '%s\r\n', str8);
fprintf(fid, '%s\r\n', str9);
end
if exist('oxygenoffset1','var')
fprintf(fid, '%s\r\n', str10);
end
if exist('oxygenoffset2','var')
fprintf(fid, '%s\r\n', str11);
end
fclose(fid);

else
    break_loop=true;
end
 
end

%% cruise-specific functions:

% remember to end your function with an "end"!

function offset=Condoffset2_sd046(press,temp,oxygen,stano,gtime)
if stano<=50
 x1=[0 3000 6200];    %SD046 cond 1 to cast 50
 y1=[0.0019 -0.0012 -0.0021];

elseif stano>50&stano<=56
x1=[0 6200];    %SD046 cond 1 casts 51:56
 y1=[0.005 -0.0003];
else
x1=[0 2000 6200];    %SD046 cond 1 casts 57 onwards
 y1=[0.0092 0.0063 0.0053];
end
offset=interp1(x1,y1,press);
end

function offset=oxygenoffset1_sd046(press,temp,oxygen,stano,gtime)
 if stano>7&stano<=30

x1=[160 360];   
y1=[4 12];
 xp1=[0 3500 4500 6200];   
 yp1=[0.3 -1.8 -2.5 -13];
offset=interp1(x1,y1,oxygen)+interp1(xp1,yp1,press);

 elseif stano>30

x1=[160 360];   
y1=[5.5 17];
xp1=[0 3500 4500 6200];   
yp1=[0.3 -1.8 -4 -13];
offset=interp1(x1,y1,oxygen)+interp1(xp1,yp1,press);
 else
     offset=0; %unknown
 end
end

function offset=oxygenoffset2_sd046(press,temp,oxygen,stano,gtime)
if stano>7&stano<=30
x2=[160 360];
y2=[2 4.5];
xp2=[0 3500 4500 6200];
yp2=[-0.5 0.4 -0.5 -9.5];
offset=interp1(x2,y2,oxygen)+interp1(xp2,yp2,press);
elseif stano>30
x2=[160 360];
y2=[2.5 10];
xp2=[0 3500 4500 6200];
yp2=[0.3 1 -0.6 -9.5];
offset=interp1(x2,y2,oxygen)+interp1(xp2,yp2,press);
else
    offset=0; %unknown
end
end

function offset=oxygenoffset2_sd041(press,temp,oxygen,stano,gtime)
    if stano>55 % sensor 3634
        offset=oxygen*(1.0702-1)-15.037-2; % calibration from SD035 with further 2 subtracted
    elseif stano>8 % sensor 3634
        offset=oxygen*(1.0702-1)-15.037-6.75; % calibration from SD035 with further 6.75 subtracted
    else % sensor 2290
        offset=oxygen*(0.9955-1)-6.7469; % calibration from SD035
    end
end

function offset=condoffset1_jr18004(press,temp,cond,stano,gtime)
    if 1<=stano && stano<=18
        offset=0.0013;
    else
        offset=0.000043954;
    end
end

function offset=condoffset2_jr18004(press,temp,cond,stano,gtime)
    if 1<=stano && stano<=15
        offset=0.0011;
    elseif 16<=stano && stano<=25
        offset=(0.0011-(stano-15)*0.00017629);
    else
        offset=-0.00066288;
    end
    offset=offset+condoffset1_jr18004(press,temp,cond,stano,gtime);
end

function offset=condoffset1_jr310(press,temp,cond,stano,gtime)
    if stano<60
        offset=0;
    else
        offset=0.000016*cond;
    end
end

function offset=condoffset2_jr310(press,temp,cond,stano,gtime)
    if stano<54
        offset=0.000033*cond;
    elseif stano<63
        offset=1.450415e-5*stano+0.999363-1;
    else
        offset=0.00031*cond;
    end
end
