function[sam, sigma2, devPercs] = assimilation(id, years, percs)
%% Loads a raw assimilation in the requested years
%
% [sam, sigma2] = load.assimilation(id, years)
%
% [sam, sigma2, devPercs] = load.assimilation(id, years, percs)
%
% ----- Inputs -----
%
% id: The ID of an assimilation
%
% years: The years in which to load the raw assimilation
%
% percs: A set of percentiles
%
% ----- Outputs -----
%
% sam: The raw sam index from the assimilation
%
% sigma2: The posterior variance from the assimilation
%
% devPercs: The percentiles of the deviations

% Default
if ~exist('percs','var') || isempty(percs)
    percs = [];
end
nPercs = numel(percs);

% Load the reconstruction
recon = load(sprintf('%s.mat',id));

% Preallocate
nTime = numel(years);
sam = NaN(nTime, 1);
sigma2 = NaN(nTime, 1);
devPercs = NaN(nTime, nPercs);

% Load the temporal intersect
[~, useX, useY] = intersect(recon.daYears, years);
sam(useY) = recon.Amean(useX);
if nargout>1
    sigma2(useY) = recon.Avar(useX);
end

% Get percentiles
if nargout>2
    percs = prctile( recon.Adev(:,:,useX), percs, 2 );
    devPercs(useY,:) = squeeze(percs)';
end

end