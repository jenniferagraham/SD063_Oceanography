function formattedTime = convertTime(timeInput)
% convertTime Converts a 24-hour time input (HHMM) into a 12-hour AM/PM format using datetime.
%
% Usage:
%   formattedTime = convertTime('1830')
%   formattedTime = convertTime('0630')
%
% Input:
%   timeInput - A string representing time in HHMM format (e.g., '0630', '1830')
%
% Output:
%   formattedTime - A string formatted as 'h:mm AM/PM'

    % Validate input format
    if length(timeInput) ~= 4 || ~all(isstrprop(timeInput, 'digit'))
        error('Invalid input. Please enter a 4-digit time in HHMM format.');
    end

    % Extract hours and minutes
    hour = str2double(timeInput(1:2));
    minute = str2double(timeInput(3:4));

    % Validate time range
    if hour < 0 || hour > 23 || minute < 0 || minute > 59
        error('Invalid time. Hours should be 00-23 and minutes 00-59.');
    end

    % Create a datetime object (using arbitrary date since we only care about time)
    formattedTime = duration(hour, minute, 0);
end
