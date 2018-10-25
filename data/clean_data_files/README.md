# README for data forms

## Structure

Each year has its own folder, with the main document in each being the data_YEAR.csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers.

- field_forms are created from the master list via an R-script, found [here](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/clean_data_files/2018/field_forms). These are created as .xlsx (excel) files to allow for retention of file manipulation for printing.

- data_entry_forms for the office are also pulled from the master via an R-script. This form is simplified to allow volunteers and those not familiar with dendroband survey methods to help enter data, if needed. Ideally, data should be entered directly after every survey.

- Final updates are run from another R-script, which merges the data_entry_forms into the data_YEAR.csv. These merges should be run as soon as the data has been entered.


### dendro_trees.csv includes the following information:

- what species of trees are present overall

- which of those trees are for the biannual survey, intraannual survey, or both

- which of these trees have been cored

- the local and global coordinates of these trees

- the UTM and lat/lon of each tree. These were obtained by merging this file with "scbi_stem_utm_lat_long.csv" found in V:\SIGEO\GIS_data\R-script_Convert local-global coord.

    a. For anyone trying to replicate this merge and using stem data from the 2013 ForestGEO survey, be aware that two trees (30365 [quad 308] and 131352 [quad 1316]) are not present due to mislabeling. This was caught in the 2018 census, and only appear in 2018 data going forward.
