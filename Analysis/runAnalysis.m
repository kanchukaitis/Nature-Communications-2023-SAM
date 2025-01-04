%% runAnalysis
%
% SUMMARY
% -------
% This script demonstrates how to run the functions used to produce the
% analysis and reconstruction. We have organized the analysis into several
% main steps. In brief, these are to:
%
% 1. Clean, catalogue, and organize the raw input data
% 2. Estimate proxy error covariances (R values)
%       * Calibrate forward models
%       * Run forward models on the 20CR reanalysis
%       * Compare the forward model outputs to the real proxy records
% 3. Build DA priors/ensembles
%       * Compute the Gong and Wang SAM index for each climate model
% 4. Generate proxy estimates
%       * Run forward models on climate model output
% 5. Kalman Filter Assimilations
%       * Run the DA for various latitude cutoff thresholds
%       * Run the frozen network assimilations
% 6. Optimal sensor analysis
%       * Single proxy add-ins
%       * SADA and ANZDA block updates
% 7. Climate analysis
%       * Solar forcing wavelet
%       * Volcanic SEA
%       * Trend analysis
% 8. Export Reconstruction
%       * Organize final reconstruction in NetCDF format
%
%
% USING THIS SCRIPT
% -----------------
% This script shows how to pass inputs to the various functions used to
% implement the analysis. Most of these functions produce intermediate 
% output files. These files hold the results from previous steps in the
% analysis, and the functions for later steps require these output files to
% run.
%
% That said, the Zenodo repository already contains all the intermediate 
% files used in the analysis (in addition to the code). As such, you can
% rerun most steps of the analysis without needing to run previous steps. So
% for example, if you are only interested in reproducing the optimal sensor
% analysis, you can skip directly to the code in section 6.
%
% If you do decide to rerun the full analysis, note that any intermediate
% output files will be saved to the current directory. (unlike the Zenodo
% repository, in which we have organized the output files into various
% subfolders).
%
%
% PREREQUISITES
% -------------
% In order to run these scripts, you must first:
%
%   1. Install Matlab 2020b or higher, and
%   2. Add the "analysis" folder (and all subfolders) to the active Matlab
%      path. You can do this by right-clicking the "analysis" folder in the
%      Matlab editor, and then selecting the 
%      "Add to Path"->"Selected Folder and Subfolders" option.
%
% If you want to rerun sections 1, 2A, 3, or 4A, then you will also need to
%
%   3. Download the "Input Data" folder, and add it (and all subfolders) to
%      the active Matlab path.
%
% If running sections 1B, 3, or 4A, you will also need to prepare the raw
% climate model data. To do so, you should:
%
%   4. Download the raw climate model output files detailed in "Input Data",
%   5. Add these files to the active Matlab path, and
%   6. Re-run the code organizing these datasets (lines 91-109 of this file)


%% 1. Clean and organize input data sets

% Clean and organize the proxy (PAGES, SADA, ANZDA) datasets
organize.PAGES;
organize.ANZDA;
organize.SADA;

% Organize the 20CR reanalysis
organize.CR20("prate", "precip");
organize.CR20("prmsl", "slp");
organize.CR20("air.sig995", "tref");

% Catalogue the instrumental indices
organize.MarshallDJF;
ogranize.FogtDJF

% Organize PMIP climate model output
varNames = ["precip","slp","tref"];
mipVarNames = ["pr", "psl", "tas"];
for v = 1:numel(mipVarNames)
    organize.BCC(mipVarNames(v), varNames(v));
    organize.CCSM4(mipVarNames(v), varNames(v));
    organize.CSIRO(mipVarNames(v), varNames(v));
    organize.FGOALS(mipVarNames(v), varNames(v));
    organize.HadCM3(mipVarNames(v), varNames(v));
    organize.IPSL(mipVarNames(v), varNames(v));
    organize.MIROC(mipVarNames(v), varNames(v));
    organize.MPI(mipVarNames(v), varNames(v));
    organize.MRI(mipVarNames(v), varNames(v));
end

% CESM-LME model output
organize.CESMPrecip("precip");
organize.CESM("TREFHT", "tref");
organize.CESM("PSL", "slp");

% Bin the drought atlases to the lower resolutions of the reanalysis and
% climate model spatial grids
grids = parameters.spatialGrids;
for g = 1:numel(grids)
    bin.atlas("anzda", grids{g});
    bin.atlas("sada", grids{g});
end

% Organize the other SAM reconstructions
organize.Abram2014;
organize.Villalba2012;
organize.Datwyler2018;
organize.Dalaiden2021;
organize.OConnor2021;


%% 2. Estimate Proxy Error Covariances (R)

% Get some parameters used to estimate error covariances
[grids, ids] = parameters.spatialGrids;   % The spatial grids associated with the tested ensembles
sadaCafec = parameters.cafec.sada;        % The CAFEC interval for SADA
anzdaCafec = parameters.cafec.anzda;      % The CAFEC interval for ANZDA
threshold = parameters.pdsiScreening;     % The threshold magnitude for PDSI screening
Ryears = parameters.years.R;              % The comparison years used to estimate R values
reanalysis = parameters.reanalysis;        % The reanalysis used to estimate R values

%%%% Drought Atlases

% Bin the reanalysis variables to the same resolution as the drought atlases
for g = 1:numel(grids)
    bin.overAtlas(reanalysis, "precip", "anzda", ids(g));
    bin.overAtlas(reanalysis, "precip", "sada", ids(g));
    bin.overAtlas(reanalysis, "tref", "anzda", ids(g));
    bin.overAtlas(reanalysis, "tref", "sada", ids(g));

    % Generate PDSI fields from downgridded reanalysis variables
    estimate.atlas.pdsi(reanalysis, "anzda", anzdaCafec, ids(g));
    estimate.atlas.pdsi(reanalysis, "sada", sadaCafec, ids(g));
    
    % Estimate drought atlases for the reanalysis by taking DJF seasonal 
    % PDSI means and removing values with unrealistic magnitudes
    estimate.atlas(reanalysis, "anzda", threshold, ids(g));
    estimate.atlas(reanalysis, "sada", threshold, ids(g));

    % Estimate error covariances (R, uncertainty) for each atlas
    estimate.atlas.R("anzda", reanalysis, Ryears, ids(g));
    estimate.atlas.R("sada", reanalysis, Ryears, ids(g));
end

%%%% PAGES2k

% Get PAGES seasonal temperatures and regression coefficients. Estimate
% PAGES records for the reanalysis and use to compute error covariance
estimate.pages.temperatures(reanalysis);
estimate.pages.coefficients(reanalysis, parameters.years.regression);
estimate.pages(reanalysis);
estimate.pages.R(reanalysis, Ryears);


%% 3. Priors

% Get years to use for the standardization step. Also get the models
gongYears = parameters.years.gongStandardization;
models = parameters.models.all;

% Calculate the Gong and Wang (1999) SAM index for each model
for m = 1:numel(models)
    gong.index(models(m), gongYears, 'pi');
end


%% 4. Compute Proxy Estimates

% Get various parameters required to estimate proxies
models = parameters.models.all;          % The names of all the models
[grids, ids] = parameters.spatialGrids;  % The spatial grids used for DA
sadaCafec = parameters.cafec.sada;       % The CAFEC interval for SADA
anzdaCafec = parameters.cafec.anzda;     % The CAFEC interval for ANZDA
threshold = parameters.pdsiScreening;    % The threshold for PDSI screening

% Bin model output to the same spatial grids as the drought atlases
for m = 1:numel(models)
    for g = 1:numel(grids)
        bin.overAtlas(models(m), "precip", "anzda", ids(g));
        bin.overAtlas(models(m), "precip", "sada", ids(g));
        bin.overAtlas(models(m), "tref", "anzda", ids(g));
        bin.overAtlas(models(m), "tref", "sada", ids(g));
    
        % Generate PDSI values over each drought atlas for each model
        estimate.atlas.pdsi(models(m), "anzda", anzdaCafec, ids(g));
        estimate.atlas.pdsi(models(m), "sada", sadaCafec, ids(g));     
        
        % Estimate atlases using DJF seasonal PDSI means
        estimate.atlas(models(m), "anzda", threshold, ids(g));
        estimate.atlas(models(m), "sada", threshold, ids(g));
    end

    % Get seasonal temperatures at the PAGES sites and use the regression
    % coefficients to estimate proxy records
    estimate.pages.temperatures(models(m));
    estimate.pages(models(m));
end


%% 5. Kalman Filter Assimilations

% Get various parameters for the assimilation
networks = parameters.da.networks;               % The proxy networks to include
[modelSets, setIDs] = parameters.da.modelSets;   % The sets of models to test as ensembles
prior = parameters.da.prior;                     % The type of prior to use
reanalysis = parameters.reanalysis;              % The reanalysis used to derive proxy estimates
priorYears = parameters.years.prior;             % The years of output to include in the prior
anomalyYears = parameters.years.anomaly;         % The years used as a background for proxy anomalies 
daYears = parameters.years.reconstruction;       % The years to reconstruct
latitudes = parameters.latitude.tests;           % The latitude thresholds to test

% Iterate through sets of models and latitude cutoff thresholds. Get a
% label for each set of parameters
for m = 1:numel(modelSets)
    for k = 1:numel(latitudes)
        label = sprintf('%s_%s_%+03.f', setIDs(m), "gong", latitudes(k));

        % Run a raw assimilation for the settings
        da.assimilate(modelSets{m}, prior, priorYears, networks, latitudes(k), ...
            anomalyYears, reanalysis, daYears, 1, label);

        % Run a frozen network assimilation for the settings
        da.frozen(modelSets{m}, prior, priorYears, networks, latitudes(k), ...
            anomalyYears, reanalysis, daYears, label);
    end
end

% Run the final assimilation (including posterior deviations) for a
% selected ensemble and cutoff latitude
latitude = parameters.latitude.cutoff;             
[models, modelLabel] = parameters.models.highres;  
label = sprintf('%s_%s_%+03.f', modelLabel, "gong", latitude);

da.assimilate(models, prior, priorYears, networks, latitude, anomalyYears, ...
    reanalysis, daYears, 3, label);


%% 6. Optimal sensor analysis

% Get various parameters for the optimal sensor
networks = parameters.da.networks;                % The proxy networks to include
latitude = parameters.latitude.cutoff;            % The latitude cutoff for the proxy networks
prior = parameters.da.prior;                      % The type of prior to use
[models, modelLabel] = parameters.models.highres; % The set of models to use
reanalysis = parameters.reanalysis;               % The reanalysis used to derive proxy estimates
priorYears = parameters.years.prior;              % The years of output to include in the prior
anomalyYears = parameters.years.anomaly;          % The years used as a background for proxy anomalies 
daYears = parameters.years.reconstruction;        % The years to reconstruct

% Run the single proxy optimal sensor analysis
label = sprintf('%s_%s_%+03.f', modelLabel, "gong", latitude);
da.sensor(models, prior, priorYears, networks, latitude, anomalyYears, ...
    reanalysis, daYears, label);

% Run the single-block updates for ANZDA and SADA in 1600
year = 1600;
networks = ["anzda","sada"];

for n = 1:numel(networks)
    label = sprintf('%s_%04.f-%s_%s_%+03.f', networks(n), year, modelLabel, "gong", latitude);
    da.assimilate(models, prior, priorYears, networks(n), latitude, ...
        anomalyYears, reanalysis, year, 2, label);
end


%% 7. Climate analysis

% Use the high-resolution assimilation with a cutoff latitude of 25 S
reconstruction = "high_gong_-25";


%%%% Solar wavelet analysis

% Parameters
plotParameters = {2, 8, 10, -1, .5, .5};   % Parameters for the plotted analysis (see the wco.m function of the sowas package for details)
years = 850:2000;                          % The years to analyze

% Run the wavelet analysis
solarWavelet(reconstruction, years, plotParameters);


%%%% Volcanic SEA

% Parameters
searchYears = 1:2000;                    % The years of the reconstruction to include in the SEA
eventYears = parameters.years.volcanic;  % The years of major volcanic events
anomalyYears = -5:-1;                    % The years of the SEA anomaly period (relative to each event year)
computeYears = -5:10;                    % The years in which to compute the SEA (relative to each event year)
MC = 5000;                               % The number of Monte Carlo iterations to use for testing significance

% Run the SEA
label = sprintf('last2k-%s', reconstruction);
sea.sam(reconstruction, searchYears, eventYears, anomalyYears, computeYears, MC, label);


%%%% Trend analysis

% Parameters
CI = 0.95;                                     % The confidence interval for testing significance
modernYears = 1900:2000;                       % The years to use as "modern" trend
backgroundYears = {1500:2000, 1:2000, 1:899};  % The years to use for computing natural variability
backgroundID = ["atlas", "pi", "early"];       % Labels for the sets of background years

% Run the analysis for each set of background years
for k = 1:numel(backgroundYears)
    label = sprintf('trend-%s-%.f-%s', backgroundID(k), 100*CI, reconstruction);
    trend.analysis(reconstruction, modernYears, CI, backgroundYears{k}, label);
end


%% 8. Compute statistics for O'Connor 2021 and Dalaiden 2021
% (The statistics reported in these papers use a different time interval,
% so need to recalculate over 1958-2000 for a fair comparison).

% Get the reconstructions
d21 = gridfile('dalaiden-2021.grid');
o21 = gridfile('oconnor-2021.grid');

% Limit to 1958-2000
years = 1958:2000;
dYears = ismember(d21.metadata.time, years);
oYears = ismember(o21.metadata.time, years);

% Load the SAM indices
dSAM = d21.load("time", {dYears});
oSAM = o21.load("time", {oYears});

% Get the correlations and p-values



%%%%% Statistics for O'Connor 2021 and Dalaiden 2021
rhos = corr(


%% 8. Export Final Reconstruction to NetCDF

% Export the high-resolution reconstruction with a 25 S latitude cutoff
reconstruction = "high_gong_-25";
file = 'reconstruction.nc';
exportReconstruction(reconstruction, file);

% Note that the exported reconstruction is located in the root folder of
% the Zenodo repository, rather than in the "Analysis" folder.
