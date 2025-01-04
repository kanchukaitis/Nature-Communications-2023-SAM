function[R, meta, netID] = uncertainties(networks, reanalysis, gridID, cellMeta)
%% Loads error covariance (R uncertainties) and associated metadata
%
% [R, meta, netID] = load.uncertainties(networks, years, gridID)
%
% [...] = load.uncertainties(networks, years, gridID, cellMeta)
% Indicate whether metadata should be a cell, even for single networks
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
% R: The error-covariance matrix
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
R = cell(nNetwork, 1);
netID = cell(nNetwork, 1);
meta = cell(nNetwork, 1);

% Get file endings for each network
for n = 1:nNetwork
    tail = load.networkTail(networks(n), gridID);
    
    % Load the covariance
    file = sprintf('%s-R-%s%s.mat', networks(n), reanalysis, tail);
    errorCov = load(file);
    R{n} = errorCov.R;
    meta{n} = errorCov.meta;
    
    % Network ID
    nSite = size(R{n},1);
    netID{n} = n * ones(nSite, 1);
end

% Convert cells to matrices
R = blkdiag(R{:});
netID = cell2mat(netID);
if nNetwork==1 && ~cellMeta
    meta = meta{1};
end

end