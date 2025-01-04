function[years] = prior
%% parameters.years.prior  Return the years that should be included in the climate model priors
% ----------
%   years = parameters.years.prior
%   Returns the years of climate model output that should be included in
%   the climate model priors. These years are the members of the various
%   climate model ensembles.
% ----------
%   Outputs:
%       years (numeric vector): The years included in the climate model priors

years = 851:2000;

end