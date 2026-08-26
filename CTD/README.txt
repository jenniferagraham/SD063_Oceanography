Documents relating to processing of CTD data, including scripts and relevant datasets for SD063.

All raw data retrieved from CTD casts are contained in:

leg\system\ctd_seabird_sbe911plus\acquisition\data\SD063

Relevant locations to be aware of are: 

* SBEproc: Contains first stage of post-processing (including SBE batch scripts). 
* Code: core matlab processing scripts (produces output in BASproc).
* BASproc: Contains data from further post-processing, in .mat format. 
* ncfiles: conversion of .mat into netCDF format. 

* GSWscripts: gsw toolbox, used in postprocessing and analysis. [NB. not archived in GitHub] 

Additional locations contain scripts used for planning and initial analysis during SD063: 

* plot_transects: contains majority of plotting scripts from cruise. 
* plot_maps: scripts to plot tidal analysis on maps of fjord. 
* Tide_analysis_output: csv and figures produced from tidal model analysis, e.g., plot_tide_simple.m
* plot_calibrations: analysis of calibration processing

NB. Some data and processing relating to calibration is also contained in Salinometer directories.

For plotting maps and other post-processing, the following paths are needed from level above: 
* TMD3.0
* Gr1kmTM
* matlabF

For further details on processing, please refer to CTD Processing section of cruise report. 

