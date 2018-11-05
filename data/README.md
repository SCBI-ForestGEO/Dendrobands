# Dendroband Data Forms

scbi.dendroAll_2018 contains data for 530 live trees out of 579 trees.
Biannual survey 2018 = 530 trees
Intraannual survey 2018 = 155 trees

The full list of trees (579), including dead trees and those not included in current surveys, is catalogued in dendro_trees.

The scbi.dendroAll_[YEAR] file is used in all field_form and data_entry Rscripts. If any major change is made (e.g. a column is added), then **_all_** the corresponding Rscripts need to be updated.


## Structure

### blank_data_forms

Templates for filling out data in field (field_forms) and in office (data_entry_forms). Final updates to the master file for the year are run via R, which merges the data_entry_forms into the data_YEAR.csv. These merges should be run as soon as the data has been entered.

- field_forms are created from the master list via an R-script. These are created as .xlsx (excel) files to allow for retention of file manipulation for printing.

- data_entry_forms for the office are also pulled from the master via an R-script. This form is simplified to allow volunteers and those not familiar with dendroband survey methods to help enter data, if needed. Ideally, data should be entered directly after every survey.

### clean_data_forms

This folder includes current data, in the form of master files for each year, a list of tree species and coordinates, and a chronology of dendroIDs.

- Each year has its own folder, with the main document in each being the data_YEAR.csv, which is the master file for that year's intraannual and biannual surveys. Headers of the file are pulled from Condit along with some additional, relevant headers.

### metadata

Metadata for the different forms.

### original_data_files

Archived data pre-2018. 
