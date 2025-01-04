function[w] = weights(id, years)
%% Returns standard deviation scaling weights for a reconstruction in the requested years
%
% w = da.weights(id, years)
%
% ----- Inputs -----
%
% id: The ID of a reconstruction
%
% years: The years in which weights are requested
%
% ----- Outputs -----
%
% w: The weights in the requested years

% Get the relative variance of each time series
frozen = load(sprintf('frozen-%s.mat', id));
ts = frozen.ts;
whichSet = frozen.whichSet;
daYears = frozen.daYears;

% Preallocate weights over the DA years
nTime = numel(daYears);
factor = NaN(nTime, 1);

% Get the relative standard deviation of each proxy set
for s = 1:size(ts,2)
    obs = ~isnan(ts(:,s)); 
    factor(whichSet==s) = std(ts(obs,s)) / std(ts(obs,1));
end

% Normalize by the maximum standard deviation
factor = max(factor) ./ factor;

% Preallocate the returned weights
nTime = numel(years);
w = NaN(nTime, 1);

% Get the temporal intersect
[~, useX, useY] = intersect(daYears, years);
w(useY) = factor(useX);

end