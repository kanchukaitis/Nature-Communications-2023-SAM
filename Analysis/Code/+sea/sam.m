function[] = sam(id, years, volcYears, anomYears, returnYears, MC, saveID)
%% Does the volcanic SEA for a SAM reconstruction
%
% sea.sam(id, volcYears, anomYears, returnYears, MC, saveID)
%
% ----- Inputs -----
%
% id: The ID of a SAM reconstruction
%
% years: The reconstruction years to use for the SEA experiments
%
% volcYears: The years of the volcanic events
%
% anomYears: The indices of years (relative to the eruption event) used to
%    compute volcanic anomalies
%
% returnYears: The indices of years (relative to the eruption event) that
%    should be returned as epoch time series
%
% MC: The number of Monte Carlo draws to use
%
% saveID: The id to use for saving
%
% ----- Outputs ----- 
%
% Creates a .mat file named: {sea}-{id}

% Load the reconstruction and do the real SEA
sam = load.reconstruction(id, years);
events = sea.events(sam, years, volcYears, anomYears, returnYears);

% Preallocate noise SEA
[nTime, nEvents] = size(events);
noise = NaN(nTime, MC);

% Get the years that can be selected for the Monte Carlo tests
mcYears = years;
pre = min( [anomYears(:); returnYears(:)] );
if pre<0
    mcYears(1:abs(pre)) = [];
end
post = max(returnYears);
if post>0
    mcYears(end-post+1:end) = [];
end
mcYears(ismember(mcYears, volcYears)) = [];

% Do a Monte Carlo SEA
rng('default');
for k = 1:MC
    kyears = randsample(mcYears, nEvents);
    kevents = sea.events(sam, years, kyears, anomYears, returnYears);
    noise(:,k) = mean(kevents, 2);    
end
noise = sort(noise, 2);

% Save
file = sprintf('sea-%s', saveID);
save(file, 'events', 'noise', 'id', 'years', 'volcYears','anomYears','returnYears');

end