# README for data forms

## Structure

Each year has its own folder, with the main document in each being the data_YEAR.csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers. Global and local coordinates for trees are located in [tree_sp.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/tree_sp.csv).

- field_forms are created from the master list via an R-script, found [here](_________________)

- data_entry_forms for the office are also pulled from the master via an R-script. This form is simplified to allow volunteers and those not familiar with dendroband survey methods to help enter data, if needed. Ideally, data should be entered directly after every survey.

- Final updates are run from another R-script, which merges the data_entry_forms into the data_YEAR.csv. These merges should be run as soon as the data has been entered.



Next steps:

- make folder for R-scripts and update link above

- dbh in metadata is listed as the dbh when the dendroband is first measured/replaced, then calculated based on the growing trend of the intraannual surveys. The 2018 file only has the dbh listed as dbh 2013. Do we want this fixed?

- explain Dendrometer type in metadata. Is it a numeric measurement?

- right now we're saying that when surveyors find a measurement that varies by more than 3mm from the last survey, they should double check the measurement and indicate "double-checked" in the notes. We chose 3mm because it seemed like a good threshold. Did we want to re-calculate this number based on standard deviations of growth data over the past several years?
