function[] = MarshallDJF
%% Organizes the DJF Marshall Index in a .grid file
%
% organize.MarshallDJF()
%
% Extracts the dataset from the raw .txt file. Saves the time series to a
% .mat file and catalogues the saved data in a .grid file.

% Load the dataset from the .txt file
data = readmatrix('Marshall_DJF.txt', 'NumHeaderLines', 4);
years = data(:,1);
index = data(:,2);
units = 'hPa';

% Save .mat file
save('marshall-djf.mat', 'years', 'index', 'units', '-v7.3');

% Build gridfile
meta = gridfile.defineMetadata('time', years);
grid = gridfile.new('marshall-djf.grid', meta, [], true);
grid.add('mat', 'marshall-djf.mat', 'index', "time", meta);

end

