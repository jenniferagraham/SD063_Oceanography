% need to create a structure variable with all MSS data 
% row must be a station 
% column are the variables

close all; clear all;
savename = 'sd063_mss.mat';

%%
mac=0; % 1 mac or 0 windows
here=pwd;
if mac==0
    addpath 'L:\work\scientific_work_areas\oceanography\MSS34\'
    disk = ['L:\work\scientific_work_areas\']; 
    mssdataP = [disk,'oceanography\MSS34\DATA\'];

elseif mac==1
    slash='/';
    disk = ['/Volumes/legwork/scientific_work_areas/'];
    mssdataP = [disk,'oceanography/MSS34/DATA/']; 
end

mssdataList=fullfile(mssdataP,"stationlist.txt"); % list with all *_struct.mat files

%% Extract a csv with the locations of the SD063 MSS

filenames = readlines(mssdataList, 'EmptyLineRule', 'skip');
for ii = 1:length(filenames)

    currentName = filenames(ii); % indexing list of struct files

    load(fullfile(mssdataP,currentName))
    msss(ii) = mss; % should I change the names?
    msss(ii).lat=mss.data.lat;
    msss(ii).lon=mss.data.lon;
end

%%
save([mssdataP,savename],'msss')