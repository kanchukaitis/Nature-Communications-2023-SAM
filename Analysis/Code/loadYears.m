function[X] = loadYears(grid, years)
%% Loads requested years from gridfile with coordinate data
% Throws an error if the years are not in the dataset
%
% X = loadYears(grid, years)
%
% ----- Inputs -----
%
% grid: A gridfile
%
% years: A vector of the years to load
%
% ----- Outputs -----
%
% X: The loaded data (coord x time)

[ismem, y] = ismember(years, grid.meta.time);
assert(all(ismem), 'grid does not have the requested years');
X = grid.load(["coord","time"], {[], y});

end