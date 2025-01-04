function[] = Villalba2012
%% Organizes the Villalba et al., 2012 SAM reconstruction in a gridfile
% Specifically, organizes the Marshall index reconstruction
%
% ----- Outputs -----
%
% Creates a .mat and .grid file named: "villalba-2012"

% Load data from the text file
data = readmatrix("villalba2012sam.txt", 'NumHeaderLines', 136);
years = data(:,1);
sam = data(:,4);

% Remove the missing final year
years(end) = [];
sam(end) = [];

% Save
file = "villalba-2012";
save(file, "sam", "years", '-v7.3');

% Gridfile
meta = gridfile.defineMetadata("time", years);
grid = gridfile.new(file, meta, [], true);
grid.add("mat", sprintf('%s.mat',file), 'sam', "time", meta);

end