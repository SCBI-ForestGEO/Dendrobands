# Data tests for SCBI dendro bands

## Table of tests 

level | category | applied to | test  | warning (W) or error (E) | coded | requires field fix? | auto fix (when applicable)
----  | ---- | ----  | ----  | ---- | ---- | ---- | ---- 
plot | completion check | all trees in census | `measure` is recorded for all bands. If `NA`, `codes` field should contain `RE`. |  E | 2021 | Y | NA 
plot | completion check | all trees in census | `status` is recorded for all bands ("alive" or "dead"). |  E | 2021 | Y | NA 
plot | consistency check | all trees in census | `status` = "alive" or "dead" |  E | 2021 | N | NA 
band | consistency check | all bands in census | `survey.ID` = "year.[census number]", where census number is 2 digits and is 0.01 greater than min(year, max value for `survey.ID` across all bands) | E | 2021 | N | ?
band | consistency check | all bands in census | `year` is possible: between 2010-current year & is not `NA` | E | 2021 | N | ?
band | consistency check | all bands in census | `year` matches current year | W | not yet | N | ?
band | consistency check | all bands in census | `month` is possible: 1 ≤ `month` ≤ 12 & is not `NA` | E | 2021 | N | ?
band | consistency check | all bands in census | `month` matches current month | W | not yet | N | ?
band | consistency check | all bands in census | `day` is possible: 1 ≤ `day` ≤ 31 for Jan, 1 ≤ `day` ≤ 29 for Feb, ..., & is not `NA` | E | 2021 | N | ?
band | consistency check | all bands in census | `day` matches current day | W | not yet | N | ?
band | consistency check | all bands in census | `measure` is possible: 0 ≤ `measure` <200 & is not `NA` | E | 2021 | Y | NA
band | consistency check | all bands in census | `measure` is reasonable: abs(`measure` - previous `measure`) < 10 (*to start. We'll refine this.*) | E | 2021 | Y | NA
band | consistency check | all bands in census | if `measure` is not between 3 & **near limit of calipers**, `codes` includes "RE" | W | 2021 | N | add "RE" to 
band | consistency check | all bands in census | all `codes` are defined, separated with `;` or `,` or `:` | E | 2021 | sometimes | NA


## not yet incorporated
- thorough review

