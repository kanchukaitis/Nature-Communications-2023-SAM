function[grids, ids] = spatialGrids
%% parameters.spatialGrids  Return spatialGrid objects for the spatial grids used in the analysis
% ----------
%   [grids, ids] = parameters.spatialGrids
%   Returns spatialGrid objects for the spatial grids used in the analysis.
%   There are currently 2 spatial grids considered - one for the all models
%   case, and one for the high-resolution models case. In each case, the
%   spatial grid used in the assimilation is defined using the lowest
%   resolution latitude-longitude spacing among the reanalysis and the
%   climate models used.
% ----------
%   Outputs:
%       grids (spatialGrid vector [2]): The spatialGrid objects to use for
%           the (1) all models,  and (2) high-resolution models cases.
%       ids (string vector [2]): The IDs associated with the grids.

% Get the reanalysis and sets of climate models
reanalysis = parameters.reanalysis;
allModels = parameters.models.all;
highModels = parameters.models.highres;

% Get the spatial grid used to implement DA for each case
gridAll  = spatialGrid.DA([allModels,  reanalysis]);
gridHigh = spatialGrid.DA([highModels, reanalysis]);
grids = {gridAll; gridHigh};

% Also get the IDs of the grids
ids = spatialGrid.ids(grids);

end