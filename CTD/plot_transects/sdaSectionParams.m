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

    case 'allmelange'
        P.sectionlist = [10, 11, 12, 13, 22,...
            14, 15, 16, 17, 18];
        P.sectionname = 'Melange All';
        P.maxy   = 500; 

    case '3mtransect' % along fjord transect 
        P.fjord = 1;
        P.sectionlist = [43,42,49,36,85:1:90,50,64,69,29,28,112];
   %    P.sectionlist = [43,42,49,35,51,50,29,28];
        P.msslist = [];
        P.sectionname = '3-M Transect';
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

    case 'ssection'
        P.sectionlist = [5,6,7,8,9];
        P.sectionname = 'S-mooring section';
        P.maxy   = 1000;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'melangetroughalong'
        P.sectionlist = [15,13,11,10,9];
        P.sectionname = 'Melange Trough along';
        P.maxy   = 700;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 2];
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

    case 'kgtrough'
        P.sectionlist = [23,24,25,26,27];
        P.sectionname = 'Kangerlussuaq Trough';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [30 35];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case '3msill'
        P.fjord = 1;
        P.sectionlist = [30,31,35,32,33,34];
        P.sectionname = '3-M Sill';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

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
        P.sectionlist = [118:123 127:129];
        P.msslist = [];
        P.sectionname = ['3-M ice front tow yo'];
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3minnermouth'
        P.fjord = 1;
        P.sectionlist = [29 55];
        P.msslist = [];
        P.sectionname = '3-M inner station repeats';
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

    case 'repeat_3msilln'
        P.fjord = 1;
        P.sectionlist = [33 73 88];
        P.msslist = [];
        P.sectionname = '3-M sill North repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];


    case 'repeat_3m_icefront'
        P.fjord = 1;
        P.sectionlist = [43 63 65 ...
            77:84 ...
            95 96 111 117 127 128 129 134];
        P.msslist = [];
        P.sectionname = '3-M ice front repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'yoyo_3meastsill'
        P.fjord = 1;
        P.sectionlist = [76 85 97:111];
        P.msslist = [];
        P.sectionname = '3-M east sill yoyo';
        P.maxy   = 300;
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3moutermouth'
        P.fjord = 1;
        P.sectionlist = [28 58 113];
        P.msslist = [];
        P.sectionname = '3-M outer mouth repeat';
        P.maxy   = 600;
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1.5];
        P.scaxis = [30 35.0];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3mmmouthsectionrepeats'
        P.fjord = 1;
        P.sectionlist = [55  114];
        P.msslist = [];
        P.sectionname = '3-M mouth sections repeat';
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