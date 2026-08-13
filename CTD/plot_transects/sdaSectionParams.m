function P = sdaSectionParams(sectionName)
% Define SD063 sections for plotting
% For each new section populate below. 
%
% P.sectionlist = [5,6,7,8,9];
% P.sectionname = 'S-mooring section';
% P.maxy   = 1000;
% P.tcaxis = [-2 5];
% P.scaxis = [30 35.5];
% P.vcaxis = [-0.5 0.5];
% P.mLON, mLAT : axes limits for map
%
% Created by JGraham
% 2025-07-28

% Defaults
P.maxy   = 1000;
P.fjord  = 0;
P.vcaxis = [-0.2 0.2];
P.tcaxis = [-2 14];
P.scaxis = [27 35.5];
P.mLON   = [-33.4 -28];
P.mLAT   = [67.4 69];

switch lower(sectionName)

    case 'quick_comp'
        P.fjord = 1;
        P.sectionlist = [26 137 161 162 163];% 13 142 17 143 146];
        P.msslist = [];
        P.sectionname = 'Quick comparison';
        P.maxy   = 600;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'aw_comp'
        % NB. stns 3 and 4 are from the shelf break
        P.fjord = 1;
        P.sectionlist = [3 4 9 137 153 154];
        P.msslist = [];
        P.sectionname = 'Quick comparison with AW';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 8];
        P.scaxis = [31 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'kangglac_kivioq_trough_across' %eclipse_trough_across
        P.fjord = 0;
        P.sectionlist = [47 46 48 49];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Kivioq Trough Across'; %Eclipse Trough Across
        P.maxy   = 200;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 1];
        P.scaxis = [30 35.0];
        P.mLON   = [-29.5 -28.5];
        P.mLAT   = [68.25 68.6];

    case 'kangglac_kivioq_trough_along' %eclipse_trough_along
        P.fjord = 0;
        P.sectionlist = [43 44 45 46];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Kivioq Trough Along'; %Eclipse Trough Along
        P.maxy   = 250;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 1];
        P.scaxis = [30 35.0];
        P.mLON   = [-29.5 -28.5];
        P.mLAT   = [68.25 68.6];

    case 'deception_trough'
        P.fjord = 1;
        P.sectionlist = [149 148 146 145 144 143 142];
        P.msslist = [];
        P.sectionname = 'Deception Trough';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 2.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'deceptionloop-1'
        P.fjord = 1;
        P.sectionlist = [7 6 5 17 13 11 10 9];
        P.msslist = [];
        P.sectionname = 'Deception Loop 1';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 2.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-34 -31];
        P.mLAT   = [67 68];

    case 'deceptionloop-2'
        P.fjord = 1;
        P.sectionlist = [152 151 150 148 146 149 145 144 160 159 158 157 156];
        P.msslist = [];
        P.sectionname = 'Deception Loop 2';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 2.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-34 -31];
        P.mLAT   = [67 68];

    case 'kangglac_deceptionloop'
        P.fjord = 1;
        %P.sectionlist = [78,72,73,4,5,6,71,79,68,69,70,74,75,63];
        P.sectionlist = [78,72,73,71,79,68,70,74,75,63];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Deception Loop';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 2.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-34 -31];
        P.mLAT   = [67 68];

    case 'kangglac_alongtrough'
        P.fjord = 1;
        P.sectionlist = [89,90,88,87,86,84,8,57,7,12,16,20];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Main Trough Along';
        P.maxy   = 800;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 7];
        P.scaxis = [30 35.0];
        P.mLON   = [-34 -28];
        P.mLAT   = [65 68];

    case 'kangglac_kgtrough'
        P.fjord = 1;
        P.sectionlist = [18:23];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Kangerlussuaq Trough';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'kangglac_kgtroughouter'
        P.fjord = 1;
        P.sectionlist = [9:15];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Kangerlussuaq Trough Outer';
        P.maxy   = 550;
        P.tcaxis = [-2 4];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'kangglac_flado'
        P.fjord = 1;
        P.sectionlist = [9 58 67 66 59 63 62 61];
        P.msslist = [];
        P.sectionname = 'Kang-Glac Kangerlussuaq Trough Outer';
        P.maxy   = 550;
        P.tcaxis = [-2 4];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'skag_kgtrough-1'
        P.fjord = 1;
        P.sectionlist = [5:11];
        P.msslist = [];
        P.sectionname = 'Skag Kangerlussuaq Trough 1';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'skag_kgtrough-2'
        P.fjord = 1;
        P.sectionlist = [47:-1:41];
        P.msslist = [];
        P.sectionname = 'Skag Kangerlussuaq Trough 2';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'allmelange'
        P.sectionlist = [10, 11, 12, 13, 22,...
            14, 15, 16, 17, 18,];
        P.sectionname = 'Melange All';
        P.maxy   = 500; 

    case 'ssection'
        P.sectionlist = [5,6,7,8,9];
        P.sectionname = 'S-mooring section';
        P.maxy   = 1000;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'ssectionwarm'
        P.sectionlist = [5,6,7,8,10,9];
        P.sectionname = 'S-mooring section warm';
        P.maxy   = 1000;
        P.tcaxis = [-2.5 2.5];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'melangetroughalong-1'
        P.sectionlist = [17,13,11,10,9];
        P.sectionname = 'Melange Trough along';
        P.maxy   = 700;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 4];
        P.scaxis = [30 35];
        P.mLON   = [-33.4 -30];

    case 'melangetroughalong-2'
        P.sectionlist = [160,159,158,157,156];
        P.sectionname = 'Melange Trough along';
        P.maxy   = 700;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 4];
        P.scaxis = [30 35];
        P.mLON   = [-33.4 -30];

    case 'melangetroughnorth'
        P.sectionlist = [15,13,12,22];
        P.sectionname = 'Melange Trough north';
        P.maxy   = 700;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.mLON   = [-33.4 -30];

    case 'melangetroughentrance'
        P.sectionlist = [14,15,16,17,18];
        P.sectionname = 'Melange Trough entrance';
        P.maxy   = 700;
        P.vcaxis = [-0.5 0.5];
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.mLON   = [-33.4 -30];

    case 'magictrough'
        P.sectionlist = [19,20,21,12,22];
        P.sectionname = 'Magic Trough';
        P.maxy   = 400;
        P.vcaxis = [-0.5 0.5];
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.mLON   = [-33.4 -30];

    case 'kgtrough-1'
        P.sectionlist = [23,24,25,26,27];
        P.sectionname = 'Kangerlussuaq Trough-1';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'kgtrough-2'
        P.sectionlist = [140,139,138,137,136];
        P.sectionname = 'Kangerlussuaq Trough-2';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'kgtrough-3'
        P.sectionlist = [161,162,163,164];
        P.sectionname = 'Kangerlussuaq Trough-3';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case '3mtransect' % along fjord transect 
        P.fjord = 1;
        P.sectionlist = [43,42,49,36,85:1:90,50,64,69,29,28,112];
   %    P.sectionlist = [43,42,49,35,51,50,29,28];
        P.msslist = [];
        P.sectionname = '3-M Transect 1';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mtransect-2' % along fjord transect 
        P.fjord = 1;
        P.sectionlist = [174 178:183 184 185];
        P.msslist = [];
        P.sectionname = '3-M Transect 2';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mtransect_anomalies' % along fjord transect 
        P.fjord = 1;
        P.sectionlist = [43,49,85,88,64,29];
        %    P.sectionlist = [43,42,49,35,51,50,29,28];
        P.msslist = [];
        P.sectionname = '3-M Transect';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mtransectbio' % along fjord transect on biology stations
        P.fjord = 1;
        P.sectionlist = [81,43,42,49,36,35,51,50,64,29,28]; % for mini section at the ice front look at 43 is 81, for repeat bio see 43 and 63 are 
        P.msslist = [];
        P.sectionname = '3-M Transect Bio';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [28 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mtransectmss' % along fjord transect 
        P.fjord = 1;
        P.sectionlist = [43,42,49,35,51,50,29,28];
        P.msslist = [];
        P.sectionname = '3-M Transect';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3minner' % needs updating!
        P.sectionlist = [30,31,32,33,34,35,36,...
            37,38,39,40,41,42,43,44,45,46,47,48,49,...
            ];
        P.msslist = [44:55];
        P.sectionname = '3-M Inner';
        P.maxy   = 400; 

    case '3minnermss'
        P.sectionlist=[];
        P.mssstationlist = [3 3 3 4 4 4 5 6 6 6]; % station list 
        P.msslist = [7:16]; % cast list
        P.sectionname = '3-M Inner';
        P.maxy   = 400;

    case '3mouter'
        P.sectionlist = [28, 29, ...
            50, 51];
        P.sectionname = '3-M Outer';
        P.maxy   = 400; 

    case 'all3m' % needs updating!
        P.sectionlist = [28,29,30,31,32,33,34,35,36,...
            37,38,39,40,41,42,43,44,45,46,47,48,49,...
            50,51];
        P.msslist = [1:55];
        P.sectionname = '3-M All';
        P.maxy   = 400; 

    case '3msill'
        P.fjord = 1;
        P.sectionlist = [30,31,35,32,33,34];
        P.sectionname = '3-M Sill';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
       % P.tcaxis = [-2 1.5];
       % P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];

    case '3minnersill'
        P.fjord = 1;
        P.msslist = [13 14 15 16 17 18 19 20 21 22 23 24];
        P.sectionname = '3-M Sill';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mhead'
        P.fjord = 1;
        P.sectionlist = [40,41,42,39,38,37];
        P.msslist = [];
        P.sectionname = '3-M Head';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mdoubletrough'
        P.fjord = 1;
        P.sectionlist = [44,49,48,47,46,45];
        P.msslist = [];
        P.sectionname = '3-M double trough';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mmouthsection'
        P.fjord = 1;
        P.sectionlist = [52 55 53 54];
        P.sectionname = '3-M mouth section';
        P.maxy   = 600; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mbeak-1'
        P.fjord = 1;
        P.sectionlist = [61 70 60 59 58 57 56];
        P.sectionname = '3-M beak section 1';
        P.maxy   = 600; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mbeak-2'
        P.fjord = 1;
        P.sectionlist = [130:133];
        P.sectionname = '3-M beak section 2';
        P.maxy   = 600; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mbeaksouth-1'
        P.fjord = 1;
        P.sectionlist = [61 70 60];
        P.sectionname = '3-M beak south 1';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mbeaksouth-2'
        P.fjord = 1;
        P.sectionlist = [130:132];
        P.sectionname = '3-M beak south 2';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mshelfnorth'
        P.fjord = 1;
        P.sectionlist = [170 169 168];
        P.sectionname = '3-M shelf north';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mshelfsouth'
        P.fjord = 1;
        P.sectionlist = [166, 167, 165];
        P.sectionname = '3-M shelf south';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3macrosssill-1'
        P.fjord = 1;
        P.sectionlist = [76:-1:71];
        P.msslist = [];
        P.sectionname = '3-M across sill section 1';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3macrosssill-2'
        P.fjord = 1;
        P.sectionlist = [85:1:90];
        P.msslist = [];
        P.sectionname = '3-M across sill section 2';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3macrosssill-3'
        P.fjord = 1;
        P.sectionlist = [178:1:183];
        P.msslist = [];
        P.sectionname = '3-M across sill section 3';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mthroat'
        P.fjord = 1;
        P.sectionlist = [68 69 67 66];
        P.msslist = [];
        P.sectionname = '3-M throat section';
        P.maxy   = 600; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3macrosssillsouthdogleg'
        P.fjord = 1;
        P.sectionlist = [94 93 92 91];
        P.msslist = [];
        P.sectionname = ['3-M across sill south dog leg 1'];
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3micefronttowyo'
        P.fjord = 1;
        P.sectionlist = [118:125 127:129];
        P.msslist = [];
        P.sectionname = ['3-M ice front tow yo'];
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        %P.tcaxis = [-2 1.5];
        % P.scaxis = [30 35.0];
        P.scaxis = [26.5 34.5]; % match SDA 041 erabus deployment
        P.tcaxis = [-2 1]; % to match SDA 041 erabus deployment 
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3micefront_section-reverse'
        P.fjord = 1;
        P.sectionlist = [171 172 174];
        P.msslist = [];
        P.sectionname = '3-M ice front repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3micefront_section-2'
        P.fjord = 1;
        P.sectionlist = [177 176 175 174 172 171];
        P.msslist = [];
        P.sectionname = '3-M ice front repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.scaxis = [26.5 34.5]; % match SDA 041 erabus deployment
        P.tcaxis = [-2 1]; % to match SDA 041 erabus deployment 
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3micefront'
        P.fjord = 1;
        P.sectionlist = [43 63 65 ...
            77:84 ...
            95 96 111 117 127 128 129 134 ...
            171 172 173 174 ...
            193 194 195];
        P.msslist = [];
        P.sectionname = '3-M ice front repeat';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3micefrontsouth'
        P.fjord = 1;
        P.sectionlist = [119 120 117 191];
        P.msslist = [];
        P.sectionname = '3-M ice front repeat';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3meastsill'
        P.fjord = 1;
        P.sectionlist = [76 85 97:111 178 190];
        P.msslist = [];
        P.sectionname = '3-M east sill repeat';
        P.maxy   = 300;
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3msillnorthpeak'
        P.fjord = 1;
        P.sectionlist = [33 73 88 181 189];
        P.msslist = [];
        P.sectionname = '3-M sill north peak repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3mwestsill'
        P.fjord = 1;
        P.sectionlist = [51 71 90 183 188];
        P.msslist = [];
        P.sectionname = '3-M west sill repeat';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3msillpeak'
        P.fjord = 1;
        P.sectionlist = [35 62 92];
        P.msslist = [];
        P.sectionname = '3-M sill peak repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3mmouth'
        P.fjord = 1;
        P.sectionlist = [29 55 184 187];
        P.msslist = [];
        P.sectionname = '3-M mouth repeat';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3mbeak'
        P.fjord = 1;
        P.sectionlist = [28 58 113 185];
        P.msslist = [];
        P.sectionname = '3-M beak repeat';
        P.maxy   = 600;
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    otherwise
        error('Unknown section name: %s',sectionName)

end
end