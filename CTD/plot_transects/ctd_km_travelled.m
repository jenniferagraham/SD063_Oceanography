close all; clear all;

if ispc
    disk = ['L:\work\scientific_work_areas\oceanography\'];
    ctddata = [disk,'CTD\BASproc\'];
else
    disk = ['/Volumes/legwork/scientific_work_areas/oceanography/'];
    ctddata = [disk,'CTD/BASproc/'];
end

cruise='SD063';
load([ctddata,cruise,'_ctd.mat']);

ncasts = length(ctds);

sumdepth = 0;

for n=1:ncasts
    maxdepth = max(ctds(n).depth);
    sumdepth = sumdepth + maxdepth*2;
end

fprintf('CTD has now travelled %.2f km\n',sumdepth/1000);

