function[] = CSIRO(mipvar, varName)
%% Organizes CSIRO model output into a .grid file
%
% organize.CSRIO(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_CSIRO-Mk3L-1-2_past1000_r1i1p1_085101-185012.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = (datetime(851, 1, 15) : calmonths(1) : datetime(2000, 12, 15))';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-csiro.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

meta.time = time(1:12000);
grid.add('nc', f, mipvar, dimOrder, meta);

f2 = sprintf('%s_Amon_CSIRO-Mk3L-1-2_historical_r1i1p1_185101-200012.nc', mipvar);
meta.time = time(12001:end);
grid.add('nc', f2, mipvar, dimOrder, meta);

end