function[] = OConnor2021
%% organize.OConnor2021  Computes SAM indices from O'Connor et al., 2021 and organizes in gridfile
% ----------
%   organize.OConnor2021
%   Computes SAM indices from the 4 reconstructions of O'Connor et al.,
%   2021. SAM indices are calculated from reconstructed sea level pressure
%   using the Gong and Wang (1999) definition. The SAM indices are saved in
%   a .mat file and then catalogued in a gridfile
% ----------
%   Outputs:
%       Creates a .mat and .grid file

% Get the file names
priors = ["cesm_lm","hadcm3_lm","lens","pace"]';
files = strcat(priors, "_recon_psl_1900_2005_ens_mean.nc");
nRuns = numel(files);

% Preallocate SAM
years = 1900:2005;
sam = NaN(numel(years), nRuns);

% Locate zonal bands
lat = ncread(files(1), 'lat');
lat40 = lat==40;
lat65 = lat==65;

% Compute SAM for each reconstruction.
for r = 1:nRuns
    psl = ncread(files(r), 'psl');
    p40 = mean(psl(:,lat40,:,:), 1:3);
    p65 = mean(psl(:,lat65,:,:), 1:3);

    p40 = squeeze(p40);
    p65 = squeeze(p65);

    p40 = zscore(p40);
    p65 = zscore(p65);

    % Normalized zonal mean anomalies
    sam(:,r) = p40 - p65;
end

% Save SAM indices as matfile
save('oconnor-2021', 'sam', 'years', 'priors', '-v7.3');

% Build gridfile
meta = gridfile.defineMetadata("time",years',"run",priors);
grid = gridfile.new('oconnor-2021', meta);
grid.add("mat","oconnor-2021.mat", "sam", ["time","run"], meta);

end