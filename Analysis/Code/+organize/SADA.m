function[] = SADA
%% Organizes the SADA dataset into a .grid file
%
% organize.SADA()
% Catalogues the data in the SADA NetCDF file in a .grid file

% Metadata
f = 'SADA_tplus1.nc';
lats = ncread(f, 'latitude');
lons = ncread(f, 'longitude') + 360;
time = double(ncread(f, 'Time'));

% Gridfile
meta = gridfile.defineMetadata('lat', lats,'lon', lons,'time',time);
grid = gridfile.new('sada.grid', meta);
grid.add('nc', f, 'scpdsi', ["lon","lat","time"], meta);

end