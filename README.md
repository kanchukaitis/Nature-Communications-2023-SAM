# Southern Annular Mode (SAM) Paleoclimate Data Assimilation
This repository contains just the code used to assimilate the Southern Annular Mode index over the Common Era from King et al. (2022).  For the complete repository, which includes the external or ancillary code for doing the assimilation as well as the input and output data files and the final reconstruction (approximately 8GB), please visit the complete Zenodo repository [here](https://zenodo.org/records/8156908). 

## Citation
King, J., K.J. Anchukaitis, K. Allen, T. Vance, A. Hessl, Trends and variability in the Southern Annular Mode during the Common Era, Nature Communications, 14, 2324, doi:10.1038/s41467-023-37643-1, 2023.

## Contents
This repository holds just the code used to implement the analyses and figures in the paper, not including the DASH core and PDSI proxy systems model.  For the complete code and data, which includes the NetCDF files of the input and output, please see the Zenodo directory [here](https://zenodo.org/records/8156908). 

* `Analysis`: This folder contains the code used to implement the analyses, as well as all intermediate output files produced by the code. We recommend users begin with the `runAnalysis.m` script, which demonstrates how to run all the code required to reproduce the analysis.

## Code Dependencies
You will need Matlab 2020b or higher to run the code.

Several of the folders rely on code or output files from other folders in the repository. Specifically:

* Several of the sections in the `Analysis` folder rely on raw data in the `Input Data` folder. You can find additional details in the `runAnalysis.m` script in the `Analysis` folder.

* All of the functions in the `Figures and Tables` folder rely on output files located in the `Analysis` folder. Thus, you will need to download the `Analysis` folder to reproduce the figures. Additional details can be found in the `figuresAndTables.m` script in the `Figures and Tables` folder.

* Once again, for the complete code and data, which includes the NetCDF files of the input and output, please see the Zenodo directory [here](https://zenodo.org/records/8156908).  
