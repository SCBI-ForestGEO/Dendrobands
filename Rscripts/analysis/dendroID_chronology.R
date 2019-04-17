######################################################
# Purpose: update the dendroID.csv with new band information
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created March 2019
######################################################
#1. update dendroID.csv ####
#read in year's data
dendro2019 <- read.csv("data/scbi.dendroAll_2019.csv")

install <- read.csv("data/dendroID.csv")

#subset by new.band=1 and then subset by columns to match install
dendro2019 <- dendro2019[dendro2019$new.band==1, ]

dendro2019 <- dendro2019[ ,colnames(install) %in% c("tag", "stemtag", "sp", "quadrat", "stemID", "treeID", "biannual", "intraannual", "survey.ID", "dendDiam", "dbh", "new.band", "dendroID", "type", "dir", "dendHt", "crown.condition", "crown.illum", "lianas", "measureID")]

#append the rows to install
install_new <- rbind(dendro2019, install)
install_new <- install_new[order(install_new$tag, install_new$stemtag), ]

write.csv(install_new, "data/dendroID.csv", row.names=FALSE)

############################################################################################
#2. original code to make dendroID.csv / troubleshooting for all previous years ####
##this could have been easily done with a for-loop but it was easier doing separate

dendro2010 <- read.csv("data/scbi.dendroAll_2010.csv")

dendro2011 <- read.csv("data/scbi.dendroAll_2011.csv")

dendro2012 <- read.csv("data/scbi.dendroAll_2012.csv")

dendro2013 <- read.csv("data/scbi.dendroAll_2013.csv")

dendro2014 <- read.csv("data/scbi.dendroAll_2014.csv")

dendro2015 <- read.csv("data/scbi.dendroAll_2015.csv")

dendro2016 <- read.csv("data/scbi.dendroAll_2016.csv")

dendro2017 <- read.csv("data/scbi.dendroAll_2017.csv")

dendro2018 <- read.csv("data/scbi.dendroAll_2018.csv")

dendro2011 <- dendro2011[dendro2011$new.band==1, ]
dendro2012 <- dendro2012[dendro2012$new.band==1, ]
dendro2013 <- dendro2013[dendro2013$new.band==1, ]
dendro2014 <- dendro2014[dendro2014$new.band==1, ]
dendro2015 <- dendro2015[dendro2015$new.band==1, ]
dendro2016 <- dendro2016[dendro2016$new.band==1, ]
dendro2017 <- dendro2017[dendro2017$new.band==1, ]
dendro2018 <- dendro2018[dendro2018$new.band==1, ]

install <- rbind(dendro2010, dendro2011, dendro2012, dendro2013, dendro2014, dendro2015, dendro2016, dendro2017, dendro2018)

install <- install[ ,colnames(install) %in% c("tag", "stemtag", "sp", "quadrat", "stemID", "treeID", "biannual", "intraannual", "survey.ID", "dendDiam", "dbh", "new.band", "dendroID", "type", "dir", "dendHt", "crown.condition", "crown.illum", "lianas", "measureID")]

install <- install[order(install$tag, install$stemtag), ]

#dendro_trees <- read.csv("data/dendro_trees.csv")

#length(unique(install$stemID))
#length(unique(dendro_trees$stemID))
#setdiff(dendro_trees$stemID, install$stemID)

# write.csv(install, "data/dendroID.csv", row.names=FALSE)
