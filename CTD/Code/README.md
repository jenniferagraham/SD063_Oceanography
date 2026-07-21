# BAS Polar Oceans CTD data processing

## History
This repository contains Matlab code for processing CTD casts. It is based on scripts originating from the University of East Anglia, derived from PSTAR data processing used for JR10 (1995) and prior cruises. The earliest Matlab implementation was used on JR40 (ALBRATROSS, 1999), with subsequent use on JR80 (Shagex, 2003), CD160 (RAPID, 2004), JR106 (AUI, 2004) and JR097 (AUI, 2005).The scripts were subsequently modified by several people at BAS on subsequent BAS JCR cruises, including JR141 (2006), JR161 (2007), JR165 (2007), JR177 (Discovery 2010, 2007-8), JR200 (2009), JR307 (WAP, 2014-15), JR15006 (ORCHESTRA, 2016) and JR17003 (ORCHESTRA, 2018).

In 2018, for cruise JR17003a (Larsen-C Benthos, 2018), Hugh Venables modified the code to make it more general, removing the need to edit individual scripts to fit the sensors installed on the CTD on each cruise. Subsequently the scripts have been maintained by Hugh Venables and Povl Abrahamsen, with further updates to ensure that they work on different computer platforms, improving the handling of bottle files, and more. The scripts have been used on JR18004 (ORCHESTRA, 2019), DY113 (ORCHESTRA, 2020 - for comparison against NOC's MSTAR data processing pipeline), and DY158 (2023).

In 2023, the scripts were used on SD033. Here, Milo Bischof updated the code to add more oxygen calibration features. On this cruise, calibrations were applied using separate scripts, found within the ancillary directory of this repository. In 2024, the scripts were used in the Arctic on SD041. Here, Martim Mas e Braga processed the main ship CTDs, adding ancillary scripts to [his own Github repository](https://github.com/martimmas/cruise_work). These have been added as a submodule to this repository. The plotting function has been updated by Povl Abrahamsen to include the upcast (the darker line is the downcast, the lighter is the upcast), and to allow more than three subplots in what used to be the "fluorometer/transmissometer/oxygen" plots. Dual oxygen sensors are also supported in these plots. Povl also used the scripts on the SBE19+V2 CTD data from Erebus ("cruise ER041"), resulting in changes to support data from internally recording Sea-Bird CTDs and  allow single C/T sensors.

## Description
The scripts are designed to process CTD casts, including bottle data, from Sea-Bird Scientific SBE911+ systems. The first processing steps, `datcnv` (data conversion), `align` (advancing oxygen data), and `celltm` (cell thermal mass correction) are performed in SBEdataprocessing. Subsequent steps take place in Matlab. These will be described in more detail in this file in the future.

## Support
This repository is maintained by:
- Hugh Venables (hjv@bas.ac.uk)
- Povl Abrahamsen (epab@bas.ac.uk)

## Authors and acknowledgment
The original authors of the Matlab code include Alberto Naveira Garabato, Mike Meredith, and Karen Heywood, with further changes during AUI by Martin Price, Paul Dodd, and Colin Goldblatt. Subsequent changes at BAS were made by Mags Wallace, Deb Shoosmith, Hugh Venables, Mark Brandon, Mike Meredith, and others. The code was generalised by Hugh Venables with subsequent edits by Povl Abrahamsen, Mike Meredith (DY158), Milo Bischof (SD033), and Martim Mas e Braga (SD041).

## License
Licensing to be confirmed.
