function[] = atlas(atlasName, grid)
%% Bins a drought atlas to a lower resolution spatial grid
%
% bin.atlas(atlasName, grid)
%
% ----- Inputs -----
%
% atlasName (string scalar): The name of a drought atlas
%
% grid (scalar spatialGrid object): A low-resolution spatial grid
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "{atlas}-{gridID}"

% Get the spatial grid that minimally surrounds the drought atlas
atlas = spatialGrid.atlas(atlasName);
grid = grid.surround(atlas);

% Bin to the low-resolution grid and convert to coordinate array
file = sprintf('%s.grid', atlasName);
[coord, Vq, meta, Vfill] = bin.toCoord(atlas, file, grid);

% Remove NaN sites
nans = all(isnan(Vq), 2);
coord(nans,:) = [];
Vq(nans,:) = [];
Vfill(nans,:) = [];

% Save and create .grid file
file = sprintf('%s-%s', atlasName, grid.id);
bin.save(file, 'pdsi', Vq, Vfill, coord, meta.time, grid);

end