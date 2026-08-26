function x = harmcrv(t, periods, t0)
% function x = harmcrv(t, periods, t0)
%  see harmfit.m

if nargin == 2,
   t0 = mean(t);
elseif nargin ~= 3,
   error('harmcrv requires 2 or 3 arguments');
end

nper = length(periods);  % temporary; see below
if nper >= 3,
   igood = find(~isnan(periods));
   periods = periods(igood);
end

nper = length(periods);  % new value: non-NaN periods

nfreq = (nper-2);
ncx = 2*nfreq + sum( periods(1:2) == 1 );
t = t(:);       % make sure it is a column vector
nt = length(t);

x = zeros(nt, ncx);


freqs = (2 * pi) ./ periods(3:nper);  % radians per time unit

jj = 1;
if periods(1) == 1,   % include the mean
   x(:,1)=ones(length(t),1);
   jj = 2;
end
if periods(2) == 1,   % include the trend
   x(:,jj)=(t-mean(t));
   jj = jj + 1;
end

for ii = 1:nfreq,
   x(:,jj) = exp(i * freqs(ii) * t);
   x(:,jj+1) = conj(x(:,jj));       % negative frequencies
   jj = jj + 2;
end
