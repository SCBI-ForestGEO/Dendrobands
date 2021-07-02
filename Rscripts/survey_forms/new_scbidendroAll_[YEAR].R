######################################################
# Purpose: Create new year's master file (scbi.dendroAll_[YEAR].csv)
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
######################################################


data_2020 <- read.csv("data/scbi.dendroAll_2020.csv")

#subset by the most recent survey and live trees
data_2021 <- subset(data_2020,survey.ID=="2020.06" & status=="alive")

cols <- c("survey.ID", "year", "month", "day", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")

data_2021[,cols] <- ""
data_2021$crown.condition <- NA
data_2021$crown.illum <- NA

write.csv(data_2021, "data/scbi.dendroAll_2021.csv", row.names=FALSE)


