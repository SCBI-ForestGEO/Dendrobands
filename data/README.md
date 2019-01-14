# Dendroband Data Overview

## metadata folder
Contains [metadata](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/metadata) for all files in this folder, excluding those in archive folder.

## `scbi.dendroAll_[YEAR]` files

Each year has its own file labeled scbi.dendroAll_[YEAR].csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers.

**Important**: The scbi.dendroAll_[YEAR] file is used in all field_form and data_entry Rscripts. If any major change is made (e.g. a column is added), then **_all_** the corresponding Rscripts need to be updated.

Notes:

- Until end of 2018, dead trees were kept in the archive survey sheets even though no measurements were taken. In making these standardized files, dead trees have been removed from a year's survey sheet *only* if the tree was designated dead in previous years. If a tree was alive in fall of 2012 but then dead in 2013, for example, it is removed only from 2014 sheet onwards. (see "dendro_trees" for mortality years)

- Surveys from 2010-2017 have crown and illum values, but these are only valid for when the corresponding dendrobands were first installed. Data was not updated with later replacements. In the fall 2018 biannual survey (2018.14), these values were re-assessed and recorded.

- The "dbh" field differs by year:
    
      a. From 2010-2013, dbh is from 2008 ForestGEO census
    
      b. From 2014-2018, dbh is from 2013 ForestGEO census
    
      c. From 2019-____, dbh is from 2018 ForestGEO census


## `dendro_trees`

The relevant information in this file includes:
- all trees in dendroband surveys (including dead and those removed from survey)
- which trees are in the biannual survey
- which trees are in the intraannual survey
- which of the biannual/intraannual trees are cored
- the start and end date of dendroband measurements, plus year of mortality
- coordinates within quadrat, full plot
- geographic coordinates (NAD83 UTM and decimal degrees; this data comes from Merged_dendroband_utm_lat_lon.csv from the local V drive: V:/SIGEO/GIS_data/dendroband surveys

**Important**: dendro_trees is used to create [dendro_cored_full](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/tree_dimensions/tree_crowns/cored_dendroband_crown_position_data/dendro_cored_full.csv). Please make sure to update the Rscript if any major changes are made (add/delete columns, column names are modified, etc).

## `dendroID_chronology`

This file contains a chronology of dendroID values, by spring and fall of each year. It was manually created in fall 2018 with the expectation that it can later be used for coding/other analyses. It is expected this will be updated with an Rscript after the main biannual surveys. Remember, a "dendroId" is a unique numeric identifier for a dendroband, crucial for identifying when a dendroband has been replaced within a stem.


## archive folder

Archived data pre-2018. 




