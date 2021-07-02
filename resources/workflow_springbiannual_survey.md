# Workflow for spring dendroband biannual survey

1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.
  - Make sure new master `scbi.dendroAll_YEAR` csv is made using this [script](Rscripts/survey_forms/new_scbidendroAll_[YEAR].R)
  - Then make field_form_biannual plus data_entry form
   a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).
2. Do survey
    a. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    a. Create a new folder for the current year, and save the data_entry_form there, calling it "data_entry_biannual_[SURVEYID]".
    b. **BEFORE** merging with the master, push the data_entry_form and the new folder to Github. This will allow us to compare any discrepancies in the future.
4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.
    a. Compare any notes of "dead" trees with the previous year's [mortality census](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_mortality/data).
        i. In general, we want to use the mortality census as the basis for what is live or dead, as it's completed during the growing season.
        ii. Trees labeled as dead during the biannual survey may look dead due to the lack of leaves, depending on leaf senescence and recruitment timing.
    b. Fix any data issues that are found.
5. Delete the data_entry_form you created but keep the folder you made in Step 3a.
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
