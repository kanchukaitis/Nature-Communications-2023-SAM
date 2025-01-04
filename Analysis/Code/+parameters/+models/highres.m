function[models, label] = highres
%% parameters.models.highres  List the names of high-resolution climate models
% ----------
%   [models, label] = parameters.models.highres
%   Lists the names of climate models considered as "high-resolution" for
%   the analysis. These should be the names of climate models as they
%   appear in the filename of the gridfile data catalogues for the climate
%   model output. Also returns a label for this set of models.
% ----------
%   Outputs:
%       models (string vector): The names of the high-resolution models
%       label (string scalar): A label for the set of models

models = ["ccsm4", "cesm", "mpi", "mri"];
label = "high";

end