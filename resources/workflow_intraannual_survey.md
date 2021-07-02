# Workflow for intraannual surveys

1. This assumes that a master [`scbi.dendroAll_YEAR.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) file for the year has already been created for the [spring biannual survey](https://github.com/SCBI-ForestGEO/Dendrobands/blob/update-workflows/resources/workflow_springbiannual_survey.md).
1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.
    1. Make the [`field_form_intrannual_YEAR.xlsx`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms) field_form_intrannual and [`data_entry_bianuual_sprYEAR.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms) data_entry forms following steps 1 and 2 of this [script](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/survey_forms/intraannual_survey.R)
    1. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).
2. Do survey
    1. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    1. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), calling it "data_entry_intraannual_[SURVEYID]".
    1. **BEFORE** merging with the master, push the data_entry_form to Github. This will allow us to compare any discrepancies in the future.
4. Merge the data_entry data to the master `scbi.dendroAll_YEAR.csv` file using step 3 of this [script](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/Rscripts/survey_forms/intraannual_survey.R).
    1. Fix any data issues that are found.
5. Once merged, delete the data_entry_form you made but keep the folder.
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.