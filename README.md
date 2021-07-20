# SCBI Dendrometer bands

## Dashboard

### data entry issues to resolve?
[![data-tests](https://github.com/SCBI-ForestGEO/Dendrobands/workflows/data-tests/badge.svg)](https://github.com/SCBI-ForestGEO/Dendrobands/tree/main/testthat/reports)

**[Click here to view error reports.](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/testthat/reports)**

### warnings? 
*These do not cause the tests to fail, but may indicate problems and should be reviewed.*

[![There_is_no_warnings_:-)](https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/testthat/reports/warnings.png)](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/testthat/reports/warnings)



## Overview 

This repository contains dendrometer bands data for the SCBI ForestGEO plot. There are two sets of measurements: 

*Biannual dendrometer bands* - dendrometer bands on >500 trees measured at start and end of growing season

*Intra-annual dendrometer bands* - dendrometer bands on >150 trees measured ~ every 2 weeks


## Sampling location
[SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)


## Sampling period
*Biannual dendrometer bands* (measured at start and end of growing season): 2010 - present

*Intra-annual dendrometer bands* (measured ~ every 2 weeks during growing season): 2011 - present


## Protocols and data management
*Biannual dendrometer bands* - In 2010, 243 bands were initially installed, additional bands were installed in 2011 and currently more than 515 stems of various DBH (5.5-152 cm) are being monitored. Protocols for band installations and remeasurement are published here ([original protocol](https://forestgeo.si.edu/sites/default/files/metal_band_dendrometer_protocol_done_1.pdf); [latest protocol](https://docs.google.com/document/d/1kCG22EAEnOVxw9Z-cPPvrHIzvRFE-j0U7anTmhJbkqM/edit)).

*Intra-annual dendrometer bands* - 
Since 2011, ~155 stems of DBH ranging from 6-148 cm are monitored biweekly during the growing season each year.

*Workflow* 
- [field_forms](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms) and [raw_data](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/raw_data) are pulled from the year's master file via R-scripts
- [maps](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/maps) are generated based on the [current list of trees with dendrobands](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv). 
- data recorded in the field are entered in [raw_data](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/raw_data) and immediately merged into the current year's master file using an R script.

*Data organization* 

A dataset for each year of collection is found in the [data folder](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data). Each year has a master data set that includes both biannual and intra-annual surveys (with a file name format "scbi.dendroAll_YEAR.csv")

In the interest of keeping survey data entry simplified, each type of survey (biannual and intra-annual) has its own .csv for data entry for the current year. This is where the current year’s data will be entered during the growing season (March – November). When the growing season is finished and the November biannual survey is complete, data should be transferred to the scbi.dendroAll_YEAR.csv via joining/merging in R. 
1.	Metadata for these individual forms are consistent with the scbi.dendroAll_YEAR.csv [metadata](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/scbi.dendroALL_%5BYEAR%5D_metadata.csv) (the master).

## Tree data for dendro trees
A summary of tree species by survey type per year (ie. dbh range) are available [here](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/results/dendro_trees_dbhcount).

Some relevant data on dendrometer banded trees (geographic location, date started/end, mortalitity year, etc) is available here [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv).

## Data use

[Data are not yet public.]


Note: Also relevant (for code, cross-site integration) is the [ForestGEO Dendro repository](https://github.com/forestgeo/dendro).

## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | plot PI |
| William McShea |  | staff scientist, SCBI | plot PI |
| Erika Gonzalez-Akre | gonzalezeb | lab manager, SCBI | oversight of data collection |
| Victoria Meakem |  | research assistant, SCBI |  data collection |
| Ryan Helcoski | RHelcoski | research assistant, SCBI | data collection |
| Ian McGregor | mcgregorian1 | research assistant, SCBI | data collection, data organization, coding |
| Alyssa Terrell | terrella3 | research assistant, SCBI | data collection, data organization, coding |
| [MORE]| | | |
 
*refers to position at time of main contribution to this repository

[List does not yet include field assistants/ students/ volunteers who helped collect data]

## Funding 
- ForestGEO 

## Contact
Contact Erika Gonzalez-Akre for any inquiry on dendroband data collection at SCBI.

