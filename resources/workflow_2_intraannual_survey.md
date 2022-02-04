# Workflow for intraannual surveys

1. Prepare raw-data form to record data in the field.
    1. This file should have been automatically created in `resources/raw_data/YEAR/data_entry_intraannual_YEAR-XX_BLANK.csv` where `XX` is the next survey number
    1. Either print this form or load onto iPad
1. Conduct survey
    1. `codes` column should be based on these [codes](data/metadata/codes_metadata.csv) 
1. Prepare data for GitHub
    1. Rename the raw-data form to `data_entry_intraannual_YEAR-XX.csv` i.e. remove the `_BLANK`
    1. If you printed out form, transfer values to raw-data form
    1. Fill in any remaining columns e.g. `month`, `day`, `field.recorders`, `data.enter`
1. Commit and push `data_entry_intraannual_YEAR-XX.csv`. This will trigger GitHub Actions continuous integration.
1. On the GitHub Actions [workflows page](https://github.com/SCBI-ForestGEO/Dendrobands/actions), you'll see your commit with either
    1. Running 🟡: Code is still running. If so, wait for code to finish running, typically 3 minutes.
    1. Pass ✅: All code successfully ran and no data collection errors were found.
    1. Fail ❌: Either code didn't successfully run or a data collection error was found.
1. If you receive a fail ❌ alert
    1. Click on the commit message, then click on QA_QC_checks
    1. If there is a ❌ alert next to "Are there any data collection errors?", that means there was a data collection error that you'll need to fix.
    1. If there is a ❌ alert anywhere else, that means there was a code error. Contact whoever is the repository code technician for assistance.
1. If there were any data collection errors, fix them:
    1. Go to [`testthat/reports/requires_field_fix`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/reports/requires_field_fix) to inspect the error alerts; an index of what the errors mean can be found in this [table](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/README.md) to interpret what the errors mean.
    1. If there are any anomalous measurements on the repository [README](https://github.com/SCBI-ForestGEO/Dendrobands#anomalous-measurement-report), then
        1. Go back into the field and verify this measurement
        1. If the measure was indeed an anomaly, in `data_entry_intraannual_YEAR-XX.csv`, update the date of the measurement and the measurement. If not, then leave entries as is.
        1. In either case, set the `measure_verified` variable to `TRUE`. This will inform the continuous integration systems that this measurement has been double checked.
    1. Commit and push `data_entry_intraannual_YEAR-XX.csv` again
1. **Not sure about this one**: Inspect all warnings: [`testthat/reports/warnings`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/reports/warnings)
1. **Not sure about this one**: Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.



# DEPRECATED: Workflow for intraannual surveys (prior to 2021)

1. Prepare data sheets for field, and make sure you have a blank raw data form ready for office.
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
