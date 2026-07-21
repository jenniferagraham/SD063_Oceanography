function ox_out=oxygenhysteresis(seconds,press,ox_in,hparams)

if nargin<4
    hparams=[-0.033 5000 1450]; % SeaBird defaults
    % H1 = amplitude of hysteresis correction. Default = -0.033, range = -0.02 to -0.05.
    % H2 = function constant or curvature function for hysteresis.
    % Default = 5000, second-order parameter that does not require tuning between sensors.
    % H3 = time constant for hysteresis (seconds). Default = 1450, range = 1200 to 2000.
else
    if length(hparams)~=3
        error('Need 3 h parameters for hysteresis correction');
    end
end

d=1+hparams(1)*(exp(press./hparams(2))-1);
c=exp(-diff(seconds)./hparams(3));
if std(c)>.000001
    warning('non-uniform time?');
end

ox_out=ox_in;
for n=2:length(ox_in)
    ox_out(n)=(ox_in(n)+(ox_out(n-1).*c(n-1).*d(n))-(ox_in(n-1).*c(n-1)))./d(n);
end

