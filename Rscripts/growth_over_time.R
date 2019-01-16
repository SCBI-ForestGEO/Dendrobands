# determine ideal length of dendroband per dbh measurement

setwd("E:/Github_SCBI/Dendrobands/data")
  
#2010 not included because only one measurement
dirs <- dir("E:/Github_SCBI/Dendrobands/data", pattern="_201[1-9]*.csv")

library(data.table)
date <- c(2011:2018)
filename <- paste(date, "range", sep="_")

all_sp <- list()
all_files <- list()

#this nested for-loop first makes a list of each species' average growth (max-min) in a year. Then, it combines all the years into one list (all_files).
for (j in seq(along=dirs)){
  year <- read.csv(dirs[[j]])
  
  year$sp <- as.character(year$sp)
  sp <- c(unique(year$sp))
  
  for (i in seq(along=sp)){
    spec <- sp[[i]]
    name <- paste0(spec, "data")
    sprange <- paste(sp[[i]], "range", sep="_")
    
    name <- subset(year, sp %in% spec)
    name <- name[ ,c("tag", "stemtag", "sp", "measure", "codes")]
    
    #get range (max-min) of measurements by tag
    sprange <- aggregate(name[, c("measure")], list(name$tag, name$stemtag, name$sp), FUN = function(i)max(i) - min(i))
    colnames(sprange) <- c("tag", "stemtag", "sp", "growth")
    
    #remove NA and values over 50 (would indicate band replacement)
    sprange <- subset(sprange, !is.na(sprange$growth) & sprange$growth <= 50)
    #take the average of the ranges
    sprange <- if (nrow(sprange)>=2){
      aggregate(sprange[, c("growth")], list(sprange$sp), mean)
    }
      else {
        sprange[ ,c("sp", "growth")]
      }
    colnames(sprange) <- c("sp", paste0("avg_growth",date[j],"_mm"))
    
    all_sp[[i]] <- sprange
  }
  all_files[[j]] <- all_sp
}

#now, coerce the list of lists into a usable dataframe
step1 <- lapply(all_files, rbindlist)
library(tidyverse)
step2 <- reduce(step1, merge, by = "sp", all=TRUE)

#round to 2nd decimal
step2[ ,c(2:9)] <- round(step2[ ,c(2:9)], digits=2)

#find range of years
step2$mingrowth_mm <- apply(step2[, 2:9], 1, min, na.rm=TRUE)
step2$maxgrowth_mm <- apply(step2[, 2:9], 1, max, na.rm=TRUE)

setwd("E:/Github_SCBI/Dendrobands/results")
write.csv(step2, "mean_growth_by_sp.csv", row.names=FALSE)
  
#troubleshooting for-loop ##############################################
dendro_2018 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2018.csv")

dendro_2018$sp <- as.character(dendro_2018$sp)
sp <- c(unique(dendro_2018$sp))

all_sp <- list()
all_sp <- data.frame(sp = character(), 
                     avg_range = integer())

for (i in seq(along=sp)){
  spec <- sp[[i]]
  name <- paste0(spec, "data")
  sprange <- paste(sp[[i]], "range", sep="_")
  
  name <- subset(dendro_2018, sp %in% spec)
  name <- name[ ,c("tag", "stemtag", "sp", "measure", "codes")]
  
  #get range (max-min) of measurements by tag
  sprange <- aggregate(name[, c("measure")], list(name$tag, name$stemtag, name$sp), FUN = function(i)max(i) - min(i))
  colnames(sprange) <- c("tag", "stemtag", "sp", "measure_range")
  
  #remove NA and values over 50 (would indicate band replacement)
  sprange <- subset(sprange, !is.na(sprange$measure_range) & sprange$measure_range <= 50)
  #take the average of the ranges
  sprange <- if (nrow(sprange)>=2){
    aggregate(sprange[, c("measure_range")], list(sprange$sp), mean)
  }
  else {
    sprange[ ,c("sp", "measure_range")]
  }
  colnames(sprange) <- c("sp", "avg_range")
  
  all_sp[[i]] <- sprange
}

library(data.table)
file <- rbindlist(all_sp)
colnames(file) <- c("sp", "avg_range")
file$avg_range <- round(file$avg_range, digits=2)


#troubleshooting within for-loop###################################################
dendro_2014 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2014.csv")

dendro_2014$sp <- as.character(dendro_2014$sp)
sp <- c(unique(dendro_2014$sp))

all_sp <- list()

  spec <- sp[[1]]
  name <- paste0(spec, "data")
  sprange <- paste(sp[[22]], "range", sep="_")
  
  name <- subset(dendro_2014, sp %in% spec)
  name <- name[ ,c("tag", "stemtag", "sp", "measure", "codes")]
  
  #get range (max-min) of measurements by tag
  sprange <- aggregate(name[, c("measure")], list(name$tag, name$stemtag, name$sp), FUN = function(i)max(i) - min(i))
  colnames(sprange) <- c("tag", "stemtag", "sp", "measure_range")
  
  #remove NA and values over 50 (would indicate band replacement)
  sprange <- subset(sprange, !is.na(sprange$measure_range) & sprange$measure_range <= 50)
  #take the average of the ranges
  sprange <- aggregate(sprange[, c("measure_range")], list(sprange$sp), mean)
  
  #add all resulting tables to a list
  all_sp[[i]] <- sprange