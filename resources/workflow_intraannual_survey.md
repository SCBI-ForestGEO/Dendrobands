# Workflow for intraannual surveys

1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.

    a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).

2. Do survey

    a. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.

3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.

    a. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), calling it "data_entry_intraannual_[SURVEYID]".
    
    b. **BEFORE** merging with the master, push the data_entry_form to Github. This will allow us to compare any discrepancies in the future.

4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.

    a. Fix any data issues that are found.

5. Once merged, delete the data_entry_form you made but keep the folder.
    
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.