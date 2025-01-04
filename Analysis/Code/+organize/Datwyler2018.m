function[] = Datwyler2018
%% Organizes the SAM reconstruction from Datwyler et al., 2018 in a gridfile
%
% organize.Datwyler2018
%
% ----- Outputs -----
%
% Creates a .mat and .grid file named: "Datwyler-2018"

% Load the data
data = readmatrix('Best_SAM_reconstruction.txt', 'NumHeaderLines', 1);

% Get the index of interest
years = data(:,1);
sam = data(:,2);
season = "DJF";

% Save
file = "datwyler-2018";
save(file, 'years', 'season', 'sam', '-v7.3');

% Gridfile
meta = gridfile.defineMetadata('time', years);
atts = struct('season', season);
grid = gridfile.new(file, meta, atts, true);
grid.add("mat", sprintf("%s.mat",file), "sam", "time", meta);

end