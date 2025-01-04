function[] = overAtlas(name, var, atlasName, id)
%% Bins a model or reanalysis variable over the domain of a drought atlas
%
% bin.overAtlas(name, var, atlasName, id)
%
% ----- Inputs -----
%
% name (string scalar): The name of a model or reanalysis
%
% var (string scalar): The name of a variable to bin
%
% atlasName (string scalar): The name of a drought atlas over which to bin the variable
%
% id (string scalar): The id of the spatial grid to use for the binning
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "{atlas}-{var}-{name}-{id}"

% Get the drought atlas grid
atlasFile = sprintf('%s-%s.grid', atlasName, id);
atlas = gridfile(atlasFile).meta.attributes.grid;

% Find the spatial grid that minimally surrounds the binned atlas
grid = spatialGrid.model(name, var);
minimal = grid.surround(atlas);

% Bin the data in the minimal domain and convert to coordinate array
file = sprintf('%s-%s.grid', var, name);
[coord, Vq, meta, Vfill] = bin.toCoord(minimal, file, atlas);

% Only use sites that are in the binned atlas
use = ismember(coord, gridfile(atlasFile).meta.coord, 'rows');
Vq = Vq(use,:);
Vfill = Vfill(use,:);
coord = coord(use,:);

% Save and create gridfile
file = sprintf('%s-%s-%s-%s', atlasName, var, name, id);
bin.save(file, var, Vq, Vfill, coord, meta.time, atlas);

end