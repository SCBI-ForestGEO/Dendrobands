# Workflow for intraannual surveys (2021 and after)

1. Decide how you are going to record data in the field: Either
    1. As you did before: print out [`field_form_intraannual_2021-06.xlsx`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/field_forms/2021) field form (includes values from last intraannual survey), write values while in field, and then type into to the blank [`resources/raw_data/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/data_entry_intraannual.csv) raw data form
    1. Record directly to blank [`resources/raw_data/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/data_entry_intraannual.csv) using iPad
1. Do survey
1. If you printed out `field_form_intraannual_2021-06.xlsx` field form, transfer data in the `data_entry_intraannual.csv` raw data form, ideally within the same day.
1. Rename the file to be `data_entry_intraannual_2021-XX.csv` where `XX` is the appropriate 0.01 increment in survey number. Note that the two digit suffix of the `survey.ID` variable in the spreadsheet should match `XX` e.g. `2021.XX`
1. Commit and push `data_entry_intraannual_2021-XX.csv` to [`resources/raw_data/2021/`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/2021) GitHub folder. This will trigger GitHub Actions continuous integration.
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
        1. If the measure was indeed an anomaly, in `data_entry_intraannual_2021-XX.csv`, update the date of the measurement and the measurement. If not, then leave entries as is.
        1. In either case, set the `measure_verified` variable to `TRUE`. This will inform the continuous integration systems that this measurement has been double checked.
    1. Commit and push `data_entry_intraannual_2021-XX.csv` again
1. **Not sure about this one**: Inspect all warnings: [`testthat/reports/warnings`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/reports/warnings)
1. **Not sure about this one**: Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
