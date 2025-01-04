function[] = CR20(var, newName)
%% Catalogues 20CR NetCDF data in a .grid file
%
% organize.CR20(var, newName)
% 
% ----- Inputs -----
%
% var: The name of a 20CR variable
%
% newName: The name by which to refer to the variable in this study

% Get the metadata
file = sprintf('%s.mon.mean.nc', var);
lat = ncread(file, 'lat');
lon = ncread(file, 'lon');
time = datetime(1800,1,1,0,0,0) + hours(ncread(file, 'time'));
time = time + caldays(14);

% Get the name of the variable in the NetCDF file
var = char(var);
if contains(var, '.')
    var = var(1:find(var=='.',1)-1);
end

% Build the .grid file
newFile = sprintf('%s-20cr.grid', newName);
meta = gridfile.defineMetadata('lat',lat, 'lon', lon, 'time', time);
grid = gridfile.new(newFile, meta, [], true);
dimOrder = ["lon","lat","time"];
grid.add('nc', file, var, dimOrder, meta);

end