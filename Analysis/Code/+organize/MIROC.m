function[] = MIROC(mipvar, varName)
%% Organizes MIROC model output into a .grid file
%
% organize.MIROC(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_MIROC-ESM_past1000_r1i1p1_085001-184912.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-miroc.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

meta.time = time(1:12000);
grid.add('nc', f, mipvar, dimOrder, meta);

f2 = sprintf('%s_Amon_MIROC-ESM_historical_r1i1p1_185001-200512.nc', mipvar);
meta.time = time(12001:end);
grid.add('nc', f2, mipvar, dimOrder, meta);

end