function[] = pdsi(name, atlas, cafecLimit, gridID)
%% Estimates PDSI values over a drought atlas domain for a model or reanalysis.
%
% estimate.atlas.pdsi(atlas, name, cafec, gridID)
%
% ----- Inputs -----
%
% atlas: The name of a drought atlas
%
% name: The name of a model or reanalysis
%
% cafecLimit: The first and last year to use for CAFEC normalizations
%
% gridID: The ID of the spatial grid to use
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "{atlas}-pdsi-{name}-{gridID}"

% Get the temperature data
Tfile = sprintf('%s-tref-%s-%s.grid', atlas, name, gridID);
[T, meta] = gridfile(Tfile).load;
T = T - 273.15;       % Kelvin to Celsius

% Get the precipitation data
Pfile = sprintf('%s-precip-%s-%s.grid', atlas, name, gridID);
P = gridfile(Pfile).load;
P = P * 60 * 60 * 24 * 30; % mm/s to mm/month

% Get the other inputs to the PDSI script
lats = meta.coord(:,1);
awcs = 25.4 * ones(size(lats));
awcu = 127 * ones(size(lats));
yearLimit = year([meta.time(1), meta.time(end)]);

% Adjust FGOALS CAFEC to account for missing 2000
if strcmp('fgoals', name) && cafecLimit(2)>1999
    cafecLimit(2) = 1999;
end

% Remove years with missing data
missing = all(isnan(T), 1);
missingYear = unique(year(meta.time(missing)));
remove = ismember(year(meta.time), missingYear);

T(:, remove) = [];
P(:, remove) = [];
meta.time(remove) = [];
yearLimit(1) = yearLimit(1) + numel(missingYear);

% Estimate PDSI
[X, Xm] = pdsi(T, P, yearLimit, lats, awcs, awcu, cafecLimit, 2);

% Save
file = sprintf('%s-pdsi-%s-%s', atlas, name, gridID);
save(file, 'X', 'Xm', 'meta', 'cafecLimit', '-v7.3');

% Gridfile
meta = rmfield(meta, 'attributes');
atts = struct('cafecLimit', cafecLimit);
grid = gridfile.new(file, meta, atts, true);
grid.add('mat', sprintf('%s.mat',file), 'Xm', ["coord","time"], meta);

end