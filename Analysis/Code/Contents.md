# Code

This folder holds code written to help implement the SAM assimilation. Many of the contents of this folder are Matlab packages (folders that begin with a plus (+) symbol). You can read additional details on these packages by entering `help <package name>` in the Matlab console.


## Contents

* +bin: Functions that bin gridded variables over lower resolution spatial grids
* +da: Functions used to implement Kalman filter analyses
* +estimate: Functions used to generate proxy estimates
* +gong: Functions used to compute the Gong and Wang (1999) SAM index
* +load: Functions that load values from intermediate output files
* +organize: Functions that organize and pre-process raw input data
* +parameters: Functions that return experimental parameters for the analysis. You can edit these functions to change the analysis.
* +screen: Functions that screen out proxy records
* +sea: Functions that implement the volcanic SEA
* +trend: Functions that implement the trend analysis
* detrendedScaling.m: Computes factors that scale the standard deviation of a detrended time series to a target detrended time series.
* exportReconstruction.m: Exports a final reconstruction to a NetCDF file format
* loadYears.m: Loads data from specific years from a gridfile data catalogue
* regridAtlas.m: Regrids a drought atlas on a coordinate grid to a cartesian grid
* solarWavelet.m: Performs the solar wavelet analysis
* spatialGrid.m: A class to helps organize and implement the different spatial grids used for assimilation
