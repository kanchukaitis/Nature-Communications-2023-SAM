function[Y, meta, netID] = observations(networks, years, gridID, cellMeta)
%% Load proxy observations and associated metadata
%
% [Y, meta, netID] = load.observations(networks, years)
%
% [Y, meta, netID] = load.observations(networks, years, gridID)
% Specify spatial grid if drought atlases are included in the networks
%
% [Y, meta, netID] = load.observations(networks, years, gridID, cellMeta)
% Specify whether metadata should be a cell for single networks
%
% ----- Inputs -----
%
% networks: A list of proxy networks
%
% years: The years in which to load proxy observations
%
% gridID: The ID of a spatial grid
%
% cellMeta: A logical that indicates if metadata should be a cell for
%    single networks. Default is false
%
% ----- Outputs -----
%
% Y: The proxy observation matrix
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
networks = string(networks);

% Preallocate
nNetwork = numel(networks);
Y = cell(nNetwork, 1);
netID = cell(nNetwork, 1);
meta = cell(nNetwork, 1);

% Get file ending for each network
for n = 1:nNetwork
    tail = load.networkTail(networks(n), gridID);
    
    % Load the observations in the specified years
    file = sprintf('%s%s.grid', networks(n), tail);
    [Y{n}, meta{n}] = load.proxyArray(file, years);
    
    % Get the network ID
    nSite = size(Y{n}, 1);
    netID{n} = n * ones(nSite, 1);
end

% Join cells into matrices
Y = cell2mat(Y);
netID = cell2mat(netID);
if nNetwork==1 && ~cellMeta
    meta = meta{1};
end

end