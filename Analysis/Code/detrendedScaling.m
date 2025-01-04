function[scaleMean, scaleStd] = detrendedScaling(T, S)
%% Scales the standard deviation of a detrended time series to a target detrended series
%
% scaleDetrended(T, S)
%
% Can use outputs to apply
%
% (S - scaleMean) / scaleStd

assert(iscolumn(T));
assert(iscolumn(S));
assert(numel(S)==numel(T));

% Remove the trend from each series
x = (1:numel(T))';
bT = polyfit(x, T, 1);
bS = polyfit(x, S, 1);

T0 = T - bT(1)*x;
S0 = S - bS(1)*x;

% Get the mean and std of each series
Tmean = mean(T0);
Tstd = std(T0);
Smean = mean(S0);
Sstd = std(S0);

% Get the scaling constants
scaleMean = Smean + (Tmean * Sstd / Tstd);
scaleStd = Sstd / Tstd;

end