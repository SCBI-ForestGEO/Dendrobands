# SCBI Dendrometer bands

Note: Also relevant (for code, cross-site integration) is the [ForestGEO Dendro repository](https://github.com/forestgeo/dendro) (contact @maurolepore for access).

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
*Biannual dendrometer bands* - In 2010, 243 bands were initially installed, currently more than 515 stems of various DBH (5.5-152 cm) are being monitored (as October 2018). Protocols for band installations and remeasurement are published here ([original protocol](https://forestgeo.si.edu/sites/default/files/metal_band_dendrometer_protocol_done_1.pdf); [latest protocol](https://docs.google.com/document/d/1kCG22EAEnOVxw9Z-cPPvrHIzvRFE-j0U7anTmhJbkqM/edit)).

*Intra-annual dendrometer bands* - 
As of 2018, 155 stems of DBH ranging from 6-148 cm are monitored biweekly during the growing season each year.

*Workflow* 
- [field_forms](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms) and [data_entry_forms](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms) are pulled from the year's master file via R-scripts
- [maps](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/maps) are generated based on the [current list of trees with dendrobands](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv). 
- data recorded in the field are entered in [data_entry_forms](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms) and immediately merged into the current year's master file using an R script.

*Data organization* 

A dataset for each year of collection is found in the [data folder](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data). Each year has a master data set that includes both biannual and intra-annual surveys.

In the interest of keeping survey data entry simplified, each type of survey (biannual and intra-annual) has its own .csv for data entry for the current year. This is where the current year’s data will be entered during the growing season (March – November). When the growing season is finished and the November biannual survey is complete, data should be transferred to the scbi.dendroAll_YEAR.csv via joining/merging in R. 
1.	Metadata for these individual forms are consistent with the scbi.dendroAll_YEAR.csv [metadata](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/scbi.dendroALL_%5BYEAR%5D_metadata.csv) (the master).

## Tree data
A list of tree species by survey type, full counts of each species, and dbh min, max, and average is available [here](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/results/dendro_trees_dbhcount.csv).

Data on dendrometer band trees is available through the core census data, and we have collected a wide range of other potentially relevant data. Please see [this page](https://github.com/EcoClimLab/SCBI-ForestGEO-Data) for links to the data.

Geographic location of tree species by quadrat, lat/lon, and qualified by survey type and which trees have been measured is available in [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv).

## Data use

[Data are not yet public.]

## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | plot PI |
| William McShea |  | staff scientist, SCBI | plot PI |
| Erika Gonzalez-Akre | gonzalezeb | lab manager, SCBI | oversight of data collection |
| Victoria Meakem |  | research assistant, SCBI |  data collection |
| Ryan Helcoski | RHelcoski | research assistant, SCBI | data collection |
| Ian McGregor | mcgregorian1 | research assistant, SCBI | data collection, data organization, coding |
| [MORE]| | | |
 
*refers to position at time of main contribution to this repository

[List does not yet include field assistants/ students/ volunteers who helped collect data]

## Funding 
- ForestGEO 

## Contact
Contact Erika Gonzalez-Akre for any inquiry on dendroband data collection at SCBI.

