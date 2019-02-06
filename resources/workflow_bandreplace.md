# Workflow for dendroband replacement and installation

1. Build dendrobands (see instructions [here](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/how_to_make_dendrobands.docx)).

2. Prepare the bandreplace form for the field, and make sure you have a blank data entry form ready for office.

    a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).

3. Do field work (see instructions above in Step 1 for exact steps).

    a. Double-check no tree is missed.
    
    b. While in field, remove dendrobands from dead trees that weren't removed in survey.
    
    c. Also, replace any tags that need replacing.

4. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.
    
    a. For dendroband replacements and installations, the survey.ID value depends on when the change is taking place.
    
    - if replacing/installing on a day of either intraannual or biannual survey, then the survey.ID is simply the same as that survey (2018.06 = 2018.06).
    
    - if replacing/installing is between intraannual survey dates, then use the survey.ID of the next chronological survey date (if 2018.06 < x < 2018.07, then use 2018.07).
    
    - if this is happening after the fall biannual survey, the number will be the number *after* that survey's. For example, if the fall survey was 2018.14, then any installation day between the end of the fall survey and the end of that calendar year would be given a survey.ID of 2018.15.
    
    - *not advised but sometimes unavoidable:* if replacing dead trees / fixing dendrobands is pushed into the next year before that year's spring biannual survey, then the survey.ID of all replacements should be the year itself (eg. only 2019). For example, in 2019 there were several days of replacements that were carried over from 2018. Even though these all had different dates, they all have the same survey.ID of 2019.

5. Save the form in the year folder within [resources](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), calling it "data_entry_bandreplace_[SURVEYID]".
    
    b. **BEFORE** merging with the master, push the data_entry_form and the new folder to Github. This will allow us to compare any discrepancies in the future.

6. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.
      
    a. Fix any data issues that are found.

7. Once merged, delete the data_entry_form you made.
 
8. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with any new records.

9. After the fall survey and after installing/replacing,
    
    a. Assign new dendroIDs and update [dendroID.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendroID.csv) with current dendroIDs and dendroband data.

    b. In addition, can update [dendro_trees_dbhcount](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/results/dendro_trees_dbhcount) using the Rscript.
    
    c. Update the maps for the biannual and intraannual surveys.
