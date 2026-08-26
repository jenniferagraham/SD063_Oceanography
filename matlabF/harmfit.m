function [b,x,r,f,v]=harmfit(uvc, t, periods, pgood)
% function [b,x,r,f,v]=harmfit(uvc, t, periods, pgood)
%
%  Fits any or all of a mean, trend, and n sinusoids to a complex
%  velocity matrix.
%  INPUT:
%     uvc     = complex velocity matrix, each row is one depth level
%               (uvc will be transposed automatically if necessary)
%     t       = vector of times corresponding to columns in uvc
%     periods = vector with 2+n elements;
%                 if periods(1) = 1, then include mean in the fit
%                 if periods(2) = 1, then include trend in the fit
%                 periods(2+ii) are periods in hours of harmonics to be fit
% >>change: Sun  10-24-1993   NaN elements in periods are not used in fit.
%                    This applies only to harmonic
%                    components, not to periods(1:2).
%
% OUTPUT:
%     b = best fit parameters; b(1) is the mean, b(2) the trend;
%                 b(3) and b(4) are coefficients of the first frequency (CCW)
%                 and its negative (CW), respectively; and similarly for
%                 higher frequencies.
%     x = matrix of curves being fit
%     r, f = matrices of residuals, fitted curves; transposed relative to uvc.
%     v = covariance matrix of model components.
%
%             Eric Firing, Sun  08-20-1989
%
% ---------------------------------------------------------------------------
% Modified to calculate the parameter, b, even at the depth which has one or
% more bad velocity values (NaN) under following condition:
%
%    Fraction of good data at that depth must be larger
%     than 0.8 or the optional parameter "pgood".
%
%             Willa Zhu,   May 30, 1991
%----------------------------------------------------------------------------

GOODPERCENT = 0.80;
if(nargin < 3)
   error('ERROR: need at least 3 arguments.');
elseif (nargin == 4),
   GOODPERCENT = pgood;
end

[nt, n] = size(t);
if n>nt, t=t'; nt=n; end;   % Make t into a column vector, if it is not already.

[nd, n] = size(uvc);

if n ~= nt,
   if nd == nt,     % The matrix needs to be transposed.
      uvc = uvc.';
      nd = n;
      disp('input matrix has been transposed');
   else
      error('ERROR: input complex matrix and time vector lack common dimension')
   end
end

x = harmcrv(t, periods);

b = x\uvc.';  % the model parameters
              % (x is included in output so that partial model
              %  fits can be calculated.)

% Add the following on May 30, 1991 ------------------------------------------
% Modified on Sun  10-24-1993
uvcc = uvc.';
ind_nan = find(sum(isnan(uvcc)) ~= 0);
for jn = 1:length(ind_nan)
    i1 = find(~isnan(uvcc(:,ind_nan(jn))));
    %good_percent  = length(i1)/(max(i1)-min(i1)+1);
    good_percent  = length(i1)/nt; % 93/11/29
    if(good_percent >= GOODPERCENT)
       b(:,ind_nan(jn)) = x(i1,:)\uvcc(i1,ind_nan(jn));
    end
end
% -------------------------------------------------------------------------

f = x*b;                % the model fit
r = uvc.' - f;          % the residuals
v = (x'*x)/nt;          % covariance matrix of the model components
                        % (can't use cov() fn, because we do not want
return;                 %  to remove the means)

