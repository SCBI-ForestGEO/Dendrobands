# SCBI Dendroband Maps

The maps here contain plotted trees across the ForestGEO plot for the intraannual survey and the biannual survey. They should be updated at least once per year to account for any tree removals or additions for the survey.

These maps are meant to be helpful guides in the field for all surveys.

Numbered areas on the biannual map have been used as survey areas since 2012, as they were drawn by Gonzalez-Akre. In 2018 these were converted to a GIS map, and in 2019 they were converted to an Rscript. In the updated [biannual_field_form.xlsx](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/protocols_field-resources/field_forms/field_form_biannual.xlsx) as of Oct. 2018, these survey areas were coded to be a separate column by which surveyors can filter for easier data collecting.


## Editing

We are using [dendro_trees.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv) to provide the data for these maps as opposed to "scbi.dendroAll_YEAR.csv" because 

1. dendro_trees reflects the data in the all of the YEAR files and

2. dendro_trees has the necessary mapping information in lx/ly, gx/gy, NAD83X/Y, AND lat/lon in decimal degrees.

The code for making the biannual and intraannual maps is found at [survey_maps](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts).
- This code only looks at live trees (since we survey only live trees).

The ArcGIS maps are here for reference, but are also fully usable and are linked to the shapefiles in this repo and in SCBI-ForestGEO-Data (link below).

## shapefiles

There are 2 categories of shapefiles.
- in this repo, there are those specifically relevant for dendroband maps
    - the N/S divide for intraannual survey
    - sample pathways to take when doing intraannual survey. These are based on the fastest distance to all trees (from 2019) based on elevation. The shapefiles were created with the ArcGIS map using the "freehand" drawing application in the "Draw" toolbar.
    - smaller survey areas for the biannual survey
- other general plot shapefiles (roads, streams, deer exclosure, gridded plot, and contour) are found in [SCBI-ForestGEO-Data](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data).
- all of these are used in the Rscript
