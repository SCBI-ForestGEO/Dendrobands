# Dendroband number of surveys per Year

|Year| n.surveys| biannual.all |intraannual.all |biannual.live|intraannual.live|
|----|:--------:|:------------:|:--------------:|:-----------:|:--------------:|
|2010|    1     |     243      |      0         |     243     |       0        |
|2011|    23    |     505      |      105       |     505     |       105      |
|2012|    18    |     524      |      105       |     515     |       105      |
|2013|    16    |     579      |      155       |     566     |       150      |
|2014|    14    |     579      |      155       |     561     |       149      |
|2015|    13    |     579      |      155       |     554     |       149      |
|2016|    15    |     579      |      155       |     545     |       149      |
|2017|    12    |     579      |      155       |     542     |       148      |
|2018|    14    |     579      |      155       |     524     |       146      |

#### ".all" includes both live and dead trees
#### ".live" number of live trees in each year's spreadsheet

## Notes for certain years:

### 2010
2010 is the first year for which we have dendroband survey data. Trees were measured once in late January.

### 2011
2011 is the first year for which we have intraannual data for the dendrobands. The file is much bigger than later years due to how often measurements were recorded. Although the protocol calls for biweekly measurements, 2011 had a mixture of the following: 
- 2 measurements every week in May and early June, 
- 1 measurement every week in June, July, and early August, 
- 1 biweekly measurement in August, September, October, and November. 

For June-November, dendrobands were measured twice. The value in the csv file is taken from the archived excel sheet. Upon comparing the excel sheet measurement with the paper data, it is unclear why one measurement was used over another. 

In the raw (Archive) data, the final survey (2011.23) dates were not fully updated in data entry. Dates were assigned to be 12/15/2011 unless otherwise mentioned in the "notes" field.

### 2012
In 2012, some trees were added while others died. Overall number of trrees changed a little.

### 2013
2013 is the first year where the number of dendrobands matches what we see in recent years. 50 more trees were added to the intraannual and biannual survey as part of a sap flow cluster study, bringing the total trees to 155 (intraannual) and 579 (biannual), including dead. Because dead trees weren't removed from survey sheets until 2018, these numbers are the ones seen in the archive sheets for 2013- spring 2018. 

All the new trees were added in the middle of the growing season, thus for these 50 trees, records only begin at survey 2013.06. The one exception is 30339 (three stems), which was the only new tree measured distinctly in 2013.01.

### 2015
Although 2015 was the final year of the sap flow cluster study, the trees involved were kept in the dendroband surveys. There were comments in the archive data about changing some values (e.g. 40792 should be stem 2, not stem 1). These comments were applied when converting to new format.

### 2018
The fall biannual survey is comprised of three different measurement types. This was a mistake. All measurements should be taken in mm to two decimal points (e.g. 174.46 mm).
- Areas 3,4,7 were measured in mm to 0 decimal points (measured in cm in field)
- Areas 1,6,9 were measured in mm to 1 decimal point
- Areas 2,5,8 were measured in mm to 2 decimal points

The standardized format the data is in (with the field_forms, data_entry_forms, and subsequent Rscripts) was created in fall 2018, before and during the fall biannual survey. Surveys 2018.01 - 2018.12 were carried out in the original formats (see [archive](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/archive) folder), and copied into the new format later on.
