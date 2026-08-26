% n2satv2.m                                        by:  Edward T Peltzer, MBARI
%                                                  revised:  2007 Apr 25.
%
% CALCULATE NITROGEN CONCENTRATION AT SATURATION
%
% Source:  The solubility of neon, nitrogen, and argon in distilled water 
%          and seawater - Hamme & Emerson (2004) Deep Sea Research V51(11):
%          1517-1528.  doi: 10.1016/j.dsr.2004.06.009.
%
% Input:       S = Salinity (0/00)
%              T = Temp (deg C)
%
% Output:      Nitrogen saturation at one atmosphere (umol/kg).
%
%                        N2 = n2satv2(S,T).

function [N2] = n2satv2(S,T)


% DEFINE CONSTANTS, ETC FOR SATURATION CALCULATION

  A0 = 6.42931;
  A1 = 2.92704;
  A2 = 4.32531;
  A3 = 4.69149;
  B0 = -7.44129e-03;
  B1 = -8.02566e-03;
  B2 = -1.46775e-02;


% CALCULATE NITROGEN SATURATION

  Ts = log((298.15-T)/(273.15+T));

  lnC = A0 + Ts.*(A1 + Ts.*(A2 + Ts.*A3));
  lnC = lnC + S .* (B0 + Ts.*(B1 + Ts.*B2));
  N2 = exp(lnC);
