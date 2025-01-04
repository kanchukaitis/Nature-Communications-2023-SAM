function[prior] = prior
%% parameters.da.prior  Lists the label of the type of prior to use for DA
% ----------
%   prior = parameters.da.prior
%   Lists the label of the type of prior to use for DA. This should match
%   the second part of the filename for the saved priors. (The part of the
%   filename after the climate model label).
% ----------
%   Outputs:
%       prior (string scalar): The type of prior to use for the assimilation

prior = "gong-pi";

end