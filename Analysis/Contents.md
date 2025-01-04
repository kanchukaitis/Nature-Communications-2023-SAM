# Analysis

This folder holds the code and intermediate output files used to implement the assimilation and analyses. The contents of this folder can be used to reproduce the results presented in the paper, or to rerun the analyses using different experimental parameters.

## Contents Summary
The following is an overview of the contents of this folder. Additional details on each item are provided below.

* [7 Numbered Subfolders](): We have divided the analysis into 7 distinct pieces, and each of these subfolders holds any intermediate output files produced by these steps.

* [Code](#code): This folder holds all the code we wrote in order to implement the analysis.

* [External Packages](#external-packages): This folder holds all the external Matlab packages we used to implement the analysis.

* [runAnalysis.m](#runanalysism): This script demonstrates how to use the code to reproduce the analysis presented in the paper.


## Using this folder
After first reading this file, we suggest that users next proceed by opening the `runAnalysis.m` script in the Matlab editor and reading the documentation therein. The `runAnalysis` file demonstrates how to use all the provided code and breaks down all the major steps of the analysis. It also details the requirements needed to get the code to run.

The `Analysis` folder contains already contains all the intermediate output files produced by our code. As such, you can rerun most steps of the analysis without needing to rerun any previous steps (some of which may take a while to compute). So for example, if you are only interested in reproducing the optimal sensor analysis, you can skip directly to the code in section 6 of `runAnalysis`.

### Altering the analysis
We anticipate that some users will be interested in altering the analysis and running the assimilations with different experimental parameters. (For example, using a different collection of proxy networks, a different latitude cutoff, different selection of models, different reanalysis, etc). There are several ways you can do this.

A first approach is to edit `runAnalysis.m` directly. Many of the sections in `runAnalysis` begin by loading several experimental parameters into the workspace. A quick way to alter the analysis is to comment out these lines and use a different value for the variable.

For a more comprehensive approach, you can instead edit the files in the `+parameters` package of the `Code` subfolder. The `+parameters` package holds a number of files, and each file sets an experimental parameter for the analysis. Editing these files will allow you use different parameters throughout the analysis, without needing to alter `runAnalysis.m`. For example, if you want to only assimilate the PAGES2k network, then you can edit the value returned by `parameters.da.networks`. Or if you want to use a different latitude cutoff threshold, then you can edit the value returned by `parameters.latitude.cutoff`. You can read about the different parameters/files in the package by entering `help parameters` in the Matlab console.

Finally, more radical departures from our setup may require altering the codebase directly, and you can do this by editing the files in the `Code` subfolder. You can read the `Contents.md` file in the `Code` subfolder for more details about the layout of our codebase.


## Contents
The following is a detailed description of the contents of this folder:


### runAnalysis.m
This script demonstrates how to use our codebase to reproduce the assimilations and analyses presented in the paper. The script is divided into several sections, each implementing a key piece of the analysis. The script also includes documentation for setting up your Matlab environment in order to be able to run the code.

### Code
This subfolder contains the code we wrote in order to implement the analysis. You can read the `Contents.md` file in the subfolder to see additional details about the layout and contents of our codebase.

### External Packages
This subfolder contains all external Matlab packages we used to implement the analysis.

* `DASH-4.0.0-alpha-5.0.6`: The DASH toolbox for paleoclimate data assimilation. We use this package to implement all of the data assimilation routines in the analysis. DASH is available on github [here](https://github.com/JonKing93/DASH). We used a prototype of the current V4 DASH release, specifically version 4.0.0-alpha-5.0.6.

* `pdsi-1.0.0`: This package implements the non-linear PDSI forward models used to estimate values for the drought atlases. The package is available on github [here](https://github.com/JonKing93/pdsi). We used version 1.0.0 for this analysis.

* `sowas.0.93.matlab`: The sowas package implements a number of routines for wavelet analysis. We use it to implement the solar forcing wavelet analysis. The package is available [here](https://tocsy.pik-potsdam.de/wavelets/). We used version 0.93 (of the Matlab release) for our analysis.

### 1-Organize-Inputs
This subfolder contains pre-processed input data (or in some cases, pre-processed gridfile data catalogues) for the analysis. It includes values from the proxy networks, climate model output, 20CR reanalysis, instrumental SAM indices, previous SAM reconstructions, and climate forcing datasets.

### 2-Proxy-Error-Covariances
This subfolder contains the output files produced when estimating proxy error covariances (R values). There are 5 key steps of this process:

A. We bin the 20CR temperature and precipitation variables to the spatial grid of the assimilation over the drought atlas domains.

B. We estimate the climate variables recorded by the various proxy records. This includes running the PDSI model over the binned variables to get PDSI values for the binned reanalysis over the drought atlas domains. It also includes determining seasonal temperature means at each of the PAGES2k sites.

C. Next, we perform the linear regression used to calibrate the PAGES2k forward models. This involves regressing the seasonal temperature means from 20CR against the PAGES2k records to obtain regression coefficients.

D. Next, we estimate the proxy records from the analysis. This proceeds by screening the PDSI values for the drought atlases, and by running the now-calibrated PAGES2k forward models on the seasonal temperature means.

E. Finally, we estimate R values by comparing the proxy records with the proxy estimates from the reanalysis. The differences between the two are considered the errors, and are used to compute the error covariances.

### 3-Priors
This subfolder contains the prior ensemble for each of climate models used in the analysis. These ensembles are built generated by computing the Gong and Wang (1999) SAM index over the output from each model.

### 4-Proxy-Estimates
This folder contains the output files produced when calculating proxy estimates for each of the models. There are 3 steps to this process:

A. First, we bin the temperature and precipitation output from each model to the spatial grid of the assimilation over the drought atlas domains.

B. We next estimate the climate variables recorded by the proxy records. This includes running the PDSI model on the binned variables over the drought atlas domains. It also includes determining seasonal temperature means for the PAGES2k sites.

C. Finally, we estimate the proxy records. This includes screening the PDSI values, and running the linear PAGES2k forward models on the seasonal temperature means.


### 5-Assimilations
This folder contains output from Kalman Filter assimilations. It is divided into two subfolders: `All models` and `High resolution models`. Each of these subfolders holds the raw assimilations, as well as the frozen-network assimilations for the latitude cutoff threshold parameter sweep. These subfolders hold a number of `.mat` files (Matlab's binary file format). Each individual `.mat` file holds the results of one assimilation. Most of the files are rather small (~23 KB), but the file `high_gong_-25` is much larger (~60 MB). This is because `high_gong_-25` holds the final assimilation and thus includes the updated posterior deviations.


### 6-Optimal-Sensor
This folder holds the results of the optimal sensor analysis. It contains 3 files. The two files beginning with `anzda` or `sada` hold results for the full atlas block updates. The file beginning with `sensor` holds the results for the single-proxy network analysis.


### 7-Climate-Analysis
This folder holds results of the various climate analyses. It includes subfolders holding the results of the trend analysis, as well as the volcanic SEA. (The solar wavelet analysis does not produce any output files, so does not have a folder here).
