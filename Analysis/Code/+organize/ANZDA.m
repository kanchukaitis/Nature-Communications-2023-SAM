function[] = ANZDA
%% Cleans the ANZDA dataset and organizes it in a .grid file
%
% organize.ANZDA()
% Reads data and metadata from the ANZDA reconstruction .txt files, saves
% to a .mat file, and catalogues the saved data in a .grid file.

% Extract the data from the .txt files
data = readmatrix('anzda-recon.txt', 'NumHeaderLines', 1);
years = data(:,1);
data(:,1) = [];

% Get the coordinate metadata
meta = readmatrix('anzda-pdsi-xy.txt');
lon = meta(:,1);
lat = meta(:,2);

lons = sort(unique(lon));
lonStep = min(abs(diff(lons)));
lons = min(lons) : lonStep : max(lons);

lats = sort(unique(lat));
latStep = min(abs(diff(lats)));
lats = min(lats) : latStep : max(lats);

% Preallocate 3D data grid
nLon = numel(lons);
nLat = numel(lats);
nTime = numel(years);
anzda = NaN(nLon, nLat, nTime);

% Place the data matrix in the grid
for s = 1:size(data,2)
    row = lons == lon(s);
    col = lats == lat(s);
    anzda(row, col, :) = data(:,s);
end

% Save to .mat file
save('anzda.mat', 'anzda', 'lon', 'lat', 'years', '-v7.3');

% Create .grid file
meta = gridfile.defineMetadata('lon',lons','lat',lats','time',years);
grid = gridfile.new('anzda.grid', meta, [], true);
dimOrder = ["lon", "lat", "time"];
grid.add('mat', 'anzda.mat', 'anzda', dimOrder, meta);

end








