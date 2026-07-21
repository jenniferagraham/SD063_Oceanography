
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

   bl=0;
while bl==0

%aaa = input('Station number?\n','s');
% while length(aaa)<3
%     aaa=['0',aaa,''];
% end 
CTDvarn
ctdsave=fullfile(dir_out,[cruise,'_ctd_',aaa,'.clb']);

if exist(ctdsave,'file')
    if fileow~=1
    disp('Calibrated variable file exists')
    disp('Force overwrite (1), check individually (2) or stop (3)')
    fileexist=input('');
else
    fileexist=1;
    end
else
  fileexist=0;  
end
if fileexist==3
    error('Output file exists')
elseif fileexist==1
    fileow=1;
else
    fileow=0;
end

disp('Running salcalappGEN') % _bot_.all -> _bot_.cal ; .edt -> .clb
if salcalappGEN(aaa),bl=1; 
   break, end %apply at this stage to allow different fallrate algorithms to be applied to calibrated data
 
disp('Running splitcastGEN') % .clb -> .clb.up & .clb.dn
if splitcastGEN(aaa,fileow), bl=1; 
  break, end
 
disp('Running fallrateGEN') % .clb.dn -> .clb.dn
if fallrateGEN(aaa),bl=1; 
   break, end
 
disp('Running gridctdGEN') % .clb.dn -> _cal.2db.mat ; .clb.up -> _cal.2db.up.mat
if gridctdGEN(aaa,fileow),bl=1; 
   break, end

disp('Running onehzctdGEN') % .clb -> _cal.1hz
if onehzctdGEN(aaa,fileow),bl=1; 
   break, end
bl=1;
end
end