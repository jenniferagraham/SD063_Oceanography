% Edited by Ellie Fisher on 12.8.2026 (SD063 GIANT)
% Calibrates either CTD or underway salinity from sal files

% Specify the file name
% Specify the folder path and base file name
addpath 'L:\work\scientific_work_areas\oceanography\CTD\Code'
CTDvarn  %only really need to ensure gsw filepath defined, + cruise

inputFolderPath = 'SalinometerCondRatios\';
outputFolderPath = 'salinities\';
cu=input('CTD profiles (c) or underway (u)?\n','s');
if cu=='u'
baseFileName = ['sal_',cruise,'_underway_'];
il=input('enter file number\n');
il2=il;  %individual crates
else
baseFileName = ['sal_',cruise,'_'];
il=input('enter first ctd\n');
il2=input('enter last ctd\n');
end


BathTemp=21;
disp(['Bath Temperature used here is ',num2str(BathTemp),'C'])
%disp('Update Salinometer bath temperature if changed')
tcheck=say_what(input('Confirm this is correct y/n \n','s'));

if tcheck

for i = il:il2
    % Create the current file name
    currentFileName = sprintf('%s%03d.csv', baseFileName, i);
    
    % Create the full path to the file
    inputFileName = fullfile(inputFolderPath, currentFileName);

    % Check if the file exists
    if exist(inputFileName, 'file') == 2
        % Read the CSV file
        data = readtable(inputFileName);

        % Extract the values in the third column
        conductivityRatio = data(:, 3).Variables / 2;

        % Apply the function to each value
        salinityResults = arrayfun(@(value) gsw_SP_salinometer(value, BathTemp), conductivityRatio);
        
        % Convert salinityResults to a table
        salinityResultsTable = table(salinityResults, 'VariableNames', {'SalinityResults'});

        % Concatenate the new table with the original table
        data = [data, salinityResultsTable];

        % Write the updated table to a new CSV file
        outputFileName = fullfile(outputFolderPath, ['output_' currentFileName]);
        writetable(data, outputFileName);

        disp(['Processed ' inputFileName ' and saved results to ' outputFileName]);
    else
        disp(['File ' inputFileName ' does not exist. Moving on to the next file.']);
    end
end

disp('Processing complete.');

else
    disp('Adjust bath temperature in this script')
end