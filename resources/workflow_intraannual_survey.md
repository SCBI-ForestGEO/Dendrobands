# Workflow for intraannual surveys

1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.
    1. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).
2. Do survey
    1. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. Enter data in the [raw data form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/raw_data), ideally within the same day.
    1. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/raw_data), calling it "data_entry_intraannual_[SURVEYID]".
    1. **BEFORE** merging with the master, push the raw data form to Github. This will allow us to compare any discrepancies in the future.
4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.
    1. Fix any data issues that are found.
5. Once merged, delete the raw data you made but keep the folder.
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.