% Setup script for general CTD processing code
% Written by Hugh Venables, to allow easier use of processing scripts,
% starting with ctdreadGEN
% See cruise reports for JR17003a, JR18004, DY111, SD020 and SD030 for more details

% Need to define:
%    directory paths
%    file name conventions (may need change to ctdreadGEN)
%       If you have two CTD packages, see notes in this section
%    Which sensors are on the package, and the Seabird export position
%       (starting from 1, not 0)
%    Which variables will either be calculated or measured afterwards
%       (cast and bottle files)

% Then save a backup of the wrapper script with cruisename in filename
%    Needed for processing later
%    Repeat any time this script is changed


if ismac
    % from cruise:
    dir_sb='/Volumes/leg/work/scientific_work_areas/ctd/SBEproc';
    dir_raw='/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD041/CTD/raw';
    dir_SBE35='/Volumes/leg/system/ctd_seabird_sbe911plus/acquisition/data/SD041/CTD/raw';

    dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
    dir_plots='/Volumes/leg/work/scientific_work_areas/ctd/BASproc/plots';
    dir_salts='/Volumes/leg/work/scientific_work_areas/ctd/salts';

    % postprocessing: directories on Povl's computer & BAS SAN
    % dir_sb='/Volumes/sda/20240717/work/scientific_work_areas/ctd/SBEproc';
    % dir_raw='/Volumes/sda/20240717/system/ctd_seabird_sbe911plus/acquisition/data/SD041/CTD/raw';
    % dir_SBE35='/Volumes/sda/20240717/system/ctd_seabird_sbe911plus/acquisition/data/SD041/CTD/raw';
    % 
    % dir_out='/Users/epab/Povl/SD041/CTD/BASproc';
    % dir_plots='/Users/epab/Povl/SD041/CTD/BASproc/plots';
    % dir_salts='/Users/epab/Povl/SD041/CTD/salts';

    %    dir_oxy='/Users/epab/Povl/SD033/CTD/oxy';
elseif ispc
    dir_sb='L:\work\scientific_work_areas\ctd\SBEproc';
    dir_raw='L:\system\ctd_seabird_sbe911plus\acquisition\data\SD041\CTD\raw';
    dir_SBE35='L:\system\ctd_seabird_sbe911plus\acquisition\data\SD041\CTD\raw';
    dir_out='L:\work\scientific_work_areas\ctd\BASproc'; % 'L:/work/scientific_work_areas/CTD/CTD_processed' ;
    dir_plots='L:\work\scientific_work_areas\ctd\BASproc\plots';
    dir_salts='L:\work\scientific_work_areas\ctd\salts'; % 'L:/work/scientific_work_areas/Salinometry/salinities';

    %     dir_oxy='C:\SD033\CTD\oxy';
else
    error('Set your paths!');
end

%%%%%Following not needed, so long as use leading commas that Matlab says
%%%%%you don't need:

% if exist('cruise','file')
%     warning('Removing the LDEO LADCP software from your path to allow you to run CTD scripts!');
%     rmpath(fileparts(which('cruise')));
%     clear cruise
% end


%If two CTD frames are in use with different sensor setups, will need two
%versions of this script
%Add the identifier for the frame after the cruise name
%eg DY111_SS and DY111_T
%place the two versions of CTDvarn in two different directories (need the same filename)
%Do not link these directories to your filepaths
%Link all other directories to your filepaths
%Go to the appropriate directory, run the code and it will use the local CTDvarn to the directory you're in

cruise='SD041';

cast_fileadd='_SS'; % suffix for the rosette
sb_prefix=''; %expecting cruise_[sb_prefix]nnn[cast_fileadd][sb_fileadd].cnv
sb_fileadd='_actm'; %expecting cruise_[sb_prefix]nnn[cast_fileadd][sb_fileadd].cnv
sb35_prefix=''; %expecting cruise_[sb35_prefix]nnn[cast_fileadd][sb35_fileadd].asc
sb35_fileadd='_sbe35'; %expecting cruise_[sb_prefix]nnn[cast_fileadd][sb35_fileadd].asc



% addpath('C:\hjv\mtlab\seawater')%set path
% addpath('C:\hjv\Code\matlab_codes')

%want a name for each section of a script, so that script can find the
%matching column (rather than hard-coded column number, allows columns to
%be added or removed

%Variable names set in table below, 
%Generalised scripts assume a temp2 and cond2, if these are absent will
%need to edit other scripts
%Note that seabird_output_position starts at 1 whereas headers in cnv files
%start at 0 (so number here is one more than number there)
columnuse={'variable_name' 'seabird_output_position' 'want_to_read' 'plus_derive' 'edit_vars' 'ctd_plot' 'bot_merge' 'plot_title'};
varnames={
            'scan'   1    1   1   0   0   0   'scan'
    'time_elapsed'   2    1   1   0   0   0   'Cast time (sec)'
           'press'   3    1   1   0   0   2   'Pressure (dbar)'
           'temp1'   4    1   1   1   0   2   'Temp 1 (^oC)'
           'temp2'   5    1   1   1   0   2   'Temp 2 (^oC)'
           'cond1'   6    1   1   1   0   2   'Cond 1 (mS cm^{-1})'
           'cond2'   7    1   1   1   0   2   'Cond 2 (mS cm^{-1})'
     'oxygen_ml_l'   0    1   1   1   0   1   'Oxygen (ml l^{-1})'
   'oxygen_umol_l'   0    1   1   1   0   1   'Oxygen (\mumol l^{-1})'
        'oxygen_V'   0    1   1   1   0   1   'Oxygen (V)'
  'oxygen1_umol_kg'  8    1   1   1   4   1   'Oxygen 1 (\mumol kg^{-1})'
  'oxygen2_umol_kg'  9    1   1   1   4   1   'Oxygen 2 (\mumol kg^{-1})'
       'turbidity'  16    1   1   1   5   1   'Turbidity (m^{-1} sr^{-1})'
       'BeamTrans'  10    1   1   1   3   1   'Trans (%)'
             'alt'  11    1   1   0   0   0   'Altimeter (m)'
      'fluor_ug_l'  12    1   1   1   1   1   'Chl a (\mug l^{-1})'
           'pumps'  15    1   1   0   0   0   'pump'     %e.g. for not saving from this point on
            'flag'  19    1   1   0   0   0   'flag'
             'par'  14    1   1   1   0   1   'PAR (\mumol m^{-2} sec^{-1})'
            'par2'   0    1   1   1   0   1   'PAR (\mumol m^{-2} sec^{-1})'
       'PressTemp'   0    1   1   0   0   0   'pressure temp (^oC)' %e.g. for including in output but not processing
         'nitrate'   0    1   1   1   0   1   'Nitrate'  %want it if present, but not on CTD
         'latscan'  17    1   1   0   0   0   'Lat'
         'lonscan'  18    1   1   0   0   0   'Long'
          'salin1'  -1    0   1   0   0   1   'Salinity 1'   %derived parameter
          'salin2'  -1    0   1   0   0   1   'Salinity 2'
           'salin'  -1    0   1   0   0   1   'Salinity'
            'temp'  -1    0   1   0   0   1   'Temperature (^oC)'
         'potemp1'  -1    0   1   0   0   1   'Pot Temp 1 (^oC)'
         'potemp2'  -1    0   1   0   0   1   'Pot Temp 2 (^oC)'
          'potemp'  -1    0   1   0   0   1   'Pot Temp (^oC)'
            'sig0'  -1    0   1   0   0   1   '\sigma_0 (kg m^{-3})'
            'sig2'  -1    0   1   0   0   1   '\sigma_2 (kg m^{-3})'
            'sig4'  -1    0   1   0   0   1   '\sigma_4 (kg m^{-3})'
           'depth'  -1    0   1   0   0   1   'Depth (m)' %set third column to 0 if not wanted
  'oxygen_umol_kg'  -1    0   1   0   0   1   'Oxygen (\mumol kg^{-1})'
            'cdom'  13    1   1   1   2   1   'CDOM (QSU)'
         } ; 

     %make 1/0 vector of whether sensor is present (column2>0) and variable wanted (column 3~=0)
     sv=size(varnames);
     vp=zeros(sv(1),1);
     vpd=zeros(sv(1),1);
     vp_b=zeros(sv(1),1);
     for iv=1:sv(1)
         vp(iv)=(varnames{iv,2}*varnames{iv,3})>0;
         vpd(iv)=(varnames{iv,2}*varnames{iv,4})~=0;  %including derived variables
         vp_b(iv)=((varnames{iv,2}~=0)*(varnames{iv,7}));
     end

% default: use primary C/T sensor. You can choose this as a function of "aaa" instead if necessary.
    ctchoice='1';
%      if exist('aaa','var')
%        switch (aaa)
%          case '020'
%              ctchoice='1'; % salp in secondary duct!
%          otherwise
%              ctchoice='2'; 
%        end
%      end
     
%      iic=find(strcmp(columnuse,'cal_var')); %ensure looking at right column
% sv=size(varnames);
%      vpp=zeros(sv(1),1);
%      for iv=1:sv(1)
%          vpc(iv)=(varnames{iv,2}*varnames{iv,iic})~=0;        
%      end
     vpc=vpd;
     
     %name   .ros pos plus read from .ros?   read?   save?
     varbotnames={
         'bscan'          1     1       0
         'btime'          2     1       0
         'bpress'         3     1       1
         'btemp1'         4     1       1
         'btemp2'         5     1       1
         'bcond1'         6     1       1
         'bcond2'         7     1       1
         'boxy1_umol_kg'  8     1       1
         'boxy2_umol_kg'  9     1       1
         'btrans'        10     1       1
         'balt'          11     1       0
         'bfluor'        12     1       1
         'bcdom'         13     1       1
         'bpar'          14     1       1
%          'bpar2'         18     1       0
%          'bPressTemp'    20     1       0
         'bpumps'        15     1       0
         'bturbidity'    16     1       1
         'bnbf'          19     1       1
         'bflag'         20     1       0
%          'blat'           3     1       0
%          'blong'          4     1       0
         
%          'ctdpress'      -1     0       1   %these names have to match names in first table
%          'ctdtemp1'      -1     0       1
%          'ctdtemp2'      -1     0       1
%          'ctdcond1'      -1     0       1
%          'ctdcond2'      -1     0       1
         'stdpress'      -1     0       1
         'stdtemp1'      -1     0       1
         'stdtemp2'      -1     0       1
         'stdcond1'      -1     0       1
         'stdcond2'      -1     0       1
         'ctdoxygen1_umol_kg' -2  0     1
         'ctdoxygen2_umol_kg' -2  0     1
%          'ctdBeamTrans'  -1     0       1
%          'ctdfluor_ug_l' -1     0       1
%          'ctdpar'        -1     0       1
%          'ctdtemp'       -1     0       1
%          'ctdoxygen_umol_kg' 0  0       1
%          'ctdoxygen_umol_l' 0   0       1
%          'ctdoxygen_umol_kg_uncal' -1 0       1
%          'ctdoxygen_umol_l_uncal' -1  0       1
%          'ctdpotemp1'    -1     0       1
%          'ctdpotemp2'    -1     0       1
%          'ctdpotemp'     -1     0       1
%          'ctdsalin1'     -1     0       1
%          'ctdsalin2'     -1     0       1
%          'ctdsalin'      -1     0       1
%          'ctdsig0'       -1     0       1
%          'ctdsig2'       -1     0       1
%          'ctdsig4'       -1     0       1
         
         'botsal'        -2     0       1   % added in the merge step
         'sb35temp'      -2     0       1   % added in the merge step
         'botoxy'        -2     0       1   % added in the merge step
         
         % add any blank variables for chemistry here!
%          'botd18o'       -2     0       1   % to be added later!
%          'botd18oflag'   -2     0       1   % to be added later!
         
         };
     
     %%%%%%%%%%%%%%%%
     % No more editing needed beyond here
     %%%%%%%%%%%%%%%%
     
     
     % add variables for ctd data to be written in to, need to match CTD
     % variable names
     
     lv=length(varbotnames);
     vadd=0;
     for iv=1:length(vpd)
         if vpd(iv)==1
             vadd=vadd+1;
             eval(['varbotnames{lv+vadd,1}=''ctd',varnames{iv,1},''';'])
            
             varbotnames{lv+vadd,2}=-1;
             varbotnames{lv+vadd,3}=0;
             varbotnames{lv+vadd,4}=1;
              
         end
     end


     svb=size(varbotnames);
     vp_bot=zeros(svb(1),1);
     vpd_bot=zeros(svb(1),1);
     vpd_botctd=zeros(svb(1),1);

     for iv=1:svb(1)
         vp_bot(iv)=(varbotnames{iv,2}*varbotnames{iv,3})>0;
         vpd_bot(iv)=(varbotnames{iv,2}*varbotnames{iv,4})~=0;  %including variables from CTD
         vpd_botctd(iv)=(varbotnames{iv,2}*varbotnames{iv,4})==-1;  %just variables from CTD
     end
     
     
