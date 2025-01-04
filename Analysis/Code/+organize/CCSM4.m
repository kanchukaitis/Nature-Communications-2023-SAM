function[] = CCSM4(mipvar, varName)
%% Organizes CCSM4 model output into a .grid file
%
% organize.CCSM4(mipvar, varName)
% Removes overlapping years from historical data and saves subset to .mat
% file. Catalogues NetCDF and .mat data in a .grid file.
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

% Load the historical dataset and its metadata
f = sprintf('%s_Amon_CCSM4_historical_r1i1p1_185001-200512.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
X = ncread(f, mipvar);

% Remove 1850 overlap
X(:,:,1:12) = [];
time = (datetime(1851,1,15):calmonths(1):datetime(2005,12,15))';

% Save historical subset
saveFile = sprintf('ccsm4-historical-%s.mat', varName);
s = struct('lat',lat,'lon',lon,'time',time,varName,X);
save(saveFile, '-struct', 's', '-v7.3');

% Create the .grid file
newFile = sprintf('%s-ccsm4.grid', varName);
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
grid = gridfile.new(newFile, meta, [], true);

% Add the data sources
dimOrder = ["lon","lat","time"];
file = sprintf('%s_Amon_CCSM4_past1000_r1i1p1_085001-185012.nc', mipvar);
meta.time = time(1:12012);
grid.add('nc', file, mipvar, dimOrder, meta);

meta.time = time(12013:end);
grid.add('mat', saveFile, varName, dimOrder, meta);

end