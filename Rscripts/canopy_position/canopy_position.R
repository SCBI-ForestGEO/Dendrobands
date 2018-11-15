# canopy positions

mort18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/SCBI_mortality/data/mortality_2018.csv")

mortcanopy <- subset(mort18, mort18$crown.position==c("A","CD","CR","D","I","OG","S"))

library(data.table)
setnames(mortcanopy, old="StemTag", new="stemtag")

mortcanopy <- mortcanopy[ ,c("tag","stemtag","stemID","sp","dbh.2013","status.2018","dbh.if.dead","perc.crown","crown.position")]             

##merge biannual, survey, and mortality data together
fullcanopy <- 

## split by dominant/codominant and intermediate/suppressed
domco <- subset(mortcanopy, mortcanopy$crown.position %in% c("D","CD"))
intsu <- subset(mortcanopy, mortcanopy$crown.position %in% c("I","S"))

## splt by above 35cm and below 35 cm dbh
large <- subset(mortcanopy, mortcanopy$dbh.2013 >= 350)
small <- subset(mortcanopy, mortcanopy$dbh.2013 <350)
