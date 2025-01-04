function[sigma] = detrendedStd(ts)
%% Computes standard deviation of a time series after first removing trend.
% Essentially, the standard deviation from internal variability.
%
% sigma = da.detrendedStd(ts)
%
% ----- Inputs ---
%
% ts: A time series. A vector
%
% ----- Outputs -----
%
% sigma: The standard deviation of the detrended time series

% Get x values for the trend fit, ensure column vectors for everything
x = (1:numel(ts))';
ts = ts(:);

% Calculate a trend line through the time series
p = polyfit(x, ts, 1);
trend = p(1)*x + p(2);

% Remove the trend and assess standard deviation
ts = ts - trend;
sigma = std(ts);

end