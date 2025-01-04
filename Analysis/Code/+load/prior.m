function[X] = prior(model, priorID, years)
%% Loads a prior for assimilation
%
% X = load.prior(model, priorID, years)
%
% ----- Inputs -----
%
% model: The name of a model
%
% priorID: The ID of the type of index used for the prior
%
% years: The years in which to load the years
%
% ----- Outputs -----
%
% X: The loaded priors (nState x nTime)

% Preallocate the array
nTime = numel(years);
X = NaN(1, nTime);

% Load the full prior
file = sprintf('%s-%s.mat', model, priorID);
m = load(file);

% Fill in the temporal intersect
[~, useX, useY] = intersect(m.years, years);
X(:,useY) = m.sam(useX);

end

