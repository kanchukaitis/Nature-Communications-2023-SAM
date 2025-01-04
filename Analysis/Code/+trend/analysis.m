function[] = analysis(id, trendYears, CI, ciYears, saveID)
% trend.analysis  Computes moving trends of different window lengths and tests trends for significance
% ----------
%   trend.analysis(id, trendYears, CI, ciYears, saveID)
% ----------
%   Inputs:
%       id (string scalar): The ID of the reconstruction
%       trendYears (numeric vector): The years to include in the analysis
%       CI (numeric scalar): Confidence interval to use for testing significance
%       ciYears (numeric vector): Years to use for determining the
%           background distribution of trends
%       saveID (string scalar): An ID to use for the output file
%
%   Outputs:
%       Creates a file whose name matches the saveID input.

%%% Parameters
reconWindows = 31:2:101;    % The trend windows applied to the reconstruction
marshallWindows = 31:2:63;  % The trend windows applied to the Marshall index
%%%

% Get the scaling factors
marshall = gridfile('marshall-djf.grid');
instrumental = marshall.meta.time <= 2000;
[marsh, mmeta] = marshall.load("time", {instrumental});
sam = load.reconstruction(id, mmeta.time);
[adjustMean, adjustStd] = da.detrendedScalingFactors(marsh, sam);

% Load the full marshall index
[marshall, mmeta] = marshall.load;
marshallYears = mmeta.time;

% Load the reconstruction over the trend years and the years used to build
% the confidence interval. Scale to the marshall index
samInstrumental = load.reconstruction(id, trendYears);
samBackground = load.reconstruction(id, ciYears);

samInstrumental = (samInstrumental - adjustMean) / adjustStd;
samBackground = (samBackground - adjustMean) / adjustStd;

% Preallocate trends and significance
nRW = numel(reconWindows);
rtrends = NaN(nRW, numel(trendYears));
rsig = false(nRW, numel(trendYears));

nMW = numel(marshallWindows);
mtrends = NaN(nMW, numel(marshallYears));
msig = false(nMW, numel(marshallYears));

% Get reconstruction trends and significance
for w = 1:nRW
    window = reconWindows(w);
    rtrends(w,:) = trend.moving(samInstrumental, window);
    rsig(w,:) = trend.significance(rtrends(w,:), window, CI, samBackground);
end

% Get Marshall trends and significance
for w = 1:nMW
    window = marshallWindows(w);
    mtrends(w,:) = trend.moving(marshall, window);
    msig(w,:) = trend.significance(mtrends(w,:), window, CI, samBackground);
end

% Save
save(saveID, 'rtrends','rsig','mtrends','msig', 'reconWindows','marshallWindows','trendYears', 'marshallYears', 'CI','ciYears');

end