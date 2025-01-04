function[] = R(atlas, reanalysis, Ryears, gridID)
%% Estimates drought atlas error covariances (R) from a reanalysis
%
% estimate.atlas.R(atlas, reanalysis, Ryears, gridID)
%
% ----- Inputs -----
%
% atlas: The name of the drought atlas to estimate for
%
% reanalysis: The name of the reanalysis to use to estimates
%
% Ryears: The years to use for the calculation
%
% gridID: The ID of the spatial grid to use
%
% ----- Outputs -----
%
% Creates a .mat file named: "{atlas}-R-{reanalysis}-{gridID}"

% Get the downgridded atlas, and reanalysis atlas estimate
atlasGrid = gridfile( sprintf('%s-%s.grid',atlas,gridID) );
estimates = gridfile( sprintf('%s-%s-%s.grid',atlas,reanalysis,gridID) );

% Load the calculation years
Y = loadYears(atlasGrid, Ryears);
Ye = loadYears(estimates, Ryears);

% Error covariances
error = Ye - Y;
R = cov(error', 'omitrows');

% Ensure positive eigenvalues
% (Because the atlases are linearly dependent, numerical rounding errors
% can lead to small negative eigenvalues)
nSite = size(R,1);
adjust = 1E-8 * ones(nSite, 1);
R = R + diag(adjust);
assert(min(eig(R))>0);

% Update metadata
meta = estimates.metadata;
meta = rmfield(meta, 'time');
meta.attributes.Ryears = Ryears;

% Save
file = sprintf('%s-R-%s-%s', atlas, reanalysis, gridID);
save(file, 'R', 'meta');

end