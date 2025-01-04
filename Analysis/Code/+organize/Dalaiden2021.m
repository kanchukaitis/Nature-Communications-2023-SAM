function[] = Dalaiden2021
%% Organizes the Dalaiden et al., 2021 SAM reconstructions in a grid file
% ----------
% Outputs:
%   Creates a .grid file named: "dalaiden-2021"

% Create the metadata
years = 1800:2000;
meta = gridfile.defineMetadata("time", years');

% Gridfile
grid = gridfile.new('dalaiden-2021', meta);
grid.add("nc", 'SAM-index_ano_annual_recon-antarctic_1800-2000.nc', 'SAM-index', "time", meta);

end