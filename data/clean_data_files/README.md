# README for data forms

## dendroID_chronology

In the "2018.spring" column, dendroID numbers 782 and 799-829 were given new bands, but all were given the same ID as 782. This was only noticed when creating the file in Oct. 2018.
- This is noted because dendroID numbers 783-798 were assigned, but not labeled in the [original datasheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/original_data_files/Dendrometry_500Tree_most%20updated.xls) as having a new band.

## dendro_cored_full.csv includes the following information:

- what species of trees are present overall

- which of those trees are for the biannual survey, intraannual survey, or both

- which of these trees have been cored, plus all cored trees (2010-2011, 2016-2017)

- the local and global coordinates of these trees

- the UTM and lat/lon of each tree. These were obtained by merging this file with "scbi_stem_utm_lat_long.csv" found in V:\SIGEO\GIS_data\R-script_Convert local-global coord.

    a. For anyone trying to replicate this merge and using stem data from the 2013 ForestGEO survey, be aware that two trees (30365 [quad 308] and 131352 [quad 1316]) are not present in the 2013 census data due to mislabeling. This was caught in the 2018 census, and only appear in 2018 data going forward.

- the accompanying Rscript for creating this file is located [here](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/cored_trees.R). Files used to create this include
    1. [census_data_for_cored_trees](https://github.com/EcoClimLab/climate_sensitivity_cores/blob/master/data/census_data_for_cored_trees.csv)
    
    2. [dendro_trees](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/clean_data_files/dendro_trees.csv)
    
    3. Merged_dendroband_utm_lat_lon.csv from V drive: V:/SIGEO/GIS_data/dendroband surveys
    
    4. scbi.stem2.csv (2013 census data) from the V drive: V:/SIGEO/3-RECENSUS 2013/DATA/FINAL DATA to use, to share
    *- this should be updated to the 2018 census data as soon as the final file is available*
    
    5. [Mortality_Survey_2018](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/SCBI_mortality/raw%20data/Mortality_Survey_2018.csv)
    
## dendro_trees

This file contains a subset of dendro_cored_full, by only including the cored trees that coincide with the dendroband surveys (however, it does not have the year of coring).
- Important to note that this file was used to create dendro_cored_full

## dendro_trees_dbhcount

This file compares tree species by 
- type of dendroband survey and 
- dbh (min, max, and average)
- a full count of the number of trees in each survey is included

Script to create this is in the [Rscripts](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts) folder.

