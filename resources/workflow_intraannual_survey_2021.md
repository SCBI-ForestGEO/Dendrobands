# (Work in progress) Workflow for 2021 intraannual surveys

1. Decide how you are going to record data in the field: Either
    1. As you did before: print out [`field_form_intraannual_2021-06.xlsx`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/field_forms/2021) field form (includes values from last intraannual survey), write values while in field, and then type into to the blank [`resources/raw_data/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/data_entry_intraannual.csv) raw data form
    1. Record directly to blank [`resources/raw_data/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/data_entry_intraannual.csv) using iPad
2. Do survey and double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. If you printed out `field_form_intraannual_2021-06.xlsx` field form, transfer data in the `data_entry_intraannual.csv` raw data form, ideally within the same day.
4. Rename the file to be `data_entry_intraannual_2021-XX.csv` where `XX` is the appropriate 0.01 increment in survey number. Note that the two digit suffix of the `survey.ID` variable in the spreadsheet should match `XX` e.g. `2021.XX`
5. Move `data_entry_intraannual_2021-XX.csv` to [`resources/raw_data/2021/`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/raw_data/2021), and push to GitHub
6. After you push this CSV, GitHub Actions should be triggered. Wait about 3 minutes at which point you'll get alerted by email to either:
    1. Pass ✅: All tests passed
    1. Fail ❌: At least one field fix error was found
7. If you receive a fail alert
    1. Go to [`testthat/reports/requires_field_fix`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/reports/requires_field_fix) to inspect the error alerts.
    1. Consult the [table of error alerts](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/README.md) to interpret what the errors mean.
    1. Fix all errors and push back to GitHub
7. Inspect all warnings: [`testthat/reports/warnings`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/testthat/reports/warnings) 
7. **Not sure about this one**: Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
