# (Work in progress) Workflow for 2021 intraannual surveys

1. Decide how you are going to record data in the field: Either
    1. As you did before: print out [`field_form_intraannual_2021-06.xlsx`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/field_forms/2021) field form (includes values from last intraannual survey), write values while in field, and then type into to the blank [`resources/data_entry_forms/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/data_entry_forms/data_entry_intraannual.csv) data entry form
    1. Record directly to blank [`resources/data_entry_forms/data_entry_intraannual.csv`](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/data_entry_forms/data_entry_intraannual.csv) using iPad
2. Do survey and double-check no tree is missed. If so, go collect the data the same day or soon thereafter.
3. If you printed out `field_form_intraannual_2021-06.xlsx` field form, transfer data in the `data_entry_intraannual.csv` data entry form, ideally within the same day.
4. Rename the file to be `data_entry_intraannual_2021-03.csv`, move it to [`resources/data_entry_forms/2021/`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/resources/data_entry_forms/2021), and push to GitHub
5. After you push this CSV, GitHub Actions should be triggered. Wait about 3 minutes at which point you'll get alerted to either:
    1. Pass (green check): All tests passed
    1. Fail (red X): At least one test failed. At that point go to [`testthat/reports/`](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/testthat/reports) to inspect the error reports and see if you can interpret them. For those that you can fix, enter fixes in `data_entry_intraannual_2021-03.csv`
6. Update [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) with new records of dead trees.
