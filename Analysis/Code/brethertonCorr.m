function[rho, pval] = brethertonCorr(ts1, ts2)
%% brethertonCorrs  Returns correlation and AR1 adjusted p-values
% ----------
%   [rho, pval] = brethertonCorr(ts1, ts2)
%   Returns the correlation between two time series. Also returns AR1
%   adjusted p-values, which account for the reduced sample size of
%   autocorrelated time series. Follows the method outlined by Bretherton
%   et al., 1999 for adjusting p-values.
% ----------
%   Inputs:
%       ts1 (numeric vector [nTime]): The first time series
%       ts2 (numeric vector [nTime]): The second time series. Must be the
%           same length as the first
%
%   Outputs:
%       rho (numeric scalar): The correlation between the two time series
%       pval (numeric scalar): The AR1-adjusted p-values

% Require vectors of same length
assert(isvector(ts1), 'ts1 is not a vector');
assert(isvector(ts2), 'ts2 is not a vector');
assert(length(ts1)==length(ts2), 'ts1 and ts2 must have the same length');

% Use column vectors
ts1 = ts1(:);
ts2 = ts2(:);

% Get correlation
rho = corr(ts1, ts2);

% Compute effective sample size accounting for AR1
r1 = corr(ts1(1:end-1), ts1(2:end));
r2 = corr(ts2(1:end-1), ts2(2:end));
N = length(ts1);
Ne = N * (1 - r1*r2) / (1 + r1*r2);

% Compute p-value using effective sample size
tstat = rho * sqrt(Ne-2) / sqrt(1-rho^2);
pval = 2 * tcdf(tstat, Ne-2, 'upper');

end