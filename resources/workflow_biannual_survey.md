# Workflow for dendroband biannual survey

1. Prepare data sheets for field, and make sure you have a blank data entry form for office.

    a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).

2. Do survey

    a. Double-check no tree is missed. If so, go collect the data the same day or soon thereafter.

3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day.

4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year.

    a. Compare any notes of "dead" trees with that year's [mortality census](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/SCBI_mortality/data).
    
        i. In general, we want to use the mortality census as the basis for what is live or dead, as it's completed during the growing season.
      
        ii. Trees labeled as dead during the biannual survey may look dead due to the lack of leaves, depending on leaf senscence and recruitment timing.
      
    b. Fix any data issues that are found.
    
5. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.

6. After the fall survey, create next year's master file...

    a....only after doing dendroband replacements and gathering that data
    
    b. When those are complete, then update [dendroID_chronology](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendroID_chronology.csv) with current dendroIDs (as the full list is ontingent on dendroband replacements)

    c. In addition, update [dendro_trees_dbhcount.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/results/dendro_trees_dbhcount.csv) using the Rscript.
