# Data entry forms

The year folders (2011-2017) contain the data entry forms used to make the 2011-2017 master files in the new format. Since this is done, these can be deleted if need be.

The csv forms are to be used to enter data from the field. They should then update the year's master file via R-scripts once the full data from each survey is entered.

The intent is that these will immediately be integrated into the master via script and then deleted. All information will be transferred to the master, and field data sheets (paper, or scans thereof) will serve as the raw field data reference.

## Entering Data

**IMPORTANT: When entering biannual or intraannual data, filter by ascending quadrat _first_, and then by area to match the [field form](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/resources/field_forms/field_form_biannual.xlsx)!**

If you want to double check certain measurements in years past, the R code ["growth_over_time.R"](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts/analysis) has script that gives the measurements from all years per stemID. This can be helpful to see trends in measurements during the growing season and over winter.
- to find stemIDs, [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) is the best option.
- **REMEMBER** codes are entered without spaces, so if a tree is I, B, and needs a new band (RE), then it should be written "I;B;RE"
