# Protocol for adding trees to dendroband survey

This is an explanation of Steps 2-6 in the code [field_form_replace_fix_dendrobands](https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/Rscripts/field_forms).

1. Take a list of dead trees from this year's survey.

2. Find the % ANPP contribution for each species, and get the top 6 species (ignoring litu because it is overrepresented).

3. Determine the number of individuals per these species that should be added. This was done by finding the % contribution of ANPP within the subset, then multiplying by the total number of trees that need to be replaced (in 2018, this was 66, accounting for dead trees 2013-2018).

4. Split the number of individuals evenly by size class (above 350mm dbh and below 350mm dbh).

5. Indicate which of these trees are going to be new trees for the intraannual survey, based on how many intraannual trees have died. Remember, all intraannual trees are biannual trees, so any new intraannual must be pulled from new biannual.

6. Determine the actual trees that will be added to survey. This was done by comparing the number of each individual by species (from step 4) with the most recent recensus data. New trees were generated from a random sample based on the subset of alive trees not already in the dendroband survey.