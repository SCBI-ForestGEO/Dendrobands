# README for data forms

## Structure

Each year has its own folder, with the main document in each being the data_YEAR.csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers. Global and local coordinates for trees are located in [tree_sp.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/tree_sp.csv).

- field_forms are created from the master list via an R-script, found [here](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/clean_data_files/2018/field_forms). These are created as .xlsx (excel) files to allow for retention of file manipulation for printing.

- data_entry_forms for the office are also pulled from the master via an R-script. This form is simplified to allow volunteers and those not familiar with dendroband survey methods to help enter data, if needed. Ideally, data should be entered directly after every survey.

- Final updates are run from another R-script, which merges the data_entry_forms into the data_YEAR.csv. These merges should be run as soon as the data has been entered.

