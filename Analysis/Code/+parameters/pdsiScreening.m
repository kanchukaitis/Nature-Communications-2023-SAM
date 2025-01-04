function[magnitude] = pdsiScreening
%% parameters.pdsiScreening  Return the cutoff magnitude for the PDSI screening
% ----------
%   magnitude = parameters.pdsiScreening
%   Returns the cutoff magnitude for the PDSI screening. This screening is
%   applied to the PDSI estimates for SADA and ANZDA. Estimated PDSI values
%   with a magnitude larger than this magnitude are considered unrealistic
%   and their values are set to NaN.
% ----------

magnitude = 10;

end