This folder contains data and processing script for the MSS (microstruture shear profiler) model 34

Below is a general description of files in each folder 

DATA/ 
process matfiles arranged as a structure for each cast SD063_mss_castnumber_struc.mat and all casts together sd063_mss.mat These are the data that we used for plotting. 
ncfiles/ the structure variables above were converted to ncfiles using mat_to_ncfiles.m and stored here
raw/ stores the raw .MRD files saved during deployment 
raw_cut/ tob files representing the mannually cut .MRD files suing MSS cuttgraph tool to exclude the data after the instrument touches the bottom.
converted/ stores our first attempt to process the full cast (upcast and downcast) from the tow-yo casts, this skipped the cutgraph step. 
raw_cutTS/ another attempt to process both the up and down cast from tow-yo. Neither was successfull before the end of the cruise
batch_shear and batch_eps/ contain the batch processing of shear and epsilon. Inside each directory a text file diary.txt describes what was done. 

datapro_1p05/ contains the sofware MSSpro used for the processing of the data during the cruise 

InstrumentLost-report/ a document reporting the events leading to the loss of the MSS in 3-miippugut during the tow-yo deployment. 

logbook/ 
Contains information on the logbook 
Scanned: .pdf 
electronic: .csv 
    original 
    + tidal phase: we have added the tidal phase to the .csv file. the tidal model use is on leg/work/scientific_work_areas/oceanography/Gr1KmTM
Logsheet
blanck logsheets to record MSS deployments, once filled these were scanned to have the loogbook

photos/
team photos and MSS photos 

Processing/ 
all the processing script. The heading text on each scripts describes what it does. 
Documents with information on how to process the data using MSSpro.
Shear probe sensitivity. 
work/ initially MSSpro routines used to build the batch processing. 
batch_SD063/ file that MSSpro1p03 reads to batch process. this was not use after we moved to MSSpro1p05. 

Setup_deployment/
Information for setting up the MSS on the aft deck, tips on how to do the deploymnet, 