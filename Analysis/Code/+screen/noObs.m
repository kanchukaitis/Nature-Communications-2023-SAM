function[keep, meta] = noObs(Y, meta)
%% Removes sites with no observations
%
% [keep, meta] = screen.noObs(Y, meta)
%
% ----- Inputs -----
%
% Y: A proxy matrix
%
% meta: Metadata for the proxy matrix
%
% ----- Outputs -----
%
% keep: The sites to keep
%
% meta: Update metadata

% Ensure metadata is cell, note starting state
wasCell = true;
if ~iscell(meta)
    meta = {meta};
    wasCell = false;
end

% Get the sites with observations
keep = ~all(isnan(Y),2);

% Screen metadata
meta = screen.metadata(keep, meta);
if ~wasCell
    meta = meta{1};
end

end