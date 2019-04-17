######################################################
# Purpose: Determine which trees should replace the dead trees in the dendroband surveys. Create field forms, create data_entry forms, merge to master
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created November 2018
######################################################
##each step here uses data from previous steps

#1 quick check of the number of trees to be replaced
#2 list of dead trees that need to be replaced
#3 determine composition of replacement species
#4 determine the actual trees to be the replacements
#5 get local and global coordinates for those trees
#6 Create field and data_entry forms
#7 merge data_entry form to year file
#8 merge data_entry form with dendro_trees and dendroID

dendro18 <- read.csv("data/scbi.dendroAll_2018.csv")

#1 quick check of number of trees that need to be replaced ####
q <- dendro18[which(dendro18$survey.ID==c('2018.14')), ] 
length(c(grep("dead", q$status)))
rm(q)

#############################################################################
#2 list of dead trees that need to be replaced ####
library(httr)
library(RCurl)

dendro_trees <- read.csv("data/dendro_trees.csv")

dendrofull <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_dimensions/tree_crowns/cored_dendroband_crown_position_data/dendro_cored_full.csv"))

dead <- dendro_trees[which(!(is.na(dendro_trees$mortality.year))), ]

dendrofull$dbhall <- pmax(dendrofull$dbh2008, dendrofull$dbh2013, dendrofull$dbh2018)

dead$dbhdead <- dendrofull$dbhall[match(dead$stemID, dendrofull$stemID)]

dead <- dead[, c(1:7,23,8:22)]

write.csv(dead, "data/dead_to_replace_2018.csv", row.names=FALSE)



#############################################################################
#3 determine composition of replacement species

#3a. determine composition based on ANPP contribution ####
ANPP <- read.csv("results/dendro_trees_ANPP.csv")
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
ANPP$under.350 <- c(2,2,2,1,1,1) #9 replacements under 350 dbh
ANPP$over.350 <- ANPP$n.replace - ANPP$under.350

replace <- ANPP[, c(1:4, 9:12)]

##double check the variety of dead intraannual
q <- dead[dead$intraannual ==1 & dead$dbhdead<=350, ]
length(q$dbhdead) #=1, so intra dead over 350 =8.
rm(q)

##represent the range of intraannual. Remember, all intraannual trees are biannual trees, so any new intra must be pulled from new biannual.
##this arrangement can be changed if we want to have other species.
replace$is.intraannual.u350 <- c(0,1,0,0,0,0)
replace$is.intraannual.o350 <- c(3,2,2,0,0,1)

replace <- replace[, c(1:7,9,8,10)]

#3b. determine composition based on species ####
ANPP <- read.csv("results/dendro_trees_ANPP.csv")
ANPP <- ANPP[with(ANPP, order(-ANPP.ANPP_Mg.C.ha1.y1_10cm)), ]

#subset to exclude litu (over-represented) and fram (all dying soon from pest)
ANPP <- ANPP[!(ANPP$sp %in% c("litu", "fram")), ]

#when Krista gets back to me, finish this part of code. potentially this can be another way of determining which species to add

#############################################################################
#4 determine the actual trees to replace

#4a. determine trees from ANPP contribution (from 3a) ####
recensus2018 <- read.csv("")
recensus2018$DBH <- recensus2018$DBH*10
library(data.table)
recensus2018 <- setnames(recensus2018, old=c("Tag", "StemTag", "QuadratName", "Mnemonic", "DBH","Codes"),new=c("tag", "stemtag", "quadrat", "sp", "dbh18", "codes"))

recensus2018$codes <- as.character(recensus2018$codes)
replace$sp <- as.character(replace$sp)
sp <- c(replace$sp) #list of species for replacement trees
n.o350 <- c(replace$over.350)
n.u350 <- c(replace$under.350)

dendrobands <- c(dendro_trees$tag) #trees that are already in dendroband survey

##subset by trees not already in dendrobands, by our target species, by alive trees over 350 dbh
trees.o350 <- subset(recensus2018, !(recensus2018$tag %in% dendrobands) & (recensus2018$sp %in% sp) & !(grepl("D", recensus2018$codes)) & (recensus2018$dbh18 > 350))

#same for under 350 but above 100 (based on range(under.350$dbhdead))
trees.u350 <- subset(recensus2018, !(recensus2018$tag %in% dendrobands) & (recensus2018$sp %in% sp) & !(grepl("D", recensus2018$codes)) & (recensus2018$dbh18 <= 350) & (recensus2018$dbh18 >100))

##this nest loop says: for each replacement sp and the number of trees, generate random trees based on DBH values. The duplicated function is there because it sometimes includes duplicate tags, so be cautious for the number within the output df
test.o350 <- NULL
for (i in seq(along=sp)){
  for (j in seq(along=n.o350)){
    if(i==j){
      species <- sp[[i]]
      number <- n.o350[[j]]
      
      species <- subset(trees.o350, trees.o350$sp %in% species)
      species <- species[species$dbh18 %in% c(sample(species$dbh18, number)), ]
      species <- species[!duplicated(species$dbh18), ]
      
      test.o350 <- rbind(test.o350,species)
    }
  }
}

##same thing for u350
test.u350 <- NULL
for (i in seq(along=sp)){
  for (j in seq(along=n.u350)){
    if(i==j){
      species <- sp[[i]]
      number <- n.u350[[j]]
      
      species <- subset(trees.u350, trees.u350$sp %in% species)
      species <- species[species$dbh18 %in% c(sample(species$dbh18, number)), ]
      species <- species[!duplicated(species$dbh18), ]
      
      test.u350 <- rbind(test.u350,species)
    }
  }
}

fulltrees <- rbind(test.o350, test.u350)
fulltrees <- fulltrees[, c("tag", "stemtag", "quadrat", "sp", "dbh18", "codes")]

#4b. determine trees from species number plus ANPP (from 3b) ####
#potentially this can be another way to determine which species to add.

#############################################################################
#5 get the local and global coordinates ####
library(httr)

stem_coords <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/tree_coord_local_plot.csv"))

fulltreesgeo <- merge(fulltrees, stem_coords, by.x=c("tag", "stemtag","quadrat"), by.y=c("tag", "stemtag","quadratname"))

fulltreesgeo <- setnames(fulltreesgeo, old=c("qx","qy","px","py"), new=c("lx","ly","gx","gy"))

fulltreesgeo <- fulltreesgeo[with(fulltreesgeo, order(tag)), ]

##if want coordinates for arcmap or mapping, use this
#geo_stems <- read.csv("V:/SIGEO/GIS_data/R-script_Convert local-global coord/scbi_stem_utm_lat_long.csv")

#############################################################################
#6 Create forms

#6a. make field form for new trees ####
newtrees<-fulltreesgeo[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "codes", "dbh18")] #depending on what data is being added, can add in location column

newtrees$measure = ""
newtrees$dendDiam = ""
newtrees$dendHt = ""
newtrees$type = ""
newtrees$dendroID = ""
newtrees$install.date = ""
newtrees$dbhnew = ""
newtrees$biannual <- 1
newtrees$intra <- ""

newtrees$codes <- as.character(newtrees$codes)
newtrees$codes = ifelse(newtrees$codes %in% "NULL", "", newtrees$codes)
#newtrees$location <-gsub("South", "S", newtrees$location)
#newtrees$location <-gsub("North", "N", newtrees$location)

setnames(newtrees, old=c("codes", "stemtag"), new=c("codes&notes", "stem"))

newtrees <- newtrees[,c(1:6,8,16:17,14,15,13,12,10,11,9,7)]

##6ai. determine which trees are added to intraannual survey ####
##this is the same kind of random assignment as seen above in step 4a
over_newtrees <- NULL
for (k in seq(along=sp)){
  for (h in seq(along=replace$is.intraannual.o350)){
    if (k==h){
      trees <- sp[[k]] #sp is from step 4a
      number <- replace$is.intraannual.o350[[h]]
      
      over <- subset(newtrees, newtrees$dbh18>350 & newtrees$sp %in% trees)
      over <- over[over$tag %in% sample(over$tag, replace$is.intraannual.o350[[k]]), ]
      
      over_newtrees <- rbind(over_newtrees, over)
    }
  }
}

under_newtrees <- NULL
for (k in seq(along=sp)){
  for (h in seq(along=replace$is.intraannual.u350)){
    if (k==h){
      trees <- sp[[k]] #sp is from step 4a
      number <- replace$is.intraannual.u350[[h]]
      
      under <- subset(newtrees, newtrees$dbh18<=350 & newtrees$sp %in% trees)
      under <- under[under$tag %in% sample(under$tag, replace$is.intraannual.u350[[k]]), ]
      
      under_newtrees <- rbind(under_newtrees, under)
    }
  }
}

replace_intra <- rbind(over_newtrees, under_newtrees)

newtrees$intra <- ifelse(newtrees$tag %in% c(replace_intra$tag), 1, 0)

##6aii. create excel sheet for field form ####
matrix <- function(newtrees, table_title) {
  
  rbind(c(table_title, rep('', ncol(newtrees)-1)), # title
        names(newtrees), # column names
        unname(sapply(newtrees, as.character))) # data
  
}

temp1 <- matrix(newtrees, table_title=('New Dendroband Trees                    Date:                       Surveyors:'))



library(xlsx)
write.xlsx(temp1, "resources/field_forms/2019/field_form_new_trees_2019.xlsx", row.names = FALSE, col.names=FALSE)

#6b. Create data_entry form ####

newtrees$year <- ""
newtrees$month <- ""
newtrees$day <- ""
newtrees$notes <- ""
newtrees$field.recorders <- ""
newtrees$data.enter <- ""
newtrees$install.date <- NULL

library(data.table)
newtrees <- setnames(newtrees, old=c("intra", "codes&notes"), new=c("intraannual", "codes"))

newtrees <- newtrees[ ,c(1:6,17:19,8:16,20:22)]
newtrees[is.na(newtrees)] <- ""

write.csv(newtrees, "resources/data_entry_forms/2019/data_entry_new_trees_2019.csv", row.names=FALSE)

############################################################################
#7 merge data_entry form to the next year's master file ####

#the next year's file should already be created from the script "new_scbidendroAll_[YEAR].R". The lines of code below are for merging into the file created from that script.
library(data.table)

dendro_2019 <- read.csv("data/scbi.dendroAll_2019.csv", stringsAsFactors = FALSE)

tree_replace <- read.csv("resources/data_entry_forms/2019/data_entry_new_trees_2019.csv")

recensus2013 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem2.csv"))

tree_replace <- setnames(tree_replace, old=c("stem", "dbhnew"), new=c("stemtag", "dbh"))

tree_replace$biannual <- as.numeric(tree_replace$biannual)
tree_replace$status <- "alive"
tree_replace$new.band <- 1
tree_replace$survey.ID <- 2019
tree_replace$dbh <- tree_replace$dbh*10
tree_replace$dendDiam <- tree_replace$dendDiam*10 #DBH AND DENDDIAM IN MM
tree_replace$stemID <- recensus2013$stemID[match(tree_replace$tag, recensus2013$tag)]
tree_replace$treeID <- recensus2013$treeID[match(tree_replace$tag, recensus2013$tag)]

extra <- setdiff(colnames(dendro_2019), colnames(tree_replace))
tree_replace[,extra] <- NA

dendro_2019 <- rbind(dendro_2019, tree_replace)
dendro_2019 <- dendro_2019[order(dendro_2019$tag, dendro_2019$stemtag), ]

dendro_2019$codes <- ifelse(is.na(dendro_2019$codes), "", dendro_2019$codes)
dendro_2019$notes <- ifelse(is.na(dendro_2019$notes), "", dendro_2019$notes)

write.csv(dendro_2019, "data/scbi.dendroAll_2019.csv", row.names=FALSE)

##############################################################################
#8 merge data_entry form with dendro_trees.csv and dendroID.csv

##8a. dendro_trees ####
tree_replace <- read.csv("resources/data_entry_forms/2019/data_entry_new_trees_2019.csv")

dendro_trees <- read.csv("data/dendro_trees.csv")

recensus2013 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem2.csv"))

geo_stems <- read.csv("V:/SIGEO/GIS_data/R-script_Convert local-global coord/scbi_stem_utm_lat_long.csv")

tree_coord <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/tree_coord_local_plot.csv"))

library(data.table)
tree_replace <- setnames(tree_replace, old=c("stem", "dbhnew"), new=c("stemtag", "dbh"))
tree_replace <- setnames(tree_replace, old=c("year", "month", "day"), new=c("dendro.start.year", "dendro.start.month", "dendro.start.day"))

tree_replace$biannual <- as.numeric(tree_replace$biannual)
tree_replace$stemID <- recensus2013$stemID[match(tree_replace$tag, recensus2013$tag)]
tree_replace$treeID <- recensus2013$treeID[match(tree_replace$tag, recensus2013$tag)]
tree_replace$cored <- 0
tree_replace$location <- ifelse(tree_replace$quadrat %% 100 >= 16, "North", "South")
tree_replace$tree.notes <- ""

add_cols <- setdiff(colnames(dendro_trees), colnames(tree_replace))
tree_replace[,add_cols] <- NA

remove_cols <- setdiff(colnames(tree_replace), colnames(dendro_trees))
tree_replace[,remove_cols] <- NULL

#add in coordinates
tree_coord <- setnames(tree_coord, old=c("qx","qy","px","py"), new=c("lx","ly","gx","gy"))
tree_replace$gx <- tree_coord$gx[match(tree_replace$tag, tree_coord$tag)]
tree_replace$gy <- tree_coord$gy[match(tree_replace$tag, tree_coord$tag)]

tree_replace$lon <- geo_stems$lon[match(tree_replace$tag, geo_stems$tag)]
tree_replace$lat <- geo_stems$lat[match(tree_replace$tag, geo_stems$tag)]
tree_replace$NAD83_X <- geo_stems$NAD83_X[match(tree_replace$tag, geo_stems$tag)]
tree_replace$NAD83_Y <- geo_stems$NAD83_Y[match(tree_replace$tag, geo_stems$tag)]

dendro_trees <- rbind(dendro_trees, tree_replace)
dendro_trees <- dendro_trees[order(dendro_trees$tag, dendro_trees$stemtag), ]

write.csv(dendro_trees, "dendro_trees.csv", row.names=FALSE)

##8b. dendroID ####
tree_replace <- read.csv("resources/data_entry_forms/2019/data_entry_new_trees_2019.csv")

dendroID <- read.csv("data/dendroID.csv")

recensus2013 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem2.csv"))

library(data.table)
tree_replace <- setnames(tree_replace, old=c("stem", "dbhnew"), new=c("stemtag", "dbh"))

tree_replace$new.band <- 1
tree_replace$survey.ID <- 2019
tree_replace$stemID <- recensus2013$stemID[match(tree_replace$tag, recensus2013$tag)]
tree_replace$treeID <- recensus2013$treeID[match(tree_replace$tag, recensus2013$tag)]
tree_replace$dbh <- tree_replace$dbh*10
tree_replace$dendDiam <- tree_replace$dendDiam*10

remove_cols <- setdiff(colnames(tree_replace), colnames(dendroID))
tree_replace[,remove_cols] <- NULL

add_cols <- setdiff(colnames(dendroID), colnames(tree_replace))
tree_replace[,add_cols] <- NA

dendroID <- rbind(dendroID, tree_replace)
dendroID <- dendroID[order(dendroID$tag, dendroID$stemtag), ]

write.csv(dendroID, "data/dendroID.csv", row.names=FALSE)

