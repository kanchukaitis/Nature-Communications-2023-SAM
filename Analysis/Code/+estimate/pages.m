function[] = pages(name)
%% Estimates PAGES proxies for a model or reanalysis.
% Estimates by applying regression coefficients to derived seasonal
% temperatures
%
% estimate.pages(name)
%
% ----- Inputs -----
%
% name: The name of the model or reanalysis
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "pages-{name}"

% Load the regression coefficients and derived seasonal temperatures
coeffs = load('pages-regression.mat');
tempsFile = sprintf('%s-pages-temperatures.ens', name);
ens = ensemble(tempsFile);
T = ens.load;

% Generate estimates
Ye = (coeffs.slope .* T) + coeffs.intercept;

% Save
file = sprintf('pages-%s', name);
meta = coeffs.meta;
meta.time = year(ens.metadata.variable(1, 'time'));
meta.attributes.regressionYears = coeffs.regressionYears;
meta.attributes.regressionTarget = coeffs.reanalysis;
save(file, 'Ye', 'meta', '-v7.3');

% Gridfile
atts = meta.attributes;
meta = rmfield(meta, 'attributes');
grid = gridfile.new(file, meta, atts, true);
grid.add('mat', sprintf('%s.mat',file), "Ye", ["coord", "time"], meta);

end