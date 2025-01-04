function[] = assimilate(priors, priorID, priorYears,...
                        networks, maxLatitude, anomalyYears,...
                        reanalysis, daYears, returnType, saveID)
%% Runs the assmilation
%
% da.assimilate(priors, priorID, priorYears,
%            networks, maxLatitude, anomalyYears
%            reanalysis, daYears, returnType, saveID)
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
% returnType: Sweitch that indicates which values to output
%   [1]: Posterior mean (Amean)
%   [2]: Posterior mean and variance (Amean and Avar)
%   [3]: Posterior mean and deviations (Amean and Adev)
%
% saveID: An identifying string for the assimilation
%
% ----- Outputs -----
%
% Creates a .mat file named: "{saveID}"

% Load the inputs for the reconstruction
[Y, R, X, Ye] = da.setup(priors, priorID, priorYears, networks, ...
                         maxLatitude, anomalyYears, reanalysis, daYears);

% Run the Kalman Filter
out = da.kalman(Y, R, X, Ye, returnType);

% Initialize outputs
Amean = out.Amean;
Avar = [];
Adev = [];

% Get optional posterior deviations
if returnType==2
    Avar = out.Avar;
elseif returnType==3
    Adev = out.Adev;
end

% Save
save(saveID, 'Amean', 'Avar', 'Adev', ...
    'priors','priorID','priorYears','networks','maxLatitude',...
    'anomalyYears','reanalysis','daYears');

end