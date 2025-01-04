function[events] = events(ts, years, eventYears, anomYears, returnYears)
%% Returns the anomalized events for a superposed epoch analysis

% Sizes
nEvent = numel(eventYears);
nYears = numel(returnYears);
nAnom = numel(anomYears);

% Preallocate
anomalies = NaN(nAnom, nEvent);
events = NaN(nYears, nEvent);

% Get the anomaly and time series for each event
for k = 1:nEvent
    y = find(years == eventYears(k));
    anomalies(:,k) = ts(y+anomYears);
    events(:,k) = ts(y+returnYears);
end

% Take anomalies
anomalies = mean(anomalies, 1, 'omitnan');
events = events - anomalies;

end