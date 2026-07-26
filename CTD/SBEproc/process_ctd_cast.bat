@echo off
set /p castno=Enter CTD number (three digits): 
echo Processing SD063 cast %castno%
set /p bottles=Did you sample niskin bottles (y/n):
if /i "%bottles%"=="y" (
    echo Processing with niskin bottles ...
    sbebatch L:\work\scientific_work_areas\oceanography\CTD\SBEproc\process_ctd_cast.txt %castno%
) else if /i "%bottles%"=="n" (
    echo WARNING: Processing with NO niskin bottles ...
    sbebatch L:\work\scientific_work_areas\oceanography\CTD\SBEproc\process_ctd_castNoBott.txt %castno%
) else (
    echo ERROR: y or n required
)
echo Done!
