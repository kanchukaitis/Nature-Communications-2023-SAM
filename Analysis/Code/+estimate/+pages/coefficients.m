function[] = coefficients(reanalysis, regressionYears)
%% Estimate PSM coefficients for PAGES recrods.
% Estimates by regressing PAGES records against seasonal temperatures.
%
% estimates.pages.coefficients(reanalysis, regressYears)
%
% ----- Inputs -----
%
% reanalysis: The name of the reanalysis to use for the regression
%
% regressionYears: The years to use for the regression
%
% ----- Outputs -----
%
% Creates a .mat file named: "pages-regression"

% Get PAGES and the target seasonal ensemble
pages = gridfile('pages.grid');
target = ensemble(sprintf('%s-pages-temperatures.ens', reanalysis));

% Load data from the regression years
pyears = pages.meta.time;
tyears = year(target.metadata.variable(1, 'time'));

[ismem, yp] = ismember(regressionYears, pyears);
assert( all(ismem), 'Pages does not include the specified years' );
[ismem, yt] = ismember(regressionYears, tyears);
assert( all(ismem), 'The target does not include the specified years');

Y = pages.load(["coord","time"], {[], yp});
target = target.useMembers(yt);
T = target.load;

% Preallocate the regression statistics
nSite = size(Y,1);
slope = NaN(nSite, 1);
intercept = NaN(nSite, 1);
used = false(nSite, numel(regressionYears));

% For each site, only use entries that are not NaN
for s = 1:nSite
    use = ~isnan(T(s,:)) & ~isnan(Y(s,:));
    nTime = sum(use);
    X = [ones(nTime, 1), T(s,use)'];
    
    % Do the regression
    b = X \ Y(s,use)';
    intercept(s) = b(1);
    slope(s) = b(2);
    used(s,:) = use;
end

% Save
meta = pages.metadata;
save('pages-regression', 'slope', 'intercept', 'meta', 'regressionYears', 'reanalysis', '-v7.3');

end