# README for data forms

### dendro_trees.csv includes the following information:

- what species of trees are present overall

- which of those trees are for the biannual survey, intraannual survey, or both

- which of these trees have been cored

- the local and global coordinates of these trees

- the UTM and lat/lon of each tree. These were obtained by merging this file with "scbi_stem_utm_lat_long.csv" found in V:\SIGEO\GIS_data\R-script_Convert local-global coord.

    a. For anyone trying to replicate this merge and using stem data from the 2013 ForestGEO survey, be aware that two trees (30365 [quad 308] and 131352 [quad 1316]) are not present due to mislabeling. This was caught in the 2018 census, and only appear in 2018 data going forward.

## dendroID_chronology

In the "2018.spring" column, dendroID numbers 782 and 799-829 were given new bands, but all were given the same ID as 782. This was only noticed when creating the file in Oct. 2018.
- This is noted because dendroID numbers 783-798 were assigned, but not labeled in the [original datasheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/original_data_files/Dendrometry_500Tree_most%20updated.xls) as having a new band.