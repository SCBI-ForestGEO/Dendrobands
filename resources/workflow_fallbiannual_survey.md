# Workflow for fall dendroband biannual survey

1. Prepare data sheets for field, and make sure you have a blank data entry form ready for office.
    1. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).
2. Do survey
    1. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    1. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), calling it "data_entry_biannual_[SURVEYID]".
    1. **BEFORE** merging with the master, push the data_entry_form and the new folder to Github. This will allow us to compare any discrepancies in the future.
4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.
    1. Fix any data issues that are found.
5. Once merged, delete the data_entry_form you made but keep the folder.
6. Replace dead trees and fix bands that need fixing (this should happen soon after the last survey to allow time to settle before the next survey in spring).
    1.  When those are complete, then update [dendroID.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendroID.csv) to keep track of all dendroband changes in one place.
    1. In addition, can update [dendro_trees_dbhcount](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/results/dendro_trees_dbhcount) using the Rscript.
7. Then, create next year's master file.    
    1. When creating the next master file, remove all trees that have been labeled as dead within the current year (and validated with that year's mortality as in Step 4a).
8. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
    1. Then update [maps](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/maps) via the [script](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts).
