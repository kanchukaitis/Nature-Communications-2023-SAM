function[indices] = latIndices(lats)
%% Returns the indices of latitudes that are closest to the Gong latitudes (40S, 65S)
% First index is 40S, second is 65S
%
% indices = gong.latIndices(lats)
%
% ----- Inputs -----
%
% lats: A vector of latitudes
%
% ----- Outputs -----
%
% indices: The indices of the latitudes closest to 40S and 65S

dist = abs(-40 - lats);
lat40 = find(dist==min(dist), 1);
dist = abs(-65 - lats);
lat65 = find(dist==min(dist), 1);

indices = [lat40; lat65];

end