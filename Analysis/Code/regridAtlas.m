function[Vq, atlas] = regridAtlas(atlas, V, coord)
%% Regrids a coordinate atlas grid to cartesian coordinates
%
% [Vq, atlas] = regridAtlas

% Get the spatial grid for the full atlas
atlas = spatialGrid.atlas(atlas);

% Preallocate
nLon = size(atlas.lon);
nLat = size(atlas.lat);
nTime = size(X, 2);
Vq = NaN(nLat, nLon, nTime);

% Infill each row
for k = 1:size(V,1)
    r = atlas.lat == coord(k,1);
    c = atlas.lon == coord(k,2);
    Vq(r,c,:) = V(k,:);
end

end