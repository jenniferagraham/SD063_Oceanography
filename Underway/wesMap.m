function cmapnew = wesMap(map_name, num_colors)
% Load data matrix for Wes Anderson style colormaps
% Options include: Budapest, Calvacanti, Chevalier, Darjeeling, Fox, Isle
% MoonriseSam, MoonriseSuzy, Rushmore, Tenenbaums, Zissou.
% Optionally include the number of colors desired to discretize.


load WesAndersonColors.mat map

for ii = 1:numel(map)
    if strcmp(map(ii).name,[map_name]) || strcmp(map(ii).name,[map_name 'FWD'])
        data = map(ii).data;
    end
end

if ~exist('data', 'var')
    error('colormap not found')
end

if nargin > 1
    step = round(length(data)/num_colors);
    ind = 1:step:length(data);
    data = data(ind,:);
end

cmapnew = data;