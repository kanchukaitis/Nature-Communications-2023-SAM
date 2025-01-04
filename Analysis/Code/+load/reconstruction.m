function[sam, sigma, devPercs] = reconstruction(id, years, percs)
%% Loads a standard deviation-adjusted reconstruction in the requested years
%
% [sam, sigma] = load.reconstruction(id, years)
% Load the reconstruction and uncertianty in requested years
%
% [sam, sigma, samPercs] = load.reconstruction(id, years, percs)
% Also return recontruction deviation percentiles
%
% ----- Inputs -----
%
% id: The ID of an assimilation
%
% years: The years in which to load the reconstruction
%
% percs: A set of percentiles to return
%
% ----- Outputs -----
%
% sam: The standard deviation-adjusted SAM reconstruction
%
% sigma: The posterior standard deviation of the adjusted reconstruction
%
% devPercs: The percentiles of the adjusted reconstruction deviations

% Default percentiles
if ~exist('percs','var') || isempty(percs)
    percs = [];
end

% Load the raw assimilation
if nargout==1
    raw = load.assimilation(id, years);
elseif nargout==2
    [raw, sigma2] = load.assimilation(id, years);
else
    [raw, sigma2, devPercs] = load.assimilation(id, years, percs);
end

% Adjust temporal variance
w = da.weights(id, years);
sam = w .* raw;
if nargout>1
    sigma = w .* sqrt(sigma2);
end
if nargout>2
    devPercs = w .* devPercs;
end

end