% open tob files 

clear all 
close all 
testfile= '/Volumes/legwork/scientific_work_areas/oceanography/MSS34/DATA/converted/';
fid=fopen([testfile, 'convert.tob']); 
disp(fgetl(fid))

for i = 1:50
    line = fgetl(fid);
    if ischar(line)
        disp(line)
    end
end
fclose(fid)

T = readtable([testfile, 'convert.tob'],'FileType','text');

% column headings :  NTC                  PRESS                SHE1                 TEMP                 SHE2                 COND                 ACC                  NTCHP                ACCx                 ACCy                 
%;                   [degC]               [dbar]               [6079]               [degC]               [6081]               [mS/cm]              [m/s2]               [degC]               [g]                  [g]                  


fall_speed = diff(T.Var3) ./ diff(time);