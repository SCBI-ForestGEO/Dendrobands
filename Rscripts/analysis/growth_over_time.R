# determine ideal length of dendroband per dbh measurement

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
  
#2010 not included because only one measurement
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[1-9]*.csv")

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
step2$avg_growth_range_mm <- step2[, "maxgrowth_mm"] - step2[, "mingrowth_mm"]

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/results")
write.csv(step2, "growth_variability_by_sp.csv", row.names=FALSE)


#####################################################################################
#convert intraannual growth to dbh####
intra <- dendro18[dendro18$intraannual==1, ]
intra$dbh2 <- NA

x10671 <- intra[intra$tag==10671, ]
cal <- c(x10671$measure)
x10671$dbh2[[1]] <- x10671$dbh[[1]]
#x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.01), x10671$dbh, x10671$dbh2)
x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.02, findDendroDBH(x10671$dbh, cal[[1]], cal[[2]]), x10671$dbh2)

x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.03, findDendroDBH(x10671$dbh2[[2]], cal[[2]], cal[[3]]), x10671$dbh2)

x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.04, findDendroDBH(x10671$dbh2[[3]], cal[[3]], cal[[4]]), x10671$dbh2)

###NEXT THING IS TO MAKE A FOR-LOOP OUT OF THIS
#questions
1. this will skip over smaller numbers, eg 2018.031
2. what happens to NA values in this iteration
3. how to account for jumps in measurements (e.g. 150.32 to 6.23)



#graphs ####
library(ggplot2)
library(RColorBrewer)

setwd("E:/Github_SCBI/Dendrobands/results")
pdf("mean_growth_by_species.pdf", width=12)

#this graph shows the average range of growth per species. The lower numbers means the avg max and avg min are closer together. Almost all species are under 10mm, which means on average each species grows less than 1cm per growing season (1 cm according to dendroband measurements).
ggplot(data = step2) +
  aes(x = sp, weight = avg_growth_range_mm) +
  geom_bar(fill = "#0c4c8a") +
  labs(title="Avg (Dendroband) Growth Range by Species", x="Species", y="Growth (mm)")
  theme_minimal()

#the following graph breaks the first one apart and plots the max by the min. It reveals a good fit relationship between the two, suggesting that most species follow a similar average pattern.
pallette = brewer.pal(9, "Set1")
pallette = colorRampPalette(pallette)(23)

ggplot(data = step2) + 
  geom_point(aes(x = mingrowth_mm, y = maxgrowth_mm, color=sp)) +
  scale_colour_manual(values = pallette) +
  labs(title="Avg (Dendroband) Growth by Species", x="Minimum growth (mm)", y="Maximum growth (mm)") +
  theme_grey()

dev.off()

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