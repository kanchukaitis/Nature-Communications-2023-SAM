function[id] = siteNames(networks, meta)
%% Returns PAGES ID / Atlas identifiers for the observations sites in a proxy network
%
% id = da.siteNames(networks, meta)
%
% ----- Inputs -----
%
% networks: A string list of proxy networks
%
% meta: The screened metadata for the proxy network
%
% ----- Outputs -----
%
% id: ID strings for each proxy site

% Preallocate
nNetwork = numel(networks);
id = cell(nNetwork, 1);

% Get the ids for each network
for n = 1:nNetwork
    if strcmpi(networks(n), 'pages')
        id{n} = meta{n}.attributes.name;
    else
        nSite = size(meta{n}.coord, 1);
        id{n} = repmat(networks(n), nSite, 1);
    end
end

% Convert cells to matrix
id = cat(1, id{:});

end
    