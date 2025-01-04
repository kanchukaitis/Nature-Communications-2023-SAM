function[reanalysis] = reanalysis
%% parameters.reanalysis  Returns the name of the reanalysis to use for the analysis
% ----------
%   reanalysis = parameters.reanalysis
%   Returns the name of the reanalysis dataset used in the analysis. The
%   reanalysis is used to determine regression coefficients for the PAGES2k
%   linear forward models. The reanalysis name should match the name of the
%   reanalysis as it appears in the filename of the gridfile data
%   catalogues.
% ----------
%   Outputs:
%       reanalysis (string scalar): The name of the reanalysis dataset to use

reanalysis = "20cr";

end
