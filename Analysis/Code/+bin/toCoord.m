function[coord, Vq, meta, Vfill] = toCoord(grid, file, lowres)
%% Bins data to a lower resolution grid and converts to a coordinate array
%
% [coord, Vq, Vfill] = bin.toCoord(grid, file, lowres)
%
% ----- Inputs -----
%
% grid (scalar spatialGrid object): A spatial grid
%
% file (string scalar): The name of a gridfile with data on the spatial grid
%
% lowres (scalar spatialGrid object): The new, low-resolution spatial grid
%
% ----- Outputs -----
%
% coord: The coordinate metadata of the final data array
%
% Vq: The binned coordinate data array
%
% meta: The gridfile metadata for the binned data
%
% Vfill: The percent of each bin filled

[V, meta] = grid.load(file);
[Vq, Vfill] = grid.bin(V, lowres);
[coord, Vq, Vfill] = lowres.ungrid(Vq, Vfill);

end