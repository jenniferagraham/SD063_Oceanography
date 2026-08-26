# BAS Polar Oceans Underway Processing

## History
This repository contains Matlab code for processing underway data from oceanographic cruises. It originates from an earlier set of Matlab scripts developed at UEA and BAS on cruises on RRS _Charles Darwin_ ([CD160](https://www.bodc.ac.uk/resources/inventories/cruise_inventory/report/6193/)) and RRS _James Clark Ross_ (JCR; [JR80](https://www.bodc.ac.uk/resources/inventories/cruise_inventory/report/6784/) and many subsequent cruises). These originally accessed the underway data using RVS pstar. On JCR, the data acquisition system was later upgraded to [SCS](https://scsshore.noaa.gov/), while the NMF ships used [TechSAS](https://www.flotteoceanographique.fr/en/Facilities/Shipboard-software/Gestion-de-missions-et-des-donnees/TECHSAS). Both NMF vessels and RRS _Sir David Attenborough_ (SDA) now run RVDAS, a data acquisition system jointly developed by [NOC](https://noc.ac.uk) and [BAS](https://www.bas.ac.uk). This is currently running concurrently with another data acquisition system, but will become the primary data acquisition in the future.

On the SDA science trials in autumn 2022, SD020, old scripts from JCR were updated to access the RVDAS data streams on board. However, the stream and variable names were coded into these scripts. On [DY158](https://www.bodc.ac.uk/resources/inventories/cruise_inventory/report/18119/) in Dec. 2022-Jan. 2023, the scripts were rewritten with enough flexibility to run on either of the NMF-operated vessels (RRS _Discovery_ and RRS _James Cook_) or SDA, despite the differences in instrumentation and RVDAS database configuration between the vessels. Further changes were made in 2024 to make the scripts more generally usable across different operating systems, without the use of external software.

## Getting started

The documentation below is based on the underway data processing chapter from the DY158 cruise report, by Povl Abrahamsen and the SD033 cruise report by Kat Turner. Thus, some of the code references DY158 and SD033. This should be changed, as appropriate, for future cruises that use this code.

### Prerequisities
- Matlab (tested with                                                                                                                    2024a, but should work with more recent versions)
- [Matlab database toolbox](https://www.mathworks.com/products/database.html) is a native Matlab toolbox that lets you interact with SQL databases seemlessly
- [m_map](https://www.eoas.ubc.ca/~rich/map.html) - used for plotting maps
- [seawater](https://www.cmar.csiro.au/datacentre/ext_docs/seawater.html) - we use the `sw_dist` function to compute distances, other functions are used in many ancillary scripts

### Folder structure
For data processing, the code is contained in a sub-folder called `code_underway`, while daily files are contained within subfolders `nav` (for navigation streams), `bathy` (for depth sounders), and `ocl` (deriving from the “Oceanlogger” on JCR, equivalent to “Surfmet” on the NMF vessels, containing oceanographic, meteorological, and other scientific sensors). Averaged files are saved at the top level, as shown below:

```
Underway (top folder, e.g. on `Public\DY158\scientific work areas`)
├── bathy (daily bathymetry files)
│   ├── ea640_sddpt (files for the EA640 single-beam sonar)
│   │   ├── ea640_sddpt_23003.mat (raw file)
│   │   └── ea640_sddpt_23003_clean.mat (clean file)
│   └── em122_kidpt (files for the EM122 multibeam sonar)
├── code_underway (Matlab scripts provided in this repository – described below)
│   ├── ancillary (archive of cruise-specific scripts - by cruise number)
│   └── underway_params_archive (archive of `set_underway_params.m` scripts)
├── dy158.gpx (GPX file of cruise track)
├── dy158_bathy_1s_ave.mat (1-s average bathymetry data)
├── dy158_bathy_30s_ave.mat (30-s average bathymetry data)
├── dy158_nav_posmv_1s_ave.mat (1-s nav data from PosMV)
├── dy158_nav_posmv_30s_ave.mat (30-s nav data from PosMV)
├── dy158_nav_seapath_1s_ave.mat (1-s nav data from SeaPath)
├── dy158_nav_seapath_30s_ave.mat (30-s nav data from SeaPath)
├── dy158_ocl_1s_ave.mat (1-s science data)
├── dy158_ocl_30s_ave.mat (30-s science data)
├── dy158_underway.nc (merged NetCDF file with nav, depth, and science)
├── nav (daily nav files – in subfolders by instrument/sentence)
├── ocl (daily science files – in subfolders by instrument)
│   ├── sbe45_nanan (files for SBE45 thermosalinograph)
│   │   ├── sbe45_nanan_23005.mat (raw file)
│   │   ├── sbe45_nanan_23005_clean.mat (clean file)
│   │   └── sbe45_nanan_23005_clean_cal.mat (clean, calibrated file)
│   └── surfmet_gpxsm (files for Surfmet data logger)
│       ├── surfmet_gpxsm_23005.mat (raw file)
│       └── surfmet_gpxsm_23005_clean.mat (clean file)
└── rtables_dy158.mat (list of tables on the RVDAS server)
```

Below, we assume that all code will be run from the `code_underway` folder, and any cruise-specific files are also in this folder (please move them into `ancillary` before uploading your updated code to this repository!).

### RVDAS data streams and databases

RVDAS stores its data in a PostgreSQL database. The scripts query the RVDAS PostgreSQL database using the native PostgreSQL interface in the Matlab database toolbox to load the data into Matlab files for each day. Editing and calibrations can then be applied to the data before the daily files are concatenated and averaged into 1-s and 30-s data files. A final [CF-compliant](http://cfconventions.org/) NetCDF file is generated at the end.

On the NMF vessels, a database is created for each cruise, while on SDA there is a single database, with a view for each cruise, which will display only the instruments used and the date range of the cruise in question. It is also possible to query the general database on SDA (outside of cruises with their own view) by specifying "sd" as the view. Database details are shown in the table below - if in doubt, check with IT or your data manager.

| Ship     | SDA                         | James Cook        | Discovery           |
| ------   | ------                      | ------            | ------              |
| Server   | sdl-pgdb-read.sda.bas.ac.uk | rvdas.cook.local  | ram.discovery.local |
| Port     | 5432                        | 5432              | 5432                |
| Username | rvdas_ro                    | rvdas             | rvdas               |
| Database | marine_sda                  | \[cruise number\] | \[cruise number\]   |
| View     | \[cruise number\] or "sd"   | n/a               | n/a                 |


First step is to set up your data source in Matlab. The example below is for SDA:
```
rvdas_sda=databaseConnectionOptions('native','postgresql');
rvdas_sda.DataSourceName='rvdas';
rvdas_sda.DatabaseName='marine_sda';
rvdas_sda.Server='sdl-pgdb-read.sda.bas.ac.uk';
```
At this stage, we should test the connection, using the username and password for the relevant database, e.g.:
```
status=testConnection(rvdas_sda,'rvdas_ro',\[database password for user rvdas_ro\])
```
If this works, we want to save our connection:
```
saveAsDataSource(rvdas_sda)
listDataSources
```

Now you are ready to run the rvdas_tables.m script! The script has a default DataSource name of "rvdas" but change this to whatever you have set the DataSource name to. If on any cruise that is not the SDA you can ignore the view parameter. The SDA makes use of views, these restrict the database output to instruments that are on installed on the cruise and the dates of the cruise. These will look something like <cruise_name>_parameter-you-are-looking-at. eg. sd033_wave_rutter_sigma_s6_wamos_ii_bridge1_pwam1. Check with your local friendly data manager for the view name - or use "sd" to query the database without a view. If you do not specify a view, many unused tables may be present in the database, for instruments that are not installed.

At the start of a cruise, or if the database has changed for some reason, a local file with a list of tables in the database is created by running the following lines, in the code directory:
```
rtables=rvdas_tables('rvdas','rvdas',\[database password for user rvdas\]);
save ../rtables_dy158 rtables
```
or
```
rtables=rvdas_tables('rvdas','rvdas_ro',\[database password for user rvdas_ro\],'sd033');
save ../rtables_sd033 rtables
```

By saving a local file, we do not need to query the database structure every time data are downloaded. It can take a long time to generate this file, depending on the speed of the server.
## Setup file
The list of variable names for the cruise, and metadata for the cruise itself, are stored in script `set_underway_params.m`. This is called by the other functions, most of which will not require cruise-specific editing. Templates for Discovery and SDA are present as `set_underway_params_disco.m` and `set_underway_params_sda.m`, respectively, in the `underway_params_archive` directory; these will require editing with any updated sensor calibrations, changed sensor names (or added sensors), etc. The file sets up structures mapping the variable names in RVDAS onto those exported in the averaged data files. If raw voltages are stored for a sensor, as is the case for the radiometers, fluorometer and transmissometer on most vessels, a function handle can also be provided to convert these to engineering values.

Ensure you have the correct conversion values! Check values for chlorophyll under set_underway_params

## Daily workflow
A daily workflow, in which the data for the previous day (or days) is usually followed.

Initially, data are downloaded from the database onto the local disk and stored in a Matlab file. For most of the scripts, the day number can be provided as an argument. If a year is not provided, the nearest year to the current date will be chosen. If a day number is not provided, the user will be prompted for this on the command line. Examples below are for 6 Jan (day number 6):

```
load_daily_nav(6);        % load daily navigation streams
append_daily_nav(6);      % append daily navigation to concatenated file
load_daily_bathy(6);      % load daily bathymetry streams
edit_daily_bathy(6);      % edit daily bathymetry streams manually
append_daily_bathy(6);    % append daily bathymetry
load_daily_ocl(6);        % load daily science sensors
dy158_edit_ocl(6);        % apply cruise-specific editing to science sensors
plot_daily_ocl(6);        % plot edited science sensors to check editing
append_daily_ocl(6);      % append science data
```
At this stage, the concatenated files of raw/edited data will be up to date. If, for any reason, a file is revised, it can be added to the concatenated file with `append_daily_[whatever]`. However, any subsequent files also need to be appended. Alternatively, all files can be concatenated using `make_total_[whatever]`.
Next, we make the averaged files:
```
make_ave_nav;              % calculate averaged navigation files
make_ave_bathy;            % calculate averaged bathymetry files
make_ave_ocl;              % calculate averaged science files
export_underway_to_netcdf; % merge the averaged files into a single CF-compliant NetCDF file
export_track_to_gpx(4);    % export the ship track to a GPX interchange file at 2-minute resolution
```

## Applying calibrations - on NMF vessels
While any sensor factory calibrations should be applied when the data are loaded, cruise-specific calibrations, such as for TSG conductivity/salinity, are best applied together with edits for bad data in a cruise-specific script, in this case `dy158_edit_ocl.m`. This script applies edits for when the TSG instruments were being cleaned, a few other range checks and errors with sensors, and then corrects the conductivity, and re-calculates salinity and speed of sound. After applying these edits to all days in the cruise, the concatenated file is recreated using the calibrated values:
```
for n=[356:365,1:29], dy158_edit_ocl(n); end
make_total_ocl;
```
Then the files can be averaged and exported to NetCDF as above.

## Applying calibrations - on SDA
Because SDA saves every sensor into a different table, rather than a single "surfmet" or "oceanlogger" table, it is not as straight forward to make edits in the daily files. On SD041 the solution was to concatenate the unedited files, then do the averaging, and apply the edits to the averaged files (where all variables have been binned onto the same timestamps). See `sd041_edit_ocl_ave.m`.

## Support
This repository is maintained by:
- Povl Abrahamsen (epab@bas.ac.uk)
- Hugh Venables (hjv@bas.ac.uk)

## Authors and acknowledgment
The original Matlab code was written by Mike Meredith for CD160, incorporating some prior code by David Stevens from JR80. Subsequent changes at BAS were made by Paul Holland, Dziga Pozzi-Walker, Deb Shoosmith, Hugh Venables, and others. The code was rewritten for RVDAS on SD020 and generalised on DY158 by Povl Abrahamsen. Kat Turner updated the code on SD033 to run on SDA with science sensors installed, and updated the code to use the ODBC drivers in the database toolbox. On SD041, Povl Abrahamsen updated the code to use the native PostgreSQL drivers, and Bryony Freer made additional changes to the code.

Some of the code for RVDAS database queries originates from [MEXEC](https://github.com/NOC-OCP/ocp_hydro_matlab) scripts written on JC211 by Brian King and Yvonne Firing. Echo sounder corrections use data from [BODC](https://www.bodc.ac.uk/resources/products/software/carters_tables/), with code ported from Fortran to Matlab by Brian King.

## License
Licensing to be confirmed.
