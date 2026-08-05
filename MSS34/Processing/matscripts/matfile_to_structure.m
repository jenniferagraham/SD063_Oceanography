close all; clear all;

% Find all MSS files
MSSDataP = 'L:\work\scientific_work_areas\oceanography\MSS34\DATA\';
files = dir(fullfile(MSSDataP,'fasteps\','*eps.mat'));

%%
if isempty(files)
    error('No MSS files found.');
end

% Extract cast numbers from filenames
cast_numbers = zeros(length(files),1);

for i = 1:length(files)
    % Filename example: SD630002_eps.mat
    % search for number in filename % export to tokens outkey
    tokens = regexp(files(i).name,'SD6300(\d+)_','tokens'); 
    cast_numbers(i) = str2double(tokens{1}{1});
end

% Largest cast number
max_cast = max(cast_numbers);

fprintf('Found casts 1 to %d\n', max_cast);
%%

% Loop through casts
for cast = 1:max_cast

    % Find file for this cast
    idx = find(cast_numbers == cast);

    if isempty(idx)
        fprintf('Cast %d missing - skipping\n', cast);
        continue
    elseif length(idx) > 1
        warning('Multiple files found for cast %d - using first one', cast);
        idx = idx(1);
    end

    infile = files(idx).name;
     outfile = sprintf('SD063_mss_%03d_struct.mat', cast);
    
     if exist(outfile,'file')
     display(outfile, 'already exist => skipping');
     else

    display(['Processing %s\n', infile]);

    % Load original file
    S = load(fullfile(MSSDataP,'fasteps\',infile));
    S.station =cast; % add the cast number 
    % Put all variables into mss structure
    mss = S;
    mss.data.corrsal = mss.data.sal - 0.080274;
    % Save new structure file
    save(fullfile(MSSDataP,outfile),'mss');
    end
end

fprintf('Finished.\n');
