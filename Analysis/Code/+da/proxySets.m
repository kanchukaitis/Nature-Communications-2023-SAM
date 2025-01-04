function[sites, whichSet] = proxySets(Y)
%% Returns the unique sets of proxies used in the assimilation
%
% [sites, whichSet] = da.proxySets(Y)
%
% ----- Inputs -----
%
% Y: A matrix of proxy observations (nSite x nTime)
%
% ----- Outputs -----
%
% sites: A logical matrix indicating unique sets of proxy sites. Each
%    column is a set of proxies
%
% whichSet: Indicates which set of proxies (column of sites) is used in
%    each time step. A numeric vector

obs = ~isnan(Y)';
[sites, ~, whichSet] = unique(obs, 'rows', 'stable');
sites = sites';

end