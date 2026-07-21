
clear
sc=input('Enter first cast\n');
if sc<0
    ec=-sc;
    sc=-sc;
else
ec=input('Enter last cast\n');
end

fileow=0;

for aa=sc:ec
    clear ('-regexp','[^aa ^fileow]')
aaa = num2str(aa,'%03d');


disp('Running tempcalbottGEN') % _bot_.all -> _bot_.tcl
if tempcalbottGEN(aaa), break, end %apply at this stage to allow different fallrate algorithms to be applied to calibrated data
 
disp('Running salcalGEN_tcal') % .clb -> .clb.up & .clb.dn
if salcalGEN_tcal(aaa), break, end
 
end