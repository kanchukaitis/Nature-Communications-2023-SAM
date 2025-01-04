function[] = IPSL(mipvar, varName)
%% Organizes IPSL model output into a .grid file
%
% organize.IPSL(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_IPSL-CM5A-LR_past1000_r1i1p1_085001-104912.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-ipsl.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

for k = 850:200:1650
    f = sprintf('%s_Amon_IPSL-CM5A-LR_past1000_r1i1p1_%04.f01-%4.f12.nc', mipvar, k, k+199);
    meta.time = (datetime(k,1,15):calmonths(1):datetime(k+199,12,15))';
    grid.add('nc', f, mipvar, dimOrder, meta);
end

f = sprintf('%s_Amon_IPSL-CM5A-LR_historical_r1i1p1_185001-200512.nc', mipvar);
meta.time = (datetime(1850,1,15):calmonths(1):datetime(2005,12,15))';
grid.add('nc', f, mipvar, dimOrder, meta);

end