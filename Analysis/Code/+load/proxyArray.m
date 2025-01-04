function[Y, meta] = proxyArray(file, years)
%% Loads the proxy matrix from a file for a set of given years
%
% [Y, meta] = load.proxyArray(file, years)
%
% ----- Inputs -----
%
% file: The name of the file with the proxy data
%
% years: The years in which to load data
%
% ----- Outputs -----
%
% Y: The proxy matrix
%
% meta: Metadata associated with the proxy matrix

% Get the gridfile and metadata
grid = gridfile(file);
meta = grid.metadata;

% Preallocate the array
nSite = size(meta.coord, 1);
nTime = numel(years);
nRun = grid.size(6);
Y = NaN(nSite, nTime, nRun);

% Load the full proxy network
[X, meta] = grid.load(["coord","time"]);

% Fill in the temporal intersect
[~, useX, useY] = intersect(meta.time, years);
Y(:,useY,:) = X(:,useX,:);

% Update the metadata
meta.time = years(:);

end