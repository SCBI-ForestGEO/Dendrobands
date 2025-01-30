# Script that takes "cleaned" version of data ready for analysis in
# data/scbi.dendroAll_YEAR.csv and checks for warnings listed in
# testthat/README.md.
#
# 
# Developed by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - First created in 2021
#
# 🔥HOT TIP🔥 Get a bird's eye view of what this code is doing by
# turning on "code folding" by going to RStudio menu -> Edit -> Folding
# -> Collapse all

# Set up ----
# Clear environment
rm(list = ls())

# Load libraries 
# library(here)

# Load existing warnings
warning_file_path <- file.path("testthat", "reports/warnings/warnings_file.csv")
if(file.exists(warning_file_path)) {
  warning_file <- read.csv(warning_file_path)
}

# write warning messages
warning_messages <- c(
  "dendroband_needs_fixing_or_replacing" = "There are dendrobands that need replacing."
)

# Check if files exist and generate a plot with the warning ####

if(file.exists(warning_file_path)){
  all_warns <- paste(c("WARNINGS!!!\n", warning_messages[unique(warning_file$alert_name)], "\nCLICK HERE TO GO TO FOLDER"), collapse = "\n") 
} else{
  all_warns = "No WARNINGS"
}


filename <- file.path("testthat", "reports/warnings.png")
if(length(all_warns) == 0)
  file.remove(filename)

png(filename, width = 3, height = 1.5, units = "in", res = 300)
par(mar = c(0,0,0,0))
plot(0, 0, axes = F, xlab = "", ylab = "", type = "n")
text(0, 0.2, all_warns, col = "red", cex = 0.6)
dev.off()


