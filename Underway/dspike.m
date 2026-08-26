function new = dspike(old,spikesize)

% function to despike a variable
% input array old and output array new are the same size
% NaNs are inserted in place of spikes
% magnitude of spike can be specified by spikesize 

new = old;

d=diff(old);

a = find(d >= spikesize);
b = find(d <= (-1)*spikesize);

% if a or b are empty then no need to go on
if isempty(a) | isempty(b)
 % do nothing
 disp('********************************************')
 disp('********** No despiking necessary **********')
 disp('********************************************')
else
 % find spikes of positive spikesize
 [I] = intersect(b,(a+1));

 % find spikes of negative spikesize
 [J] = intersect(a,(b+1));

 new(I) = NaN*ones([1,length(I)]);
 new(J) = NaN*ones([1,length(J)]);

end
