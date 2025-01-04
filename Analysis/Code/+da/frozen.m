function[] = frozen(priors, priorID, priorYears,...
                            networks, maxLatitude, anomalyYears,...
                            reanalysis, daYears, saveID)
%% Performs frozen network assimilations for a set of reconstruction settings
%
% da.frozen(priors, priorID, priorYears, networks, maxLatitude, ...
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
% Creates a .mat file named: "frozen-{saveID}"

% Load the inputs for the reconstruction
[Y, R, X, Ye] = da.setup(priors, priorID, priorYears, networks, ...
                         maxLatitude, anomalyYears, reanalysis, daYears);
                     
% Get the unique sets of proxy networks and associated time steps
[sites, whichSet] = da.proxySets(Y);

% Preallocate the frozen reconstructions
nSets = size(sites, 2);
nTime = numel(daYears);
ts = NaN(nTime, nSets);

% Do an assimilation for each proxy set
for s = 1:nSets
    use = sites(:,s);
    sY = Y(use,:);
    sR = R(use,use);
    sYe = Ye(use,:);
    out = da.kalman(sY, sR, X, sYe, 1);
    
    % Record the reconstruction for the frozen network in all years that
    % use the complete proxy network
    use = ~any(isnan(sY),1);
    ts(use,s) = out.Amean(use);
end

% Save
file = sprintf('frozen-%s', saveID);
save(file, 'ts', 'sites', 'whichSet',...
    'priors','priorID','priorYears','networks','maxLatitude',...
    'anomalyYears','reanalysis','daYears');

end