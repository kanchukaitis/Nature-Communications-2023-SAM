function[] = solarWavelet(id, years, params)

% Load the reconstruction and solar forcing dataset
sam = load.reconstruction(id, years);

solar = schmidt_solar;
solarYears = solar(:,1);
solar = solar(:,7);

% Ensure the analysis years are in the solar dataset
assert(all(ismember(years, solarYears)), 'Some of the analysis years are not in the solar dataset');

% Get the overlapping portions of the dataset
[years, ksol, ksam] = intersect(solarYears, years);
solar = solar(ksol);
sam = sam(ksam);

% Do the wavelet coherence plot
ts1 = [years, solar];
ts2 = [years, sam];
wco(ts1, ts2, params{:});

end