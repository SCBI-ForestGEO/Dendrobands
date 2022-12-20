# SCBI ForestGEO Dendrometer Field Forms

If printing the first form for the season, please make sure the correct [R-script](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts) has been run from the master.

**Please review the [codes_metadata.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/codes_metadata.csv) _prior_ to surveying.**

## Notes for field

**REMEMBER** 

1. Data is collected in mm to 2 decimals!! E.g. 74.89

2. *Important!* For both intraannual and biannual surveys, write the surveyID next to codes/notes. This way it will be easier to tell for data entry.
- e.g. a tree measured 4 times on a datasheet, and has codes F, F;RE (2019.04)

3. If a tree looks dead but the survey is being done before leaves are evident or after leaves have begun falling, put "check status, looks unhealthy" in notes. Then, cross-reference with mortality or other census during data entry.

4. In general, if a measurement is >6mm difference compared to the previous measurement, double check in field, then if need be write "check previous measure" in notes column.

### Timing 
5. For intraannual timing, depending on how fast you go (and how well the surveyors can navigate the plot), with two people it takes anywhere from 2-3 hours (1 person in north, 1 in south, ~150 trees). With one person, it takes just over 4 hours for the whole plot

5a. The intraannual survey is done every 2 weeks between the two biannual surveys, weather permitting.

6. The 2018 fall biannual (2018.14, 524 trees) survey took about 5 hours, with 7 people in 3 teams. The 2019 spring biannual (2019.01, 548 trees) was done in 9 hours with 2 teams of 2 people (1 half-day had only 2 people, one full day had all 4). With three teams, the areas are generally split up in this way:
- One team in Areas 1, 6, 9
- One team in Areas 2, 5, 8
- One team in Areas 3, 4, 7

6a. The biannual survey is done at the beginning of the growing season (March) and end of the growing season (October/early November), schedule permitting.



## Notes on printing new field_forms (after creating .xlsx files from Rscripts)

1. add all borders, merge and center title across top, then left align

2. adjust cell dimensions as needed
  
 -  2a. column titles for the Date, SID, and Name should be stacked (multiple lines). In excel, this is done with Alt+Enter.

3. change page margins to "narrow"

4. change orientation to "Landscape"

5. select and define print area as wanted (under "Page Layout").

6. Keep the headers on each print page. Go to "Print Titles," click in "Rows to repeat at top" and then select the title and headers on the sheet (rows 1 and 2). Click ok. 

7. Select all the numbers, hover over the warning sign next to the selection, and select "Convert to Number." This is because in creating the file R converts everything to as.character

8. Filter by ascending quadrat. Then filter by area [biannual] or location(N/S) [intraannual].

9. *Double check in print preview before printing!!*

10. *Optional:* Show page number to clarify how many trees are in each area. After filtering by everything above, in the print preview pane, select "Page Setup", then the "Header/Footer" tab. On the Header drop menu, select "Page 1 of ?" and it will appear centered. Click on "Custom Header", move the code in the center section and paste in the right section. Click ok.


## Checklist for collecting data
- datasheet (one of the field forms above)
- [code sheet](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/codes_metadata.csv)
- copy of [map](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/protocols_field-resources/maps)
- calipers
- clipboard
- flagging tape
- pencils
- eraser

### checklist for fixing/replacing bands
- everything in the first checklist above
- DBH pole and DBH tape
- replacement bands
- everything in green bag
  - small hole punchers (easier to leave the giant ones in office)
  - metal scissors
  - small metal sleeves (make more if need)
  - springs, large and small
  - sharpie (shouldn't need if replacement bands made but never know)
