% quick plot of MSS casts
% load data and plots a series of stations

% this is data was processed
%% define the paths
mac=1;
% paths
if mac==0
    dataP = 'C:\Users\sa07lc\OneDrive - SAMS\Desktop\MSS\DATA_sd034\fasteps\upcast\';
else
    dataP = 'L:\work\scientific_work_areas\oceanography\MSS34\DATA\fasteps\';
end

%% to plot in a raw
stn1 = flip([31:43]); % inside the sill tow-yo - plotting left to right
stn2 = flip([44:55]); % glacier front tow-yo - plotting left to right

%%
%clf
stn=stn2;
for ii=1:length(stn) % select range of casts for this station
figure; % Open a new figure for plotting this cast

    mssname= ['SD6300',num2str(stn(ii)),'_eps.mat'];
    load ([dataP,mssname]);
    % setting values for each cast in the relevant variables
    myPress = [data.press]; %(:,ii)
    myT     = [data.temp]; %(:,ii)
    myS     = [data.sal]; %(:,ii)
    myEPS   = [data.epsilon]; %(:,ii)

    title('MSS cast ')
    % profile plots
    %hold on
    % Temp plot
    % Does this need to be converted to theta?
    subplot(1,3,1); hold on
    plot(myT,myPress,color="r")
    xlabel('Temperature (°C)')
    ylabel('Pressure (dbar)')
    if ii==length(stn)
        ax = gca; ax.XAxisLocation = 'top';
        ax.YDir = 'reverse'; % Invert the y-axis
        box on
    % Invert the Y-axis regardless of previous if clause 
    set(gca, 'YDir', 'reverse');
    end
    % Salinity plot
    subplot(1,3,2); hold on
    plot(myS,myPress,color="b")
    xlabel('Salinity (psu)')
    ylabel('Pressure (dbar)')
    if ii ==length(stn)
        ax = gca; ax.XAxisLocation = 'top';
        ax.YDir = 'reverse'; % Invert the y-axis
        box on
    % Invert the Y-axis regardless of previous if clause 
    set(gca, 'YDir', 'reverse');
    end
    % Epsilon plot
    subplot(1,3,3); hold on
    plot(myEPS,myPress,color="g")
    xlabel('\epsilon')
    ylabel('Pressure (dbar)')
    if ii==length(stn)
        ax = gca; ax.XAxisLocation = 'top';
        ax.YDir = 'reverse'; % Invert the y-axis
        box on
        ylabel('Press db')
    % Invert the Y-axis regardless of previous if clause 
    set(gca, 'YDir', 'reverse');
    end
end