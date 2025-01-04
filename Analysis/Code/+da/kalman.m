function[out] = kalman(Y, R, X, Ye, returnType)
%% Builds and runs a Kalman Filter for an assimilation
%
% out = da.kalman(Y, R, X, Ye)
% Run a Kalman Filter given a set of inputs
%
% out = da.kalman(Y, R, X, Ye, returnType)
% Optionally specify whether to return updated posterior deviations or
% variance
%
% ----- Inputs -----
%
% Y: A matrix of proxy observations
%
% R: Proxy error covariance matrix
%
% X: A prior matrix
%
% Ye: Model estimates of proxies
%
% returnType: Integer switch. Indicates the values to output from the Kalman filter.
%   [1] (default): Posterior mean (Amean)
%   [2]: Posterior mean and variance (Amean and Avar)
%   [3]: Posterior mean and deviations (Amean and Adev)
%
% ----- Outputs -----
%
% out: Kalman Filter output

% Build the filter object
kf = kalmanFilter;
kf = kf.observations(Y);
kf = kf.uncertainties(R, [], true);
kf = kf.prior(X);
kf = kf.estimates(Ye);

% Specify output
if returnType==2
    kf = kf.variance(true);
elseif returnType==3
    kf = kf.deviations(true);
end

% Run the filter
out = kf.run;

end