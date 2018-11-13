# Workflow for dendroband biannual survey

1. Prepare data sheets for field (and make sure you have blank data entry form for office)

a. Review [checklist](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms).

2. Do survey

a. Double-check no tree was missed. If so, go collect the measurement the same day or soon thereafter

3. Enter data in the [data_entry_form](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms), ideally within the same day

4. Merge to the [master file](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) for that year

a. Compare any notes of "dead" with that year's [mortality census](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/SCBI_mortality/data)

  i. In general we want to use the mortality census as the basis for what is live and dead, as it's completed during the summer.

  ii. Trees labeled as dead during the biannual survey may look dead due to the loss of leaves, depending on leaf senescence timing

b. Fix any data issues that are found

5. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees

6. Create next year's master file...

  a. ...only AFTER doing dendroband replacements and gathering the data for those

  b. When those are complete, then update [dendroID_chronology](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendroID_chronology.csv) with current dendroIDs (as the full list is contingent on dendroband replacements)
                                                               