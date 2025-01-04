function[adjustMean, adjustStd] = detrendedScalingFactors(T, S)
%% Gets the scaling factors needed to match the mean and standard deviation
% of a detrended time series to a target
%
% Scaling factors for:    (S - adjustMean) / adjustStd
% as per a zscore normalization
%
% Inputs:
%   T (numeric vector): The target time series
%   S (numeric vector): The time series to be scaled
%
% Outputs:
%   adjustMean (numeric scalar): The scaling factor for the mean
%   adjustStd (numeric scalar): The scaling factor for the standard deviation

% Error check
assert(isvector(T));
assert(isvector(S));
assert(length(T) == length(S));

% Use column vectors
if isrow(T)
    T = T';
end
if isrow(S)
    S = S';
end

% Remove the linear trend from both series
x = (1:length(T))';
bT = polyfit(x, T, 1);
bS = polyfit(x, S, 1);

T = T - bT(1)*x;
S = S - bS(1)*x;

% Get the scaling factors
Tstd = std(T);
Sstd = std(S);

adjustStd = Sstd / Tstd;
adjustMean = mean(S) - mean(T) * adjustStd;

end