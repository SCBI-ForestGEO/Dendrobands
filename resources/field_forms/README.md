# SIGEO Field Forms

If printing the first form for the season, please make sure the correct [R-script](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts) has been run from the master.

**Please review the [codes_metadata.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/codes_metadata.csv) _prior_ to surveying.**

Codes for the field form should be followed by the census#, to help with data entry later.
-	For example, if the tree is broken on census# 2018.08, then the code is B8.
- Remember to record if there is a discrepancy between the current measurement and the last measurement (see metadata).


## Notes on printing new field_forms (after creating .xlsx files from Rscripts)

1. add all borders, merge and center title across top, then left align

2. adjust cell dimensions as needed

3. change page margins to "narrow"

4. change orientation to "Landscape"

5. select and define print area as wanted (under "Page Layout"); this should be rows 1 and 2.

6. Keep the headers on each print page. Go to "Print Titles," click in "Rows to repeat at top" and then select the title and headers on the sheet. Click ok. 

7. Select all the numbers, hover over the warning sign next to the selection, and select "Convert to Number." This is because in creating the file R converts everything to as.character

8. Filter by area or location(N/S). Then filter by ascending quadrat.

9. *Double check in print preview before printing!!*

10. *Optional:* Show page number to clarify how many trees are in each area. After filtering by everything above, in the print preview pane, select "Page Steup", then the "Header/Footer" tab. On the Header drop menu, select "Page 1 of ?" and it will appear centered. Click on "Custom Header", copy the code in the center section and paste in the right section. Click ok.


## Checklist for collecting data
- datasheet (one of the field forms above)
- [code sheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/codes_metadata.csv)
- copy of [map](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/protocols_field-resources/maps)
- calipers
- clipboard
- flagging tape
- pencils
- eraser
