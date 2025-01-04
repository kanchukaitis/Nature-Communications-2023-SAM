function[] = temperatures(name)
%% Calculates seasonal temperatures for the PAGES sites from a model or reanalysis.
% 
%
% estimate.pages.temperatures(name)
%
% ----- Inputs -----
%
% name: The name of the model or reanalysis to use to eestimate seasonal
%     temperatures
%
% ----- Outputs -----
%
% Creates an .ens file named: "{name}-pages-temperatures"

% Load PAGES and model metadata
file = sprintf('tref-%s.grid', name);
meta = gridfile(file).metadata;
pages = gridfile('pages.grid').metadata;

% State vector indices
january = month(meta.time)==1;
closest = dash.closestLatLon(pages.coord, meta.lat, meta.lon);

% Remove missing years from HadCM3
if strcmpi(name, 'hadcm3')
    missing = ismember(year(meta.time), 1951:1959);
    january = january & ~missing;
end

% Get the ID for each proxy
pages = pages.attributes;
nPages = numel(pages.id);

% Create a progress bar. Set it to delete when the function exits
message = sprintf('Estimating PAGES2k temperatures for %s: 0/%.f', name, nPages);
h = waitbar(0, message);
deleteBar = onCleanup( @()delete(h) );

% Build the state vector for each proxy
sv = stateVector('pages', false);
sv = sv.add(pages.id, file);
for s = 1:nPages
    var = pages.id(s);
    lat = meta.lat==closest(s,1);
    lon = meta.lon==closest(s,2);
    sv = sv.design(var, ["lon","lat","time","run"], [true true false false], {lon, lat, january, 1});
    sv = sv.mean(var, 'time', pages.season{s});

    % Update progress bar
    message = sprintf('Estimating PAGES2k temperatures for %s: %.f/%.f', name, s, nPages);
    waitbar(s/nPages, h, message);
end
sv = sv.allowOverlap(pages.id, true);

% Build the ensemble
file = sprintf('%s-pages-temperatures.ens', name);
[~, info] = sv.info(1);
N = info.possibleMembers-1;
sv.build(N, false, file, true, false);

end