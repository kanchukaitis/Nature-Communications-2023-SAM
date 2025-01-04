function[trends] = moving(ts, k)
%% trend.moving  Calculate moving trend
% ----------
%   trends = movtrend(ts, k)
%   Slides a window of length k over a time series and calculates the trend
%   over each interval
% ----------
%   Inputs:
%       ts (vector [nTime]): A time series vector
%       k (scalar, positive odd integer): Window length
%
%   Outputs:
%       trends (vector [nTime]): The trend for the window centered on each
%           year. NaN where the full window does not fit.

% Error check inputs
assert(mod(k,2)==1,'k must be odd');
assert(isvector(ts));

% Preallocate
nYears = numel(ts);
trends = NaN(nYears, 1);

% Get the half step and x coordinates
x = 1:k;
halfStep = floor(k/2);
firstMidpoint = halfStep + 1;
lastMidpoint = nYears - halfStep;

% Get the trend over the moving window
for y = firstMidpoint:lastMidpoint
    interval = ts(y-halfStep:y+halfStep);
    p = polyfit(x, interval, 1);
    trends(y) = p(1);
end

end