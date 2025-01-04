function[] = CESMPrecip(newName)
%% Cleans and organizes CESM precipitation output in a .grid file
%
% organize.CESMPrecip(newName)
% Adds convective and large-scale precipitation rates. Saves the total
% precipitation rate, and catalogues the saved data in a .grid file.

% File strings
files = ["b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.085001-184912.nc";
         "b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.185001-200512.nc";
         "b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECL.085001-184912.nc";
         "b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECL.185001-200512.nc"];

% Get metadata
lat = ncread(files(1), 'lat');
lon = ncread(files(1), 'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';

% Preallocate the final precipitation rate
nLon = numel(lon);
nLat = numel(lat);
nTime = numel(time);
P = zeros(nLon, nLat, nTime);

% Add the two precipitation rates
PRECC = cat(3, ncread(files(1),'PRECC'), ncread(files(2),'PRECC'));
PRECL = cat(3, ncread(files(3),'PRECL'), ncread(files(4),'PRECL'));
P = PRECC + PRECL;

% Save the total precipitation rate
newFile = sprintf('%s-cesm', newName);
save(newFile, 'lat','lon','time','P', '-v7.3');

% Build the .grid file
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
grid = gridfile.new(newFile, meta, [], true);
dimOrder = ["lon","lat","time"];
grid.add('mat', sprintf('%s.mat',newFile), 'P', dimOrder, meta);

end