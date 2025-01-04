function[tslow] = lowpass(ts, N, keepEnds)
%% Applies a low-pass butterworth filter to a time series
%
% ts = da.lowpass(ts, N)
%
% ts = da.lowpass(ts, N, keepEnds)
% Specify whether to keep endpoints or convert to NaN. Default is convert
% to NaN.
%
% ----- Inputs -----
%
% ts: A time series or matrix of time series. If a matrix, each series
%    should be a column
%
% N: The number of years used for the lowpass filter
%
% keepEnds: Scalar logical indicating whether to discard time series
%    endpoints
%
% ----- Outputs -----
%
% tslow: The lowpass filtered time series

% Default
if ~exist('keepEnds','var') || isempty(keepEnds)
    keepEnds = false;
end

% Row vector
if isrow(ts)
    ts = ts';
end

% Get the normalized lowpass frequency
Wn = 2 / N;
[b,a] = butter(5, Wn);

% Filter
tslow = filtfilt(b, a, ts);

% Remove endpoints
if ~keepEnds
    step = floor(N/2);
    tslow([1:step, end-step:end]) = NaN;
end

end