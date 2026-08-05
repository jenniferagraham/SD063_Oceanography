% Find all MSS files
MSSDataP = 'L:\work\scientific_work_areas\oceanography\MSS34\DATA\fasteps';
files = dir([MSSDataP,'*eps.mat']); %SD6300*2db_
%%
if isempty(files)
    error('No MSS files found.');
end

% Extract cast numbers from filenames
cast_numbers = zeros(length(files),1);

for i = 1:length(files)
    % Filename example: SD063_ctd_002_SS_005_2db.mat
    tokens = regexp(files(i).name,'SD063_ctd_(\d+)_','tokens');
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
     outfile = sprintf('SD063_ctd_%03d_struct.mat', cast);
    
     if exist(outfile,'file')
     display(outfile, 'already exist => skipping');
     else

    display('Processing %s\n', infile);

    % Load original file
    S = load(infile);
    S.station =cast; % add the cast number 
    % Put all variables into ctd structure
    ctd = S;
    % Save new structure file
    save(outfile,'ctd');
    end
end

fprintf('Finished.\n');
