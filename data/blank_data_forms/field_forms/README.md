# README for field forms

If printing the first form for the season, please make sure the correct [R-script](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/clean_data_files/Rscripts) has been run from the master.

**Please review the [codes_metadata.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/codes_metadata.csv) _prior_ to surveying.**

Codes for the field form should be followed by the census#, to help with data entry later.
-	For example, if the tree is broken on census# 2018.08, then the code is B8.
- Remember to record if there is a discrepancy between the current measurement and the last measurement (see metadata).


## Notes on printing new field_forms (after creating .xlsx files from Rscripts)

1. add all borders, merge and center title across top, then left align

2. adjust cell dimensions as needed

3. change page margins to "narrow"

4. change orientation to "Landscape"

5. select and define print area as wanted (under "Page Layout")

6. Keep the headers on each print page. Go to "Print Titles," click in "Rows to repeat at top" and then select the title and headers on the sheet. Click ok. 

7. Select all the numbers, hover over the warning sign next to the selection, and select "Convert to Number." This is because in creating the file R converts everything to as.character

8. Filter by north/south (location). Then filter by ascending quadrat.

9. *Double check in print preview before printing!!*


## Checklist for collecting data
- datasheet (one of the field forms above)
- [code sheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/codes_metadata.csv)
- copy of [map](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/maps)
- calipers
- clipboard
- flagging tape
- pencils
- eraser
