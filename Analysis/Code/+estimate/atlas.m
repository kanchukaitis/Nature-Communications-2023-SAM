function[] = atlas(name, atlas, maxMagnitude, gridID)
%% Estimates values for a drought atlas from a PDSI field. 
% Extracts DJF seasonal means and replaces unrealistic PDSI magnitudes with NaN.
%
% estimate.atlas(model, atlas, maxMagnitude, gridID)
%
% ----- Inputs -----
%
% name: The name of a climate model or reanalysis from which the PDSI
%    estimate is derived
%
% atlas: The name of a drought atlas
%
% maxMagnitude: The maximum allowed PDSI magnitude
%
% gridID: The ID of the spatial grid to use
%
% ----- Outputs -----
%
% Creates .mat and .grid files named: "{atlas}-{name}-{gridID}"

% Get PDSI metadata
file = sprintf('%s-pdsi-%s-%s.grid', atlas, name, gridID);
meta = gridfile(file).metadata;

% Build a state vector of DJF seasonal means
january = month(meta.time)==1;

sv = stateVector;
sv = sv.add(atlas, file);
sv = sv.design(atlas, 'time', false, january);
sv = sv.mean(atlas, 'time', -1:1);

[~, info] = sv.info(1);
N = info.possibleMembers;
[Ye, ensMeta] = sv.build(N, false, [], [], false);

% Remove extreme values
extreme = abs(Ye) > maxMagnitude;
Ye(extreme) = NaN;

% Save
meta.time = year(ensMeta.variable(atlas,'time'));
file = sprintf('%s-%s-%s', atlas, name, gridID);
save(file, 'Ye', 'meta', 'extreme', 'maxMagnitude', '-v7.3');

% Gridfile
atts = meta.attributes;
atts.maxMagnitude = maxMagnitude;
atts.season = "DJF";

meta = rmfield(meta, 'attributes');
grid = gridfile.new(file, meta, atts, true);
grid.add('mat', sprintf('%s.mat',file), "Ye", ["coord","time"], meta);

end