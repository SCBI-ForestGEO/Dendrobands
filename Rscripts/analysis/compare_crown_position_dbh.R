######################################################
# Purpose: compare canopy position with trees that are bigger/smaller than 35cm dbh, and to compare dbh by canopy position (dominant/codominant; intermediate/suppressed)
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created January 2019
######################################################
library(RCurl)

mort18 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/master/SCBI_mortality/data/mortality_2018.csv?token=AlsQkX-i6epvExyZODvtRjSxUqfr2mfXks5cvbFcwA%3D%3D"))

mortcanopy <- subset(mort18, mort18$crown.position==c("A","CD","CR","D","I","OG","S"))

library(data.table)
setnames(mortcanopy, old="StemTag", new="stemtag")

mortcanopy <- mortcanopy[ ,c("tag","stemtag","stemID","sp","dbh.2013","status.2018","dbh.if.dead","perc.crown","crown.position")]             

##merge biannual, crown assessment survey, and mortality data together
fullcanopy <- 

## split by dominant/codominant and intermediate/suppressed
domco <- subset(mortcanopy, mortcanopy$crown.position %in% c("D","CD"))
intsu <- subset(mortcanopy, mortcanopy$crown.position %in% c("I","S"))

## splt by above 35cm and below 35 cm dbh
large <- subset(mortcanopy, mortcanopy$dbh.2013 >= 350)
small <- subset(mortcanopy, mortcanopy$dbh.2013 <350)
