# canopy positions

mort18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/SCBI_mortality/data/mortality_2018.csv")

mortcanopy <- subset(mort18, mort18$crown.position==c("A","CD","CR","D","I","OG","S"))

library(data.table)
setnames(mortcanopy, old="StemTag", new="stemtag")

mortcanopy <- mortcanopy[ ,c("tag","stemtag","stemID","sp","dbh.2013","status.2018","dbh.if.dead","perc.crown","crown.position")]                     
