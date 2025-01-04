function[] = PAGES
%% Cleans and organizes the PAGES2k dataset for the assimilation.
%
% organize.PAGES()
%
% 1. Collects proxy metadata in a structure array
% 2. Removes sites not used in the PAGES2k temperature reconstruction
% 2. Removes low-resolution records
% 3. Averages sub-annual records to annual
% 4. Collects time series into a matrix
% 5. Saves the time-series matrix and proxy metadata

%% Collect PAGES2k data and site metadata

% Load the raw data
pages = load('PAGES2k_v2.0.0.mat');
pages = pages.TS;

% Collect data and metadata for each record
lat = {pages.geo_latitude}';
lon = {pages.geo_longitude}';
id = {pages.paleoData_pages2kID}';
years = {pages.year}';
data = {pages.paleoData_values}';
season = {pages.climateInterpretation_seasonality}';
name = {pages.geo_siteName}';
var = {pages.climateInterpretation_variable}';
type = {pages.archiveType}';

% Correct a typo in the seasonality for site Arc_080
typo = strcmp(id, 'Arc_080');
season{typo} = '7 8 9';

% Organize into structure
s = struct('lat',lat,'lon',lon,'id',id, 'years', years, 'data', data, ...
    'season', season, 'name', name, 'var', var, 'type', type);

% Remove sites not used in the PAGES2k temperature reconstruction
use = {pages.paleoData_useInGlobalTemperatureAnalysis}';
use = strcmpi(use, "TRUE");
s = s(use);
name = string({s.name})';

%% Remove low-resolution records

% Restrict the GBR corals to the high-resolution modern record
gbr = find(strcmpi(name, "GBR"));
for site = 1:numel(gbr)
    k = gbr(site);
    remove = s(k).years<1940;
    s(k).years(remove) = [];
    s(k).data(remove) = [];
end

% Preallocate high-resolution indicator
nRecords = numel(s);
highRes = false(nRecords, 1);
subannual = false(nRecords, 1);

% Get the time step size for each record, remove duplicate time stamps
for k = 1:nRecords
    spacing = abs(diff( s(k).years ));
    spacing(spacing==0) = [];
    
    % Note whether a record has subannual spacing
    if any(spacing<1)
        subannual(k) = true;
    end
        
    % Some sites have a few "low-resolution" time steps that result from a
    % break in the record, or from crossing year 0. Keep anything that has
    % less than 10% low-resolution time steps
    percentLow = sum(spacing>1) / numel(spacing);
    if percentLow < 0.1
        highRes(k) = true;
    end
end

% Restrict to high-resolution sites
s = s(highRes);
subannual = subannual(highRes);
nRecords = numel(s);

%% Averages subannual records to annual

% Get the unique years in each subannual record, average years so they are
% centered about the summer months
subIndex = find(subannual);
for site = 1:numel(subIndex)
    k = subIndex(site);
    
    if s(k).lat >= 0
        allYears = floor( s(k).years );
    else
        allYears = round( s(k).years );
    end
    
    uniqYear = unique(allYears);
    uniqYear(isnan(uniqYear)) = [];
    
    % Take annual averages
    nYears = numel(uniqYear);
    annualData = NaN(nYears, 1);
    for y = 1:nYears
        inyear = allYears == uniqYear(y);
        annualData(y) = mean( s(k).data(inyear), 'omitnan' );
    end
    
    % Overwrite subannual data
    s(k).data = annualData;
    s(k).years = uniqYear;
end

%% Get seasonality metadata in a common numeric format

% Set seasonal month indices for different hemispheres
annualNH = 1:12;
annualSH = [-7:-1:-12, 1:6];
jja = 6:8;
djf = [-12, 1, 2];

% Get the seasonality metadata and hemisphere for each record
for k = 1:nRecords
    season = s(k).season;
    nh = s(k).lat >= 0;
    
    % If subannual, annual, or unspecified, use annual month indices
    if isempty(season) || ismember(season, ["subannual","N/A","annual","N/A (subannually resolved)"]);
        if nh
            months = annualNH;
        else
            months = annualSH;
        end
        
    % Summer
    elseif any(strcmpi(season, ["summer","early summer"]))
        if nh
            months = jja;
        else
            months = djf;
        end
        
    % Winter
    elseif strcmpi(season, 'winter')
        if nh
            months = djf;
        else
            months = jja;
        end
        
    % If a string of indices, convert to numeric
    else
        months = str2num(season); %#ok<ST2NM>
    end
    
    % When spanning multiple calendar years, set January as 1
    if any(months>12)
        year1 = months<=12;
        year2 = months>12;
        months(year1) = -months(year1);
        months(year2) = months(year2) - 12;
    end
    
    % Convert to January-based sequence indices
    months(months>0) = months(months>0)-1;
    months(months<0) = -(mod(months(months<0),12)+1);
    assert(~any(abs(months)>=12))
    
    % Set seasonality
    s(k).season = months;
end

%% Final data matrix and metadata

% Get the first and last year across the dataset
minYear = Inf;
maxYear = -Inf;
for k = 1:nRecords
    miny = min(s(k).years);
    maxy = max(s(k).years);
    
    if minYear>miny
        minYear = miny;
    end
    if maxYear<maxy
        maxYear = maxy;
    end
end

% Create the data matrix and time metadata
years = minYear:maxYear;
X = NaN(nRecords, numel(years));
for k = 1:nRecords
    [~, loc] = ismember( floor(s(k).years), years);
    try
        X(k, loc) = s(k).data;
    catch
        'debug';
    end
end

% Collect the final metadata fields
lat = [s.lat]';
lon = [s.lon]';
id = string({s.id})';
season = {s.season}';
name = string({s.name})';
var = string({s.var})';
type = string({s.type})';

%% Catalogue in a .grid file
    
% Save
save('pages', 'X', 'years', 'lat', 'lon', 'id', 'season', 'name', 'var', 'type', '-v7.3');

% Jitter the longitudes to avoid duplicate coordinates
rng('default');
lon = lon + 10^-10 * rand(size(lon));

% Create new gridfile
meta = gridfile.defineMetadata('coord', [lat, lon], 'time', years');
atts = struct('id', id, 'name', name, 'var', var, 'type', type);
atts.season = season;
grid = gridfile.new('pages.grid', meta, atts, true);
grid.add('mat', 'pages.mat', 'X', ["coord","time"], meta);

end