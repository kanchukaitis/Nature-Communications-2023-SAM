function[isSignificant] = significance(ts, window, CI, tsBackground)
%% trend.significance  Tests whether trend values are significant
% -----------
%   isSignificant = trend.significance(ts, window, CI, tsBackground)
%   Computes a moving trend of a specific window length from a time series.
%   Compares the moving trend to a background distribution and tests values
%   for significance.
% ----------
%   Inputs:
%       ts (numeric vector): The time series used to compute trend values
%       window (odd positive integer): The window length of the trend
%       CI (numeric scalar): The confidence interval to use when testing significance
%       tsBackground (numeric vector): The time series used to compute the
%           background distribution of trends
%
%   Outputs:
%       isSignificant (logical vector): Whether each value in the moving
%           trend is significantly different from the background.

% Error check inputs
assert(isvector(ts));
assert(mod(window,2)==1);
assert(isscalar(CI) && CI>=0 && CI<=1);

% Get the distribution of trends
trends = trend.moving(tsBackground, window);
trends(isnan(trends)) = [];
trends = sort(trends);

% Get the confidence interval indices
nTrends = numel(trends);
cilow = (1-CI)/2;
cihigh = 1-cilow;
lowIndex = floor(nTrends*cilow);
highIndex = ceil(nTrends*cihigh);

% Get the confidence interval bounds
bounds = [-Inf Inf];
if lowIndex>0
    bounds(1) = trends(lowIndex);
end
if highIndex<=nTrends
    bounds(2) = trends(highIndex);
end

% Test significance
isSignificant = ts<=bounds(1) | ts>=bounds(2);

end