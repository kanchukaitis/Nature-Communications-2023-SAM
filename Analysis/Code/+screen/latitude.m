function[keep, meta] = latitude(northernEdge, meta)
%% Returns a latitude screen for a proxy matrix
%
% [screen, meta] = screen.latitude(northernBound, meta)
%
% ----- Inputs -----
%
% northernBound: The northernmost latitude to be included in the proxy matrix
%
% meta: A cell vector of metadata for the proxy matrix or a single metadata
%    structure
%
% ----- Outputs -----
%
% keep: A logical vector indicating which sites to keep
%
% meta: The updated metadata

% Ensure metadata is cell, note starting state
wasCell = true;
if ~iscell(meta)
    meta = {meta};
    wasCell = false;
end

% Get the latitude screening
nMeta = numel(meta);
keep = cell(nMeta, 1);
for m = 1:nMeta
    keep{m} = meta{m}.coord(:,1) <= northernEdge;
end
keep = cell2mat(keep);

% Apply the screening to the metadata
meta = screen.metadata(keep, meta);
if ~wasCell
    meta = meta{1};
end

end