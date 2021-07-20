library(here)
library(testthat)

test_that("There are errors that require field fix", {
  
  report_exists <- file.exists(file.path(here("testthat"), "reports/requires_field_fix/require_field_fix_error_file.csv"))
  
  expect_false(report_exists)
})
