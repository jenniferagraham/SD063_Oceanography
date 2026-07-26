@echo off
set /p castno=Enter CTD number (three digits): 
echo Processing SD063 cast %castno%
sbebatch L:\work\scientific_work_areas\oceanography\CTD\SBEproc\process_ctd_cast.txt %castno%
echo Done!
