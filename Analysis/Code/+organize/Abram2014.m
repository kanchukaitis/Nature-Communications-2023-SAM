function[] = Abram2014
%% Organizes the Abram et al., 2014 SAM reconstruction in a .grid file.
%
% ----- Outputs -----
%
% Creates a .mat and .grid file named: "abram-2014"

% Load the data from the text file
data = readmatrix('abram2014sam.txt', 'NumHeaderLines', 102);

% Get years and index
years = data(:,1);
sam = data(:,2);

% Organize in ascending time
years = flipud(years);
sam = flipud(sam);

% Save
file = "abram-2014";
save(file, "sam", "years", '-v7.3');

% Gridfile
meta = gridfile.defineMetadata("time", years);
atts = struct("season", "Annual (Jan-Dec)", "Normalized", 1961:1990);
grid = gridfile.new(file, meta, atts, true);
grid.add("mat", sprintf('%s.mat',file), 'sam', "time", meta);

end