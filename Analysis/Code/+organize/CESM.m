function[] = CESM(var, newName)
%% Catalogues CESM output in a .grid file
%
% organize.CESM(var, newName)
%
% ----- Inputs -----
%
% var: The name of a variable with output from CESM
%
% newName: The name to use for the variable in this study

f = sprintf('b.e11.BLMTRC5CN.f19_g16.002.cam.h0.%s.085001-184912.nc', var);
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
time = (datetime(850, 1, 15) : calmonths(1) : datetime(2005, 12, 15))';

meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
file = sprintf('%s-cesm.grid', newName);
grid = gridfile.new(file, meta, [], true);
dimOrder = ["lon","lat","time"];

meta.time = time(1:12000);
grid.add('nc', f, var, dimOrder, meta);

f2 = sprintf('b.e11.BLMTRC5CN.f19_g16.002.cam.h0.%s.185001-200512.nc', var);
meta.time = time(12001:end);
grid.add('nc', f2, var, dimOrder, meta);

end