setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

install <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/installation_data.csv")

install_df <- install[rep(row.names(install), 18), 1:ncol(install)]
install_df <- install_df[order(install_df$tag), ]
install_df$season <- ""
install_df$status <- ""
install_df <- install_df[, c(1:9, 21, 10:20)]

install_df$year <- 2010:2018
install_df <- install_df[order(install_df$tag, install_df$year), ]

install_df$season <- c("spring", "fall")


dendro2010 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2010.csv")

dendro2011 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2011.csv")

dendro2012$dendroID <- ifelse(dendro2012$new.band==0, dendro2011$dendroID, dendro2012$dendroID)

dendro2011 <- dendro2011[dendro2011$new.band==1, ]

install <- rbind(dendro2010, dendro2011)

install <- install[ ,colnames(install) %in% c("tag", "stemtag", "sp", "quadrat", "stemID", "treeID", "biannual", "intraannual", "survey.ID", "dendDiam", "dbh", "new.band", "dendroID", "type", "dir", "dendHt", "crown.condition", "crown.illum", "lianas", "measureID")]

install <- install[order(install$tag, install$stemtag), ]
install <- install[, c(1,2,4:9,3,10:20)]
