# determine trees to fix dendrobands, and trees that need to replaced in the survey

dendro18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

#1 list to fix ####
fix <- dendro18[grep("RD", dendro18$codes), ]



#2 list to replace ####
dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")

dendrofull <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/cored_dendroband_crown_position_data/dendro_cored_full.csv")

dead <- dendro_trees[which(!(is.na(dendro_trees$mortality.year))), ]

dendrofull$dbhall <- pmax(dendrofull$dbh2008, dendrofull$dbh2013, dendrofull$dbh2018)

dead$dbhdead <- dendrofull$dbhall[match(dead$stemID, dendrofull$stemID)]

dead <- dead[, c(1:7,22,8:21)]

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
write.csv(dead, "dead_to_replace.csv", row.names=FALSE)



#3 determine composition of replacement species ####
ANPP <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/results/dendro_trees_ANPP.csv")
ANPP <- ANPP[with(ANPP, order(-ANPP.ANPP_Mg.C.ha1.y1_10cm)), ]

##find the % ANPP contribution for each species
ANPP$percent.totalANPP <- (ANPP$ANPP.ANPP_Mg.C.ha1.y1_10cm / sum(ANPP$ANPP.ANPP_Mg.C.ha1.y1_10cm))*100

##ignoring litu (over-represented), subset the top 6 species
ANPP <- ANPP[c(2:7), ]

##determine number of individuals to be replacements by finding the % contribution within the subset, then multiplying by the total number of trees that need to be replaced (66).
ANPP$n.replace <- (ANPP$percent.totalANPP / sum(ANPP$percent.totalANPP))*66
ANPP$n.replace <- round(ANPP$n.replace, digits=0)

##split evenly by size class
over.350 <- dead[dead$dbhdead > 350, ]
under.350 <- dead[dead$dbhdead <= 350, ]

