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

    case '3minner'
        P.sectionlist = [30,31,32,33,34,35,36,...
            37,38,39,40,41,42,43,44,45,46,47,48,49,...
            ];
        P.sectionname = '3-M Inner';
        P.maxy   = 400; 

    case '3mouter'
        P.sectionlist = [28, 29, ...
            50, 51];
        P.sectionname = '3-M Outer';
        P.maxy   = 400; 

    case 'all3m'
        P.sectionlist = [28,29,30,31,32,33,34,35,36,...
            37,38,39,40,41,42,43,44,45,46,47,48,49,...
            50,51];
        P.sectionname = '3-M All';
        P.maxy   = 400; 

    case 'allmelange'
        P.sectionlist = [10, 11, 12, 13, 22,...
            14, 15, 16, 17, 18];
        P.sectionname = 'Melange All';
        P.maxy   = 500; 

    case '3mtransect'
        P.fjord = 1;
        P.sectionlist = [43,42,49,35,51,50,29,28];
        P.sectionname = '3-M Transect';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'ssection'
        P.sectionlist = [5,6,7,8,9];
        P.sectionname = 'S-mooring section';
        P.maxy   = 1000;
        P.tcaxis = [-2 5];
        P.scaxis = [30 35.5];
        P.vcaxis = [-0.5 0.5];
        P.mLON   = [-33.4 -30];
        P.mLAT   = [66.8 69];

    case 'melangetroughalong'
        P.sectionlist = [13, 11,10];
        P.sectionname = 'Melange Trough along';
        P.maxy   = 700;
        P.vcaxis = [-0.2 0.2];
        P.tcaxis = [-2 3];
        P.scaxis = [29 35];
        P.mLON   = [-33.4 -30];

    case 'melangetroughentrance'
        P.sectionlist = [14, 15, 16, 17, 18];
        P.sectionname = 'Melange Trough entrance';
        P.maxy   = 700;
        P.vcaxis = [-0.5 0.5];
        P.tcaxis = [-2 3];
        P.scaxis = [29 35];
        P.mLON   = [-33.4 -30];

    case 'melangetroughnorth'
        P.sectionlist = [13, 12, 22];
        P.sectionname = 'Melange Trough North';
        P.maxy   = 500;
        P.vcaxis = [-0.5 0.5];
        P.tcaxis = [-2 3];
        P.scaxis = [29 35];
        P.mLON   = [-33.4 -30];

    case 'magictrough'
        P.sectionlist = [14, 15, 16, 17, 18];
        P.sectionname = 'Magic Trough';
        P.maxy   = 400;
        P.vcaxis = [-0.4 0.4];
        P.tcaxis = [-2 3];
        P.scaxis = [29 35];
        P.mLAT   = [67.2 69];

    case 'kgtrough'
        P.sectionlist = [23,24,25,26,27];
        P.sectionname = 'Kangerlussuaq Trough';
        P.maxy   = 550;
        P.tcaxis = [-2 2];
        P.scaxis = [29 35.5];
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
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mhead'
        P.fjord = 1;
        P.sectionlist = [40,41,42,39,38,37];
        P.sectionname = '3-M Head';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mdoubletrough'
        P.fjord = 1;
        P.sectionlist = [44,49,48,47,46,45];
        P.sectionname = '3-M double trough';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mmouthsection'
        P.fjord = 1;
        P.sectionlist = [52 55 53 54];
        P.sectionname = '3-M mouth section';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3mbeak'
        P.fjord = 1;
        P.sectionlist = [61 60 59 58 57 56];
        P.sectionname = '3-M beak section';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case '3macrosssill'
        P.fjord = 1;
        P.sectionlist = [76:-1:71];
        P.sectionname = '3-M across sill section';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3moutermouth'
        P.fjord = 1;
        P.sectionlist = [28 58];
        P.sectionname = '3-M outer section repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3minnermouth'
        P.fjord = 1;
        P.sectionlist = [29 55];
        P.sectionname = '3-M inner station repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3m_3msillpeak'
        P.fjord = 1;
        P.sectionlist = [35 62];
        P.sectionname = '3-M sill peak repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    case 'repeat_3m_icefront'
        P.fjord = 1;
        P.sectionlist = [43 63 65];
        P.sectionname = '3-M ice front front repeats';
        P.maxy   = 300; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];

    otherwise
        error('Unknown section name: %s',sectionName)

end
end