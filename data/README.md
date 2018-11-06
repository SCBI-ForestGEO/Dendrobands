# Dendroband Data Overview

## metadata folder
Contains metadata for all files in this folder, excluding those in archive folder.

## [YEAR] folders

Each year has its own folder, with the main document in each being the scbi.dendroAll_[YEAR].csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers.

**Important**: The scbi.dendroAll_[YEAR] file is used in all field_form and data_entry Rscripts. If any major change is made (e.g. a column is added), then **_all_** the corresponding Rscripts need to be updated.

## `dendro_trees`

The relevant information in this file includes:
- all trees in dendroband surveys (including dead and those removed from survey)
- which trees are in the biannual survey
- which trees are in the intraannual survey
- which of the biannual/intraannual trees are cored
- the start and end date of dendroband measurements, plus year of mortality
- coordinates within quadrat, full plot
- geographic coordinates (NAD83 UTM and decimal degrees; this data comes from Merged_dendroband_utm_lat_lon.csv from the local V drive: V:/SIGEO/GIS_data/dendroband surveys

**Important**: dendro_trees is used to create [dendro_cored_full](https://github.com/SCBI-ForestGEO/tree-growth-and-productivity/tree/master/dendro_cored_full). Please make sure to update the Rscript if any major changes are made (add/delete columns, column names are modified, etc).

## `dendroID_chronology`

This file contains a chronology of dendroID values, by spring and fall of each year since dendroband measurements started in 2010. It was manually created in fall 2018 with the expectation that it can later be used for coding/other analyses. It is expected this will be updated with an Rscript after the main biannual surveys.

In the "2018.spring" column, dendroID numbers 782 and 799-829 were given new bands, but all were given the same ID as 782. This was only noticed when creating the file in Oct. 2018.
- This is noted because dendroID numbers 783-798 were assigned, but not labeled in the [original datasheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/original_data_files/Dendrometry_500Tree_most%20updated.xls) as having a new band.

## archive folder

Archived data pre-2018. 




