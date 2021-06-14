# Data tests for SCBI dendro bands

## Table of tests 

level | category | applied to | test  | warning (W) or error (E) | coded | requires field fix? | auto fix (when applicable)
----  | ---- | ----  | ----  | ---- | ---- | ---- | ---- 
plot | completion check | all trees in census | `measure` is recorded for all bands. If `NA`, `codes` field should contain `RE`. |  E | not yet | Y | NA 
plot | completion check | all trees in census | `status` is recorded for all bands ("alive" or "dead"). |  E | not yet | Y | NA 
plot | consistency check | all trees in census | `status` = "alive" or "dead" |  E | not yet | N | NA 
band | consistency check | all bands in census | `survey.ID` = "year.[census number]", where census number is 2 digits and is 0.01 greater than min(year, max value for `survey.ID` across all bands) | E | not yet | N | ?
band | consistency check | all bands in census | `year` is possible: (*fill in criteria*) | E | not yet | N | ?
band | consistency check | all bands in census | `year` matches current year | W | not yet | N | ?
band | consistency check | all bands in census | `month` is possible: 1 ≤ `month` ≤ 12 | E | not yet | N | ?
band | consistency check | all bands in census | `month` matches current month | W | not yet | N | ?
band | consistency check | all bands in census | `day` is possible: 1 ≤ `day` ≤ 31 | E | not yet | N | ?
band | consistency check | all bands in census | `day` matches current day | W | not yet | N | ?
band | consistency check | all bands in census | `measure` is possible: 0 ≤ `measure` <200 | E | not yet | Y | NA
band | consistency check | all bands in census | `measure` is reasonable: abs(`measure` - previous `measure`) < 10 (*to start. We'll refine this.*) | E | not yet | Y | NA
band | consistency check | all bands in census | if `measure` < 3, `codes` includes "RE" | W | not yet | N | add "RE" to codes
band | consistency check | all bands in census | if `measure` > (**near limit of calipers**), `codes` includes "RE" | W | not yet | N | add "RE" to codes



## not yet incorporated
- thorough review

