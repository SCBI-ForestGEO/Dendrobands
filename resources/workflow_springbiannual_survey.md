# Workflow for spring dendroband biannual survey

1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.
    1. Make sure a new master [`scbi.dendroAll_YEAR.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) is made using this [script](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/survey_forms/new_scbidendroAll_%5BYEAR%5D.R)
    1. Then make [field_form_biannual](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms) plus [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms) following steps 1 and 2 of this [script](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/survey_forms/intraannual_survey.R)
    1. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).
2. Do survey
    1. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    1. Create a new folder for the current year, and save the data_entry_form there, calling it "data_entry_biannual_[SURVEYID]".
    1. **BEFORE** merging with the master, push the data_entry_form and the new folder to Github. This will allow us to compare any discrepancies in the future.
4. Merge to the master [`scbi.dendroAll_YEAR.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) using step 3 of this [script](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/survey_forms/intraannual_survey.R).
    1. Compare any notes of "dead" trees with the previous year's [mortality census](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_mortality/data).
        i. In general, we want to use the mortality census as the basis for what is live or dead, as it's completed during the growing season.
        ii. Trees labeled as dead during the biannual survey may look dead due to the lack of leaves, depending on leaf senescence and recruitment timing.
    1. Fix any data issues that are found.
5. Delete the data_entry_form you created but keep the folder you made in Step 3a.
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
