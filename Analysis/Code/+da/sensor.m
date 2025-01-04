function[] = sensor(priors, priorID, priorYears, ...
                    networks, maxLatitude, anomalyYears, ...
                    reanalysis, daYears, saveID)
%% Runs the optimal sensor analysis
%
% da.sensor(priors, priorID, priorYears, networks, maxLatitude,...
%           anomalyYears, reanalysis, daYears, saveID)
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
% saveID: An identifying string for the assimilation
%
% ----- Outputs -----
%
% Creates a .mat file named: "sensor-{saveID}"

% Load the inputs used for assimilation / optimal sensor
[Y, R, X, Ye, meta] = da.setup(priors, priorID, priorYears, networks, ...
                               maxLatitude, anomalyYears, reanalysis, daYears);
R = diag(R);

% Get the unique proxy sets
[sites, whichSet] = da.proxySets(Y);

% Preallocate optimal sensor outputs
nSite = size(Y,1);
nSets = size(sites,2);
percentVar = NaN(1, nSets);
potentialVar = NaN(nSite, nSets);

% Do an optimal sensor for each proxy set
for s = 1:nSets
    use = sites(:,s);
    
    os = optimalSensor;
    os = os.prior(X);
    os = os.estimates( Ye(use,:), R(use) );
    os = os.metric('mean');
    
    N = sum(use);
    out = os.run(N);
    
    % Record the total variance constrained by the proxy network and the
    % potential variance of each proxy
    percentVar(s) = sum(out.percentVar.best);
    potentialVar(use,s) = out.percentVar.potential(:,1);
end

% Save
iVar = out.metricVar.initial;
file = sprintf('sensor-%s.mat', saveID);
save(file, 'percentVar','potentialVar', 'sites','whichSet','meta','networks','iVar', 'priors', 'reanalysis');

end
    
    