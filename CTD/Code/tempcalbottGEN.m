function break_loop=tempcalbottGEN(aaa)


% If calibrating both temperature and conductivity, need a step of applying
% temperature calibration to bottle files, to allow the back-calculation of
% the bottle conductivities to use the calibrated temperature
%
% Can then apply both calibrations in salcalappGEN

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

switch(cruise)
    case 'SD046' ...
        
        tempoffset1fcn = @(press,temp,cond,stano,gtime) interp1([0 2000 6200],[0.00055 -0.00065 -0.00065],press);
        tempoffset2fcn = @(press,temp,cond,stano,gtime) interp1([0 2000 6200],[-0.00025 -0.00125 -0.00125],press); 
    
    otherwise
        error('Cruise %s not defined in tempcalapp, maybe see salcalappGEN',cruise)
end


%% apply calibrations to bottle file

disp('applying calibrations to bottle file')

% load file containing bottle salinity, CTD conductivity, CTD temperature,
% and CTD pressure data
infile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.sal'])
otfile=fullfile(dir_out,[cruise,'_bot_',aaa,'',frame_fileadd,'',eee,'.tcl'])


if exist(infile,'file') %skip bottle section if salcal & mergebot not run (no bottle file)
    
    load (infile,'-mat');

    ctdtemp1_uncal=ctdtemp1;
    if exist('ctdtemp2','var')
    ctdtemp2_uncal=ctdtemp2;
    end

    if exist('ctdtemp2','var')
    disp('Two bottle sensor mode')
    botcalvars={'tempoffset1','tempoffset2','ctdtemp1_uncal','ctdtemp2_uncal'};
    else
    disp('One bottle sensor mode')
    botcalvars={'tempoffset1','ctdtemp1_uncal'};   
    end    
        
    tempoffset1=feval(tempoffset1fcn,ctdpress,ctdtemp1,ctdcond1,stano,gtime);
    if isscalar(tempoffset1)
        tempoffset1=repmat(tempoffset1,size(ctdtemp1));
    end
    ctdtemp1=ctdtemp1+tempoffset1;

    if exist('ctdtemp2','var')
    tempoffset2=feval(tempoffset2fcn,ctdpress,ctdtemp2,ctdcond2,stano,gtime);
    if isscalar(tempoffset2)
        tempoffset2=repmat(tempoffset2,size(ctdtemp2));
    end
    ctdtemp2=ctdtemp2+tempoffset2;
    end
    ctdtemp=eval(['ctdtemp',ctchoice]);



save(otfile,'gtime','samplesals','niskinnums','niskinind','botno',botcalvars{:},varbotnames{(vpd_bot==1),1});
% Now want to recalculate bottle conductivities. Use salcalGEN_tcal 
end %skip bottle section if salcal not run (no bottle file)

if nargout>0
    break_loop=false;
end
