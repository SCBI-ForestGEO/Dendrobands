# README for data forms

Data form
- Headers of data pulled from Condit headers, added biannual and intraannual qualifiers

- Global and local coordinates for the trees are located in the tree_sp.csv.

Next steps:

- dbh in metadata is listed as the dbh when the dendroband is first measured/replaced, then calculated based on the growing trend of the intraannual surveys. The 2018 file only has the dbh listed as dbh 2013. Do we want this fixed?

- explain Dendrometer type in metadata. Is it a numeric measurement?





- write a script that will create a new sheet for each biannual census (one separate for March and November) pulling from the headers in the master_data.
- write a script that will also create the intraannual forms.
- right now we're saying that when surveyors find a measurement that varies by more than 3mm from the last survey, they should double check the measurement and indicate "double-checked" in the notes. We chose 3mm because it seemed like a good threshold. Did we want to re-calculate this number based on standard deviations of growth data over the past several years?
