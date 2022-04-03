# Main things to keep in mind:

1. `data/scbi.dendroAll_BLANK.csv` is a blank csv that contains all ~500 stems currently in our database. It should be kept up-to-date b/c the following csv's are constructed from it:
    a) The current year's master data csv `data/scbi.dendroAll_YEAR.csv`
    a) The next survey's data entry field form `resources/raw_data/YEAR/data_entry_*.csv`
1. Whenever there is a change in a band in a field fix form `resources/raw_data/YEAR/data_entry_fix_YEAR.csv`, these need to be manually incorporated in the next field form. Ex: `new.band = 1` or `codes = BA`
1. `dendroID.csv` needs to be manually updated
1. `dendro_trees.csv` needs to be manually updated



# What we did in early 2022

1. After fall biannual census `create_master_csv_2021_and_after.R` will create a blank master `scbi.dendroAll_2022.csv` file for next year
1. Identify which bands need to be replaced and new bands that need to be installed #89. Create an "action item" csv for Jess, who will then record these in `raw_data/2022/data_entry_fix_2022.csv`
    a) Because stem has died
    a) `code=RE`
    a) Measure is less than 3 or greater than 130 (caliper limits)
1. For new bands that are replacing dead stems, thoughtfully sample new stems #97
1. Using the information in `raw_data/2022/data_entry_fix_2022.csv`, update the following csv's #100
    a) Master `scbi.dendroAll_2022.csv`
        i. Removing dead stems
        i. Adding new stems that replaced previously dead ones
        i. Band replacements???
    a) `dendroID.csv` file #87 (Manually done for 2021 in PR #93)
    a) `dendro_trees.csv` file 
1. Create blank field form for next survey `raw-data/2022/data_entry_XXX.csv` #90 (done in PR #122) 



1. A lot of above is done manually by (#88)
    a) `fix_dendrobands.R`
    a) `replace_dead_trees_dendrobands.R`
1. Ensure fall to spring anomaly detection works #102 (done in PR #105)
1. Routine recomputations
    a) `dendrotrees_by_sp-survey-dbh.R` to output `results/dendro_trees_dbhcount/dendro_trees_sp_2021_min_max_mean_dbh.csv` #86 (done in #94)
    a)