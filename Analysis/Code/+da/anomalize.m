function[ts, Xstd, Xmean] = anomalize(ts, years, anomalyYears)
%% Normalizes (mean and std) a time series against a set of years
%
% ts = da.anomalize(ts, years, anomalyYears)
% Normalize (z-score) a time series
%
% [ts, Xstd, Xmean] = da.anomalize(ts, years, anomalyYears)
% Also return the normalization constants
%
% ----- Inputs -----
%
% ts: A time series vector
%
% years: The years of the time series
%
% anomalyYears: The years in which to take the anomaly
%
% ----- Outputs -----
%
% ts: The normalized time series
%
% Xstd: The standard deviation normalization constant
%
% Xmean: The mean normalization constant

% Error check
assert(isvector(ts), 'ts must be a vector');
assert(isvector(years), 'years must be a vector');
assert(numel(years)==numel(ts), 'years must have the same number of elements as ts');
assert(all(ismember(anomalyYears, years)), 'Not all anomaly years are in the time series');

% Use column vectors
ts = ts(:);
years = years(:);

% Take the anomaly
anom = ismember(years, anomalyYears);
Xmean = mean(ts(anom));
Xstd = std(ts(anom));

ts = (ts - Xmean) ./ Xstd;

end