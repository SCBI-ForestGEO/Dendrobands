# Workflow for dendroband replacement and installation

1. Prepare the bandreplace form for the field, and make sure you have a blank data entry form ready for office.

    a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).

2. Do field work

    a. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
    
    b. While in field, remove dendrobands from dead trees that weren't removed in survey.
    
    c. Also, replace any tags that need replacing.

3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    
    a. For dendroband replacements and installations, the survey.ID value depends on when the change is taking place.
    
    - if replacing/installing on a day of either intraannual or biannual survey, then the survey.ID is simply the same as that survey.
    
    - if this is happening between two intraannual surveys, then the number will reflect this. For example, if replacing bands between 2018.06 and 2018.07, then the survey.ID should be 2018.061 (since adding a new dendroband involves collecting new data).
    
    - if this is happening after the fall biannual survey, the number will be the number *after* that survey's. For example, if the fall survey was 2018.14, then an installation day later would be given a survey.ID of 2018.15.

4. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), calling it "data_entry_bandreplace_[SURVEYID]".
    
    b. **BEFORE** merging with the master, push the data_entry_form and the new folder to Github. This will allow us to compare any discrepancies in the future.

4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.
      
    a. Fix any data issues that are found.

5. Once merged, delete the data_entry_form you made.
 
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with any new records.

7. After the fall survey,
    
    a. Update [dendroID_chronology](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendroID_chronology.csv) with current dendroIDs (as the full list is contingent on dendroband replacements)

    c. In addition, update [dendro_trees_dbhcount2018.csv](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/results) using the Rscript.
