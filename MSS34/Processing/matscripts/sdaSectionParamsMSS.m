function P = sdaSectionParamsMSS(sectionName)
% Define SD063 sections for plotting
% For each new section populate below. 
% Created by JGraham for CTD  2025-07-28
% Modified for MSS by Laura C 2026-Aug-04

% P.stationlist = [5,5,5,6,6,7,7,7]; % MSS station normally have 3 casts per staiton unless decision to not or conditions did not allowed it. 
% P.castlist = [14,15,16,17,18,19,20,21]; continues number for downcast profiles 
% P.sectionname = 'S-mooring section';

% Defaults
P.maxy   = 1000;
P.fjord  = 0;
P.vcaxis = [-0.2 0.2];
P.tcaxis = [-2 14];
P.scaxis = [27 35.5];
P.epscaxis = [-11 -4];
P.mLON   = [-33.4 -28];
P.mLAT   = [67.4 69];
P.clevels = [23:1:28];

switch lower(sectionName)
   case 'all3m'
        P.stationlist=[1:36];
        P.castlist = [1:55];
        P.sectionname = '3-M All';
        P.maxy   = 400;
        P.tcaxis = [-2 2];
    case '3minner_towyo'
        P.castlist = flip([44:55]);
        P.stationlist = flip([24:34]); % left to right facing the ice
        P.sectionname = '3-M Inner towyo';
        P.maxy   = 400; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
   case '3minner'
        P.castlist=[7:16];
        P.stationlist = [3 3 3 4 4 4 5 6 6 6]; % station list 
        P.sectionname = '3-M Inner';
        P.maxy   = 400; 
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
    case '3mtransect' % along fjord transect
        P.fjord = 1;
        P.stationlist = [];
        P.castlist = [];
        P.sectionname = '3-M Transect';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];
    case '3mtransectmss' % along fjord transect inner
        P.fjord = 1;
        P.stationlist = [6 , 6,   6, 2, 2, 2,  7,  7,  8,  8, 9,   9,  9, 14];
        P.castlist =    [14, 15, 16, 4, 5, 6, 17,  18, 19, 20, 21, 22, 23, 33]; % cast 19 replaced a cast with an identical no. to 20 
        P.sectionname = '3-M Transect inner to Sill';
        P.maxy   = 500; 
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];
    case '3msill_towyo'
        P.fjord = 1;
        P.stationlist = flip([12:24]); % left to right 
        % ***** 16 **** is repeated - needds to be fix by alice delete this message when it is fixed. 
        P.castlist = flip([31:43]); % left to right is the plotting convention.
        P.sectionname = '3-M Sill towyo';
        P.maxy   = 250; 
        P.fjord  = 1;
        P.vcaxis = [-0.3 0.3];
        P.tcaxis = [-2 1];
        P.scaxis = [26.5 34.5];
        P.mLON   = [-31 -30];
        P.mLAT   = [68 68.5];
        P.clevels = [24:0.5:28];
    otherwise
        error('Unknown section name: %s',sectionName)

end
end