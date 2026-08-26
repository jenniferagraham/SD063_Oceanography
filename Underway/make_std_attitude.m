function make_std_attitude(startday, endday, yy, interval)
%MAKE_STD_ATTITUDE(startday, endday, yy, interval)
% This function processes and averages attitude data (roll, pitch, and heave)
% from shipboard navigation sensors over a specified time range and interval.
%
% PARAMETERS:
%   startday  - (Optional) Start Julian day for averaging. If not provided, prompts user input.
%   endday    - (Optional) End Julian day for averaging. If not provided, prompts user input.
%   yy        - (Optional) Year (e.g., 2024). Defaults to the current year.
%   interval  - (Optional) Averaging interval in minutes. Defaults to 1 minute.
%
% FUNCTIONALITY:
% - Loads attitude data from navigation sensors.
% - Allows the user to specify a custom start and end time (or defaults to full days).
% - Filters data within the given time range.
% - Computes and stores the maximum and average roll, pitch, and heave values at the chosen interval.
% - Saves the processed results to a CSV file.
%
% OUTPUT:
% - A CSV file containing time-binned maximum and average values of roll, pitch, and heave.
%
% NOTE:
% - If no interval is specified, the function defaults to 1-minute averages.
% - If no start or end day is provided, the function prompts user input for these values.
%
% USAGE EXAMPLE:
%   make_std_attitude(15, 20, 24, 30)
%   -> Processes data from Julian day 15 to 20 in the year 2024, with 30-minute intervals.

% check for interval, otherise run for 30min intervals
if nargin < 4
    fprintf('This script creates averages at a 1min interval.\n');
    interval = input(['If you wish for a different length sepcify time here (note input must be even) \n' ...
        'eg. 30 for half an hour intervals (otherwise leave blank): ']);
    if isempty(interval)
        interval = 1;
    end
end

set_underway_params

% check for time interval 
if nargin < 3
    yy = year(datetime('now'));
end 

if nargin < 2
    startday = input('Input start jday to begin the averaging (blank for first day): ');  
    endday = input('Input end jday to end averaging at (blank for last day): ');
end

% loop through each sensor
for q=1:length(hpr_sensor_sets)

    %% load data
    hpr=load(fullfile('..','nav',hpr_sensor_sets(q).hpr_table,...
        [hpr_sensor_sets(q).hpr_table,'_all.mat']));
    data=hpr.(hpr_sensor_sets(q).hpr_table);

    %% check for start and end day + start and end time
    jday_start = round(data.time_jday(1));
    jday_end = round(data.time_jday(end));

    if isempty(startday) startday = jday_start; end
    if isempty(endday) endday = jday_end; end

    if q == 1
        choose_time = say_what(input("Do you wish to introduce a desired time? (no will result in periods midnight to midnight) yes/no: ", 's'));

        
        if choose_time == 1
            start_time = input('Input starting time in 24-hour format (e.g., 0630 or 1830): ', 's');  
            start_time = convertTime(start_time);
            
            end_time = input('Input ending time in 24-hour format (e.g., 0630 or 1830): ', 's');  
            end_time = convertTime(end_time);

            % Define time range for selection
            start_time = datetime(yy, 1, startday) + start_time; 
            end_time = datetime(yy, 1, endday) + end_time;
        
            fprintf("Starting at %s, Ending at %s\n", start_time, end_time);
        else
            start_time = datetime(yy, 1, startday); 
            end_time = datetime(yy, 1, endday);
        end
    end

    % set up variables
    time = datetime(data.time, 'ConvertFrom', 'datenum');
    roll = data.roll;
    pitch = data.pitch;
    heave = data.heave;
    
    % Filter data within the time range
    valid_idx = (time >= start_time) & (time <= end_time);
    time = time(valid_idx);
    roll = roll(valid_idx);
    pitch = pitch(valid_idx);
    heave = heave(valid_idx);
    
    % Define bin edges for 30-minute intervals
    bin_edges = start_time:minutes(interval):end_time;
    num_bins = length(bin_edges) - 1;
    
    % Initialize output arrays
    binned_time = bin_edges(1:end-1) + minutes(interval/2); % Center of bins
    max_roll = zeros(num_bins, 1);
    max_pitch = zeros(num_bins, 1);
    max_heave = zeros(num_bins, 1);
    avg_roll = zeros(num_bins, 1);
    avg_pitch = zeros(num_bins, 1);
    avg_heave = zeros(num_bins, 1);
    
    % Bin data and compute max and average values (helpful for standard
    % deviation)
    for i = 1:num_bins
        bin_idx = (time >= bin_edges(i)) & (time < bin_edges(i+1));
        if any(bin_idx)
            max_roll(i) = max(abs(roll(bin_idx).*hpr_sensor_sets(q).hpr_scale_factor));
            max_pitch(i) = max(abs(pitch(bin_idx).*hpr_sensor_sets(q).hpr_scale_factor));
            max_heave(i) = max(abs(heave(bin_idx).*hpr_sensor_sets(q).hpr_scale_factor));
            avg_roll(i) = mean(abs(roll(bin_idx)).*hpr_sensor_sets(q).hpr_scale_factor);
            avg_pitch(i) = mean(abs(pitch(bin_idx)).*hpr_sensor_sets(q).hpr_scale_factor);
            avg_heave(i) = mean(abs(heave(bin_idx)).*hpr_sensor_sets(q).hpr_scale_factor);
        else
            max_roll(i) = NaN;
            max_pitch(i) = NaN;
            max_heave(i) = NaN;
            avg_roll(i) = NaN;
            avg_pitch(i) = NaN;
            avg_heave(i) = NaN;
        end
    end
    
    % Save results to CSV file
    results = table((binned_time-minutes(15))', max_roll, max_pitch, max_heave, avg_roll, avg_pitch, avg_heave,...
        'VariableNames', {'Time', 'Max_Roll', 'Max_Pitch', 'Max_Heave', 'Avg_Roll', 'Avg_Pitch', 'Avg_Heave'});
    
    fprintf('Saving file %s.\n', hpr_sensor_sets(q).hpr_table);
    writetable(results, ...
        fullfile('..',strcat(cruisename,'_nav',hpr_sensor_sets(q).file_add, ...
            sprintf('_%d-%d_%d',startday, endday,interval),'min_std.csv')));

    figure;
    subplot(3,1,1)
    scatter(binned_time', max_roll,7,[1 0.01 0.8],'filled')
    title("Max Roll")

    subplot(3,1,2)
    scatter(binned_time', max_pitch,7,[0.8 0 0.5],'filled')
    title("Max Pitch")

    subplot(3,1,3)
    scatter(binned_time', max_heave,7,[0.7 0 0.9],'filled')
    title("Max Heave")

    sgtitle(hpr_sensor_sets(q).hpr_table)
end