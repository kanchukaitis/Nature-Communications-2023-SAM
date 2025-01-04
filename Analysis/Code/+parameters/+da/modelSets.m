function[modelSets, labels] = modelSets
%% parameters.da.modelSets  Return the sets of models to test in the DA
% ----------
%   [modelSets, labels] = parameters.da.modelSets
%   Returns the sets of models to test in the DA. Also returns a label for
%   each set. Each set is used to build a multi-model ensemble comprised
%   of the listed models.
% ----------
%   Outputs:
%       modelSets (cell vector [nSets] {string vector}): A cell vector. Each
%           element holds a list of names. Each list specifies a particular
%           set of models that should be used to build an ensemble for DA.
%       labels (string vector [nSets]): A label for each set of models

% Get the sets and labels
[allModels, allLabel] = parameters.models.all;
[highModels, highLabel] = parameters.models.highres;

% Combine
modelSets = {allModels, highModels};
labels = [allLabel, highLabel];

end