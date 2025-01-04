function[models, label] = all
%% parameters.models.all  List the names of the climate models used in the analysis
% ----------
%   [models, label] = parameters.models.all
%   Returns the names of the climate models considered in the analysis.
%   These are the names of the climate models as they appear in the
%   filenames of the gridfile catalogues for the organzed climate model
%   output. Also returns a label for the set of models
% ----------
%   Outputs:
%       models (string vector): A list of climate model names
%       label (string scalar): A label for the set of models

models = ["bcc","ccsm4","cesm","csiro","hadcm3","fgoals","ipsl","miroc","mpi","mri"];
label = "all";

end