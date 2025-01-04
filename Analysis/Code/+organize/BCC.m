function[] = BCC(mipvar, varName)
%% Organizes BCC model output into a .grid file
%
% organize.BCC(mipvar, varName)
%
% ----- Inputs -----
%
% mipvar: The variable name used by CMIP
%
% varName: The variable name to use for this study

f = sprintf('%s_Amon_bcc-csm1-1_past1000_r1i1p1_085001-185012.nc', mipvar);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = ( datetime(850, 1, 15) : calmonths(1) : datetime(2000, 12, 15) )';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-bcc.grid', varName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

meta.time = time(1:12012);
grid.add('nc', f, mipvar, dimOrder, meta);

f2 = sprintf('%s_Amon_bcc-csm1-1_past1000_r1i1p1_185101-200012.nc', mipvar);
meta.time = time(12013:end);
grid.add('nc', f2, mipvar, dimOrder, meta);

end