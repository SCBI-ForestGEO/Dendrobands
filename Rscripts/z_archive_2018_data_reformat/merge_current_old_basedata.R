# script to copy over base data (survey qualification, stemID, and treeID from current data), for reorganizing pre-2018 data

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

dendro11 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2011.csv")

dendrotrees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")

dendro11$stemID <- dendrotrees$stemID[match(dendro11$tag, dendro_trees$tag)]

dendro11$treeID <- dendrotrees$treeID[match(dendro11$tag, dendro_trees$tag)]

write.csv(dendro11, "scbi.dendroAll_2011.csv", row.names=FALSE)

####################################################################
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

data_2017 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2017.csv")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

data_2017$intraannual <- data_2018$intraannual[match(data_2017$tag, data_2018$tag)]

data_2017$intraannual <- ifelse(is.na(data_2017$intraannual), 1, data_2017$intraannual)

data_2017$stemID <- data_2018$stemID[match(data_2017$tag, data_2018$tag)]

data_2017$treeID <- data_2018$treeID[match(data_2017$tag, data_2018$tag)]


data_2017$codes <- as.character(data_2017$codes)
data_2017$codes <- ifelse(is.na(data_2017$codes), "", data_2017$codes)


write.csv(data_2017, "scbi.dendroAll_2017.csv", row.names=FALSE)
