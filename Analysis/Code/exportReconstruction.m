function[] = exportReconstruction(reconLabel, file)
%% exportReconstruction  Exports the final reconstruction to NetCDF
% ----------
%   exportReconstruction(reconLabel, file)
%   Exports the indicated reconstruction to NetCDF. The associated
%   assimialtion outputs should include updated posterior deviations.
% ----------
%   Inputs:
%       reconLabel (string scalar): The label of a reconstruction to export
%       file (string scalar): The file name for the new NetCDF file.
%
%   Outputs:
%       Creates a NetCDF file in the current directory.

% Settings for export
years = 1:2000;
percs = 1:99;

% Load the reconstruction
[sam, samSigma, samPercs] = load.reconstruction(reconLabel, years, percs);

% Get sizes
nYears = numel(years);
nPercs = numel(percs);

% Create NetCDF variables
nccreate(file, 'years', 'Dimensions', {'years',nYears});
nccreate(file, 'percentiles', 'Dimensions', {'percentiles',nPercs});
nccreate(file, 'sam', 'Dimensions', {'years',nYears});
nccreate(file, 'sam_sigma', 'Dimensions', {'years',nYears});
nccreate(file, 'sam_percentiles', 'Dimensions', {'years',nYears,'percentiles',nPercs});

% Write attributes
ncwriteatt(file, 'years', 'Units', 'Common Era');
ncwriteatt(file, 'sam', 'Description', 'The reconstructed SAM index time series. This is the mean of the assimilated ensemble in each reconstructed year.');
ncwriteatt(file, 'sam_sigma', 'Description', 'The standard deviation across the assimilated ensemble in each reconstructed year. This can help quantify the uncertainty in the reconstructed time series.');
ncwriteatt(file, 'sam_percentiles', 'Description', 'The percentiles of the assimilated ensemble in each reconstructed year. This can help quantify the uncertainty in the reconstructed time series.');

% Write values
ncwrite(file, 'years', years);
ncwrite(file, 'percentiles', percs);
ncwrite(file, 'sam', sam);
ncwrite(file, 'sam_sigma', samSigma);
ncwrite(file, 'sam_percentiles', samPercs);

end