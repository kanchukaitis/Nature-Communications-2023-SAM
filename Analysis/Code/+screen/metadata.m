function[meta] = metadata(keep, meta)
%% Applies a proxy screening to associated metadata
%
% meta = screen.metadata(keep, meta)
%
% ----- Inputs -----
%
% keep: A proxy screening. A logical vector indicating which proxies to keep
%
% meta: Metadata for the proxy array
%
% ----- Outputs -----
%
% meta: The screened metadata

% Get the portion of the screen for each metadata
start = 0;
for m = 1:numel(meta)
    nSite = size(meta{m}.coord, 1);
    if nSite==0
        continue
    end
    indices = start + (1:nSite);
    screen = keep(indices);
    
    % Update the metadata fields
    meta{m}.coord(~screen,:) = [];
    if isfield(meta{m}.attributes, "id")
        fields = fieldnames(meta{m}.attributes);
        for f = 1:numel(fields)
            meta{m}.attributes.(fields{f})(~screen) = [];
        end
    end
    
    % Adjust the indices for the next proxy set
    start = indices(end);
end

end
    