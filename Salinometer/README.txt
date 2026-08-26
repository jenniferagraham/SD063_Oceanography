This directory contains data and scripts relating to salinometer processing of salinity samples onboard the RRS Sir David Attenborough on the SD063 GIANT cruise. The subdirectory structure is as follows:

--------- Salinometer --------
---- data
---- How-to-guide
	-- Salinometer software guides
	-- SDA_AME_AUTOSAL_Logsheet_Manual
---- lab_temperature
---- salinities
---- SalinometerCondRatios
---- Scans_Salinometer_logsheets

The "data" directory contains the raw output files from the salinometer instrument for all salinity processing during SD063. There are four files per session, with the suffixes: dat, hdr, raw and txt. The dat and txt files may be imported as TSV (tab-separated) plain text files. 

The directory "How-to-guide" contains the software guide for the Salinometer data acquisition program, the user manual and logsheet for the salinometer, and the SOP for salinometry on SD063. 

"lab_temperature" contains a timeseries of the temperature in the Salinometer room measured by a , which was used to determine when the temperature was stable enough for analysis to begin. 

"salinities" contains salinity files which have been processed using the script salinityprocessing.m in the top-level directory. The files have the format output**.csv and are the input for the CTD calibration.

"SalinometerCondRatios" contains separate files for each CTD cast where salinity sampling was performed, including the bottle number for the sample and its measured conductivity ratio K. The files have the format sal**.csv.

Scans_salinometer_logsheets contains scanned copies of the paper log sheet used to record measurement readings during each session with the salinometer instrument.

salinityprocessing.m in the top-level directory is the script which takes the per-cast conductivity values under SalinometerCondRatios as input, and outputs converted bottle salinities for each cast under "Salinities". This is part of the calibration workflow for CTD measurements and should be used in combination with scripts in the CTD/Code directory on the SD063 legwork drive. Further information and instructions are in SDA063_CTD_DataProc_Workflow.docx under the CTD directory. 