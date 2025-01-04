function[Ye, meta, netID] = estimates(model, networks, years, gridID, cellMeta)
%% Loads model estimates of proxy values in selected years
%
% [Ye, meta, netID] = load.estimates(model, networks, years, gridID)
%
% [Ye, meta, netID] = load.estimates(model, networks, years, gridID)
% Specify whether metadata should be returned as a cell for single networks
%
% ----- Inputs -----
%
% model: The name of the model that the estimates are derived from
%
% networks: The proxy networks to load
%
% years: The years in which to load data
%
% gridID: The spatial grid on which to load data
%
% cellMeta: A logical that indicates if metadata should be a cell for
%    single networks. Default is false
%
% ------ Outputs -----
%
% Ye: The loaded estimates
%
% meta: A cell vector with the metadata associated with each network
%
% netID: A vector with one element per proxy site. Indicates which proxy
%    network the proxy site belongs to

% Defaults
if ~exist('gridID','var') || isempty(gridID)
    gridID = '';
end
if ~exist('cellMeta','var') || isempty(cellMeta)
    cellMeta = false;
end

% Use strings internally
model = string(model);
networks = string(networks);

% Preallocate
nNetwork = numel(networks);
Ye = cell(nNetwork, 1);
netID = cell(nNetwork, 1);
meta = cell(nNetwork, 1);

% Get filename tail for each network
for n = 1:nNetwork
    tail = load.networkTail(networks(n), gridID);
    
    % Load the estimates in the specified years
    file = sprintf('%s-%s%s.grid', networks(n), model, tail);
    [Ye{n}, meta{n}] = load.proxyArray(file, years);
    
    % Get the network ID
    nSite = size(Ye{n}, 1);
    netID{n} = n * ones(nSite, 1);
end

% Join cells into matrices
Ye = cell2mat(Ye);
netID = cell2mat(netID);
if nNetwork==1 && ~cellMeta
    meta = meta{1};
end

end