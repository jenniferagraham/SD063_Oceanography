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
        P.maxy   = 600;
        P.tcaxis = [-2 5];
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

    otherwise
        error('Unknown section name: %s',sectionName)

end
end