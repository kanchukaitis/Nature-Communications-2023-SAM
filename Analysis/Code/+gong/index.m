function[] = index(name, standardYears, id)
%% Computes the Gong (zonal SLP) SAM index for a model or reanalysis
%
% gong.index(name, standardYears, pi)
% 
% ----- Inputs -----
%
% name: The name of a model or reanalysis
%
% standardYears: The years to use for standardization
%
% id: An string ID for the set of standardization years
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "{name}-gong-{id}"

% Get the SLP gridfile
file = sprintf('slp-%s.grid', name);
meta = gridfile(file).metadata;

% Build a state vector with zonal-mean DJF SLP over the Gong latitudes
zonal = gong.latIndices(meta.lat);
jan = month(meta.time)==1;
djf = -1:1;

sv = stateVector;
sv = sv.add('SLP', file);
sv = sv.design('SLP', ["time","lat"], [false, true], {jan, zonal});
sv = sv.mean('SLP', ["time", "lon"], {djf, []});

[~, info] = sv.info(1);
N = info.possibleMembers;
[X, ensMeta] = sv.build(N, false);

% Standardize
years = year(ensMeta.variable(1, 'time'));
stan = ismember(years, standardYears);

Xmean = mean(X(:,stan), 2, 'omitnan');
Xstd = std(X(:,stan), [], 2, 'omitnan');
X0 = (X - Xmean) ./ Xstd;

% Compute the index
X0 = X0';
sam = X0(:,1) - X0(:,2);

% Save
file = sprintf('%s-gong-%s', name, id);
save(file, 'sam', 'years', 'standardYears', '-v7.3');

end