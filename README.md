# SCBI Dendrometer bands

Note: Also relevant (for code, cross-site integration) is the [ForestGEO Dendro repository](https://github.com/forestgeo/dendro) (contact @maurolepore for access).

## Overview 
This repository contains dendrometer bands data for the SCBI ForestGEO plot. There are two sets of measurements: 

*Biannual dendrometer bands* - dendrometer bands on >500 trees measured at start and end of growing season

*Intra-annual dendrometer bands* - dendrometer bands on >150 trees measured ~ every 2 weeks

Active data is found the [clean_data_files](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) folder. Each year has its own set of files, including a master csv, field_forms, data_entry_forms, and maps.

- field_forms and data_entry_forms are pulled from the year's master via R-scripts, and data is subsequently merged back to the master in the same way

In the interest of keeping survey data entry simplified, each type of survey (biannual and intraannual) has its own .csv for data entry for the current year. This is where the current year’s data will be entered during the growing season (March – November). When the growing season is finished and the November biannual survey is complete, data should be transferred to the scbi.dendroAll_YEAR.csv via joining/merging in R. 
1.	Metadata for these individual forms are consistent with the metadata for the scbi.dendroAll_YEAR.csv (the master).


## Sampling location
[SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)


## Sampling period
*Biannual dendrometer bands* (measured at start and end of growing season): 2010 - present

*Intra-annual dendrometer bands* (measured ~ every 2 weeks): 2011 - present


## Protocols
*Biannual dendrometer bands* - In 2010, 243 bands were initially installed, with more than 570 stems of various DBH (55-1520 mm) being monitored as of October 2018. Protocols for band installations and remeasurement are published here ([original protocol](https://forestgeo.si.edu/sites/default/files/metal_band_dendrometer_protocol_done_1.pdf); [latest protocol](https://docs.google.com/document/d/1kCG22EAEnOVxw9Z-cPPvrHIzvRFE-j0U7anTmhJbkqM/edit)).

*Intra-annual dendrometer bands* - [fill in]
As of 2018, 155 stems of DBH ranging from 60-1480 mm are monitored biweekly during the growing season each year.

## Tree data
A list of tree species by survey type, full counts of each species, and dbh min, max, and average is available [here](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/clean_data_files/dendro_trees_dbhcount.csv).

Data on trees from which cores were taken is available through the core census data. Please see [this page](https://github.com/EcoClimLab/SCBI-ForestGEO-Data) for links to the data.

Geographic location of tree species by quadrat, lat/lon, and qualified by survey type and which trees have been cored is available in [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/clean_data_files/dendro_trees.csv).

## Data use

[Data are not yet public.]

## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | plot PI |
| William McShea |  | staff scientist, SCBI | plot PI |
| Erika Gonzalez-Akre | gonzalezeb | lab manager, SCBI | |
| Victoria Meakem |  | research assistant, SCBI |  |
| Ryan Helcoski | RHelcoski | research assistant, SCBI |  |
| Ian McGregor | mcgregorian1 | research assistant, SCBI |  |
| [MORE]| | | |
 
*refers to position at time of main contribution to this repository

[List does not yet include field assistants/ students/ volunteers who helped collect data]

## Funding 
- ForestGEO 

## Contact
Contact Erika Gonzalez-Akre for any inquiry on dendroband data collection at SCBI.

