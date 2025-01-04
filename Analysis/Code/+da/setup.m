function[Y, R, X, Ye, meta] = setup(priors, priorID, priorYears, networks, ...
                                maxLatitude, anomalyYears, reanalysis, daYears)
%% Loads the Kalman Filter inputs for an assimilation
%
% [Y, R, X, Ye, meta] = da.setup(priors, priorID, priorYears, networks, maxLatitude, ...
%                           anomalyYears, reanalysis, daYears)
%
% ----- Inputs -----
%
% priors: A list of models to use in the MME prior
%
% priorID: The ID of the type of prior to use
%
% priorYears: The years to include in the prior
%
% networks: A list of the proxy networks to include in the assimilation
%
% maxLatitude: The northern latitude boundary to use for the proxy networks
%
% anomalyYears: The years to use to calculate proxy anomalies
%
% reanalysis: The reanalysis used to compute error covariances
%
% daYears: The years over which to perform the assimilation
%
% ----- Outputs -----
%
% Y: The proxy observations
%
% R: Proxy error-covariances
%
% X: The model prior
%
% Ye: Model estimates of proxy values
%
% meta: Metadata structures for the proxy network sites used in the
%    assimilation

% Use strings internally
priors = string(priors);
reanalysis = string(reanalysis);
networks = string(networks);

% Determine the spatial grid to use for the reconstruction
gridID = spatialGrid.DA([priors, reanalysis]).id;

% Load the observations in assimilation and anomaly years
obsYears = union(daYears, anomalyYears);
[Y, meta] = load.observations(networks, obsYears, gridID);
R = load.uncertainties(networks, reanalysis, gridID);

% Screen by latitude
[latScreen, meta] = screen.latitude(maxLatitude, meta);
Y = Y(latScreen,:);
R = R(latScreen, latScreen);

% Take observation anomalies and restrict to assimilation years
anom = ismember(obsYears, anomalyYears);
Y = Y - mean(Y(:,anom), 2, 'omitnan');
use = ismember(obsYears, daYears);
Y = Y(:,use);

% Preallocate prior and estimates
nPrior = numel(priors);
Ye = cell(1, nPrior);
X = cell(1, nPrior);

% Get the total set of years to load for estimates and prior
modelYears = union(priorYears, anomalyYears);
anom = ismember(modelYears, anomalyYears);

% Get estimate anomalies for each model
for p = 1:nPrior
    Ye{p} = load.estimates(priors(p), networks, modelYears, gridID);
    Ye{p} = Ye{p}(latScreen,:);
    Ye{p} = Ye{p} - mean( Ye{p}(:,anom), 2, 'omitnan' );
    
    % Load the prior and take anomalies
    X{p} = load.prior(priors(p), priorID, modelYears);
    X{p} = X{p} - mean(X{p}(:,anom), 2, 'omitnan');
    
    % Restrict to prior years and remove years with NaN elements
    use = ismember(modelYears, priorYears) & ~any(isnan(Ye{p}),1) & ~any(isnan(X{p}),1);
    Ye{p} = Ye{p}(:,use);
    X{p} = X{p}(:,use);
end

% Concatenate cells into prior
X = cat(2, X{:});
Ye = cat(2, Ye{:});

% Remove any sites that have no observations
[keep, meta] = screen.noObs(Y, meta);
Y = Y(keep,:);
Ye = Ye(keep,:);
R = R(keep, keep);

end