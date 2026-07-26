% Ask user for cast number
cast = input('Enter cast number: ');

% Build input filename
filename = sprintf('L:\work\scientific_work_areas\oceanography\CTD\BASproc\SD063_ctd_%03d_SS_012_2db.mat', cast);

% Find matching file
files = dir(filename);

if isempty(files)
    error('No file found matching %s', filename);
elseif length(files) > 1
    error('Multiple files found. Please check the filename pattern.');
end

infile = files(1).name;

fprintf('Loading %s\n', infile);

% Load the file
S = load(infile);

% Put everything into a structure
ctd = S;

% Create output filename
outfile = strrep(infile,'.mat','_struct.mat');

% Save structure
save(outfile,'ctd');

fprintf('Saved as %s\n', outfile);
