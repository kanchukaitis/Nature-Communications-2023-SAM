function[] = FogtDJF
%% Organizes the DJF Fogt Index in a .grid file
%
% organize.FogtDJF
%
% Extracts the dataset from the raw .txt file. Saves the time series to a
% .mat file and catalogues the saved data in a .grid file

% Load the dataset from the .txt file
data = readmatrix("Fogt_DJF.txt", 'NumHeaderLines', 3);
years = data(:,1);
index = data(:,2);

% Save .mat file
save('fogt-djf.mat', 'years', 'index', '-v7.3');

% Build gridfile
meta = gridfile.defineMetadata('time', years);
grid = gridfile.new('fogt-djf.grid', meta, [], true);
grid.add('mat', 'fogt-djf.mat', 'index', 'time', meta);

end
