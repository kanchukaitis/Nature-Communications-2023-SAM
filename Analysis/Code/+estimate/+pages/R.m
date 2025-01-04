function[] = R(reanalysis, Ryears)
%% Estimates PAGES error covariances (R) from a reanalysis
%
% estimate.pages.R(reanalysis, Ryears)
%
% ----- Inputs -----
%
% reanalysis: The name of a reanalysis to use to estimate R
%
% Ryears: The years to use in the calculation
%
% ----- Outputs -----
%
% Creates a .mat file named: "pages-R-{reanalysis}"

% Get gridfiles for the estimates and real records
pages = gridfile('pages.grid');
estimates = gridfile(sprintf('pages-%s.grid', reanalysis));

% Load both in the R estmiate years
Y = loadYears(pages, Ryears);
Ye = loadYears(estimates, Ryears);

% Get the error covariance
error = Ye - Y;
R = var(error, [], 2, 'omitnan');
R = diag(R);

% Save
meta = estimates.metadata;
meta = rmfield(meta, 'time');
meta.attributes.Ryears = Ryears;

file = sprintf('pages-R-%s', reanalysis);
save(file, 'R', 'meta');

end