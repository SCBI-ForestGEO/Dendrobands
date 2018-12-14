# Determine both dendrobands that need to be fixed, and new trees that will replace dead ones.

setwd("C:\Users\mcgregori\Dropbox (Smithsonian)\Github_Ian\Dendrobands\resources\field_forms")

dendro18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

##Quick numbers
#bands that need to be fixed
length(c(grep("RD", dendro18$codes)))

#number of trees that need to be replaced
q <- dendro18[which(dendro18$survey.ID==c('2018.14')), ] 
length(c(grep("dead", q$status)))
rm(q)

#1 Create field_form_bandreplace forms for trees that need fixing ####
##1a determine # of dendrobands whose window is too large. These will need to be changed out at some point. ####
trends <- dendro18[,c("tag", "stemtag", "survey.ID", "sp", "measure")]
trends <- trends[which(trends$survey.ID==c('2018.01', '2018.14')), ] 

##determine which trees will need to have dendroband replaced based on measurements. The max a caliper can measure is 153.71 mm.
library(data.table)
growth <- data.table(trends)
growth<-growth[,list(band.growth=diff(measure)),list(tag,sp)]

##range of measurement values over the growing season
range <- c(sort(growth$band.growth, decreasing=TRUE))
range <- range[range >=0]
range
mean(range)
sd(range)

##in 2018's example, mean=11.88 and sd=8.94, so I'm assigning values in measure >= 133 to have a code of RD.
data_install<-dendro18[which(dendro18$survey.ID=='2018.14'), ]
data_install$codes <- as.character(data_install$codes)
data_install$codes <- ifelse(data_install$measure >= 133 & !grepl("RD", data_install$codes), paste(data_install$codes, "RD", sep = ";"), data_install$codes)
data_install$codes <- gsub("^;", "", data_install$codes) 

##1b if don't have much time, then focus first on those bands that really need fixing ####

##subset by RD codes (having subset by 2018.14 already above)
data_install<-dendro18[which(dendro18$survey.ID=='2018.14'), ] #if did not do step 1a above then run this line before going on
data_install<-data_install[grepl("RD",data_install[["codes"]]), ]

##rest of code is for making the field_form
data_install<-data_install[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "measure", "codes", "location", "dendDiam", "dendroID", "type", "dendHt")]

data_install$measure = NA
data_install$codes = NA
data_install$dendDiam = NA
data_install$dendHt = NA
data_install$type = NA
data_install$dendroID = NA

data_install$install.date = NA
data_install$dbhnew = NA

library(dplyr)
setnames(data_install, old=c("codes", "stemtag"), new=c("codes&notes", "stem"))

data_install[is.na(data_install)] <- " "

data_install<-data_install[,c(1:6,14,15,11,12,10,13,7:9)]

data_install$location<-gsub("South", "S", data_install$location)
data_install$location<-gsub("North", "N", data_install$location)

matrix <- function(data_install, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_install)-1)), # title
        names(data_install), # column names
        unname(sapply(data_install, as.character))) # data
  
}

temp <- matrix(data_install, table_title=('Dendroband Replacement                       Date:                       Surveyors:'))

library(xlsx)
write.xlsx(temp, "field_form_bandreplace.xlsx", row.names = FALSE, col.names=FALSE)


#2 list of dead trees that need to be replaced ####
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







#4 determine the actual trees to replace ####
recensus2018 <- read.csv("I:/recensus2018.csv")
recensus2018$DBH <- recensus2018$DBH*10
library(data.table)
recensus2018 <- setnames(recensus2018, old=c("Tag", "StemTag", "QuadratName", "Mnemonic", "DBH","Codes"),new=c("tag", "stemtag", "quadrat", "sp", "dbh18", "codes"))

replace$sp <- as.character(replace$sp)
sp <- c(replace$sp) #list of species for replacement trees
n.o350 <- c(replace$over.350)
n.u350 <- c(replace$under.350)

dendrobands <- c(dendrofull$tag) #trees that are already in dendroband survey

##subset by trees not already in dendrobands, by our target species, by alive trees over 350 dbh
trees.o350 <- subset(recensus2018, !(recensus2018$tag %in% dendrobands) & (recensus2018$sp %in% sp) & !(recensus2018$codes %in% c("D", "DS", "DC", "DN", "DT")) & (recensus2018$dbh18 > 350))

#same for under 350 but above 100 (based on range(under.350$dbhdead))
trees.u350 <- subset(recensus2018, !(recensus2018$tag %in% dendrobands) & (recensus2018$sp %in% sp) & !(recensus2018$codes %in% c("D", "DS", "DC", "DN", "DT")) & (recensus2018$dbh18 <= 350) & (recensus2018$dbh18 >100))

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

#5 get the local and global coordinates ####
stem_coords <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/census3_coord_local_plot.csv")

fulltreesgeo <- merge(fulltrees, stem_coords, by.x=c("tag", "stemtag","quadrat"), by.y=c("tag", "stemtag","quadratname"))

fulltreesgeo <- setnames(fulltreesgeo, old=c("qx","qy","px","py"), new=c("lx","ly","gx","gy"))

fulltreesgeo <- fulltreesgeo[with(fulltreesgeo, order(tag)), ]

##if want coordinates for arcmap or mapping, use this
#geo_stems <- read.csv("V:/SIGEO/GIS_data/R-script_Convert local-global coord/scbi_stem_utm_lat_long.csv")

#6 make field form for new trees ####
##rest of code is for making the field_form
newtrees<-fulltreesgeo[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "codes", "dbh18")] #depending on what data is being added, can add in location column

newtrees$measure = ""
newtrees$dendDiam = ""
newtrees$dendHt = ""
newtrees$type = ""
newtrees$dendroID = ""
newtrees$install.date = ""
newtrees$dbhnew = ""

newtrees$codes <- as.character(newtrees$codes)
newtrees$codes = ifelse(newtrees$codes %in% "NULL", "", newtrees$codes)
#newtrees$location <-gsub("South", "S", newtrees$location)
#newtrees$location <-gsub("North", "N", newtrees$location)

setnames(newtrees, old=c("codes", "stemtag"), new=c("codes&notes", "stem"))

newtrees <- newtrees[,c(1:6,8,14,15,13,12,10,11,9,7)]

#remember to indicate somewhere which trees are going to be added to the intraannual survey. Could do another nested for loop like the one above in step 4 but probably not needed since few intraannual trees die compared to biannual.

matrix <- function(newtrees, table_title) {
  
  rbind(c(table_title, rep('', ncol(newtrees)-1)), # title
        names(newtrees), # column names
        unname(sapply(newtrees, as.character))) # data
  
}

temp1 <- matrix(newtrees, table_title=('New Dendroband Trees                    Date:                       Surveyors:'))



library(xlsx)
write.xlsx(temp1, "field_form_treereplace.xlsx", row.names = FALSE, col.names=FALSE)
