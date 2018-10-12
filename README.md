# SCBI Dendrometer bands

Note: Also relevant (for code, cross-site integration) is the [ForestGEO Dendro repository](https://github.com/forestgeo/dendro) (contact @maurolepore for access).

## Overview 
This repository contains dendrometer bands data for the SCBI ForestGEO plot. There are two sets of measurements: 

*Biannual dendrometer bands* - dendrometer bands on >500 trees measured at start and end of growing season

*Intra-annual dendrometer bands* - dendrometer bands on >150 trees measured ~ every 2 weeks

Active data is found the [data](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data) folder. The master_data.csv contains thorough data for both biannual and intraannual surveys.

[Data/biannual](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/biannual) contains
-	field form
-	species list
-	map of tree locations
-	the current year’s csv
- previous version of biannual master data (to archive at later stage)

[Data/intraanual](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/data/intraannual) contains
-	field form
-	species list
-	map of tree locations
-	the current year’s csv
- previous version of biannual master data (to archive at later stage)

In the interest of keeping survey data entry simplified, each type of survey (biannual and intraannual) has its own .csv for data entry for the current year. This is where the current year’s data will be entered during the growing season (March – November). When the growing season is finished and the November biannual survey is complete, data should be transferred to the master_data.csv via joining/merging in R. 
1.	Metadata for these individual forms are consistent with the metadata for the master_data.csv.

2. Metadata for both intraannual and biannual forms are found [here](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/fieldform_metadata.csv). Potentially fix this.

## Sampling location
[SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)


## Sampling period
*Biannual dendrometer bands* (measured at start and end of growing season): 2010 - present

*Intra-annual dendrometer bands* (measured ~ every 2 weeks): 2011 - present


## Protocols
*Biannual dendrometer bands* - In 2010, 243 bands were initially installed, with more than 500 stems of various DBH being monitored as April 2017. Protocols for band installations and remeasurement are published here ([original protocol](https://forestgeo.si.edu/sites/default/files/metal_band_dendrometer_protocol_done_1.pdf); [latest protocol](https://docs.google.com/document/d/1kCG22EAEnOVxw9Z-cPPvrHIzvRFE-j0U7anTmhJbkqM/edit)).

*Intra-annual dendrometer bands* - [fill in]


## Species
*Biannual dendrometer bands* 

| Species | Species code |
| ---- | ---- |
| Acer rubra |	acru |
| Carpinus caroliniana |	caca |
| Carya cordiformis |	caco |
| Carya glabra |	cagl |
| Carya ovalis |	caovl |
| Carya tomentosa |	cato |
| Cercis canadensis |	ceca |
| Cornus florida |	cofl |
| Fagus grandifolia |	fagr |
| Fraxinus americana |	fram |
| Juglans nigra |	juni |
| Liriodendron tulipifera |	litu |
| Nyssa sylvatica |	nysy |
| Pinus strobus |	pist |
| Platanus occidentalis |	ploc |
| Quercus alba |	qual |
| Quercus prinus |	qupr |
| Quercus rubra |	quru |
| Quercus velutina |	quve |
| Robinia pseudoacacia |	rops |
| Sassafras albidum |	saal |
| Tilia americana |	tiam |
| Ulmus rubra |	ulru |

*Intra-annual dendrometer bands*

| Species | Species code |
| --- | --- |
| Carpinus caroliniana | caca |
| Carya cordiformis | caco |
| Carya glabra | cagl |
| Cornus florida | cofl |
| Fagus grandifolia |fagr |
| Juglans nigra | juni |
| Liriodendron tulipifera | litu |
| Nyssa sylvatica |nysy |
| Quercus alba |qual |
| Quercus rubra |quru |
| Tilia americana |tiam |


## Tree data
Data on trees from which cores were taken is available through the core census data. Please see [this page](https://github.com/EcoClimLab/SCBI-ForestGEO-Data) for links to the data.

Geographic location of tree species by quadrat, lat/lon, and qualified by biannual survey, intraannual survey, and cored trees is available in [tree_sp.csv](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/metadata/tree_sp.csv).

## Data use

[Data are not yet public.]

## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | plot PI |
| William McShea |  | staff scientist, SCBI | plot PI |
| Erika Gonzalez-Akre | gonzalezeb | lab manager, SCBI | |
| Victoria Meakem |  | research assistant, SCBI |  |
| Ryan Helcoski | RHelcoski | research assistant, SCBI |  |
| [MORE]| | | |
 
*refers to position at time of main contribution to this repository

[List does not yet include field assistants/ students/ volunteers who helped collect data]

## Funding 
- ForestGEO 

## Contact
Contact Erika Gonzalez-Akre for any inquiry on dendroband data collection at SCBI.

