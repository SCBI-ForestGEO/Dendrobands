# determine growth over time with dbh

#1 convert intraannual growth to dbh####

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[0-8]*.csv")
years <- c(2010:2018)

#1a. this loop breaks up each year's dendroband trees into separate dataframes by stemID
all_years <- list()

for (k in seq(along=dirs)){
    file <- dirs[[k]]
    yr <- read.csv(file)
    yr_intra <- yr[yr$intraannual==1, ]

    all_years[[k]] <- split(yr_intra, yr_intra$stemID)
  #  if (file == dirs[[1]]){
  #   all_years[[k]] <- split(yr, yr$stemID)
  #  }
  #  else{
  #    all_years[[k]] <- split(yr_intra, yr_intra$stemID)
  #  }
}
tent_name <- paste0("trees", sep="_", years)
names(all_years) <- tent_name

#the below loop takes all the unique stemIDs from each year and rbinds them.
all_stems <- list()

for(stemID in sort(unique(unlist(sapply(all_years, names))))) {
  all_stems[[paste0("stemID_", stemID)]] <-  do.call(rbind, lapply(years, function(year) all_years[[paste0("trees", sep="_", year)]][[stemID]]))
}

#sort(unique(unlist(sapply(all_years, names)))) -> an explainer:
#sapply says find all the names within all_years
#unlist says take all those names (all those stemIDS) and dump them all together
#unique gets rid of the duplicates, and sort sorts them


#need to call in Condit's functions (also saved in separate R code) for the next bit
objectiveFuncDendro= function(diameter2,diameter1,gap1,gap2){
  if(gap1>diameter1) return(20)
  if(gap2>diameter2) return(20)
  
  delta=abs(diameter1 - diameter2 + (1/pi) * diameter2 * asin(gap2/diameter2) - (1/pi) * diameter1 * asin(gap1/diameter1))
  
  return(return(delta))
}
findOneDendroDBH= function(dbh1,m1,m2,func=objectiveFuncDendro){
  if(is.na(dbh1)|is.na(m1)|is.na(m2)|dbh1<=0) return(NA)
  
  if(m2>0) upper=dbh1+m2
  else upper=dbh1+1
  if(m2<m1) lower=0
  else lower=dbh1
  
  result=optimize(f=func,interval=c(lower,upper),diameter1=dbh1,gap1=m1,gap2=m2)
  return(result$minimum)
}
findDendroDBH= function(dbh1,m1,m2,func=objectiveFuncDendro){
  records=max(length(dbh1),length(m1),length(m2))
  
  if(length(dbh1)==1) dbh1=rep(dbh1,records)
  if(length(m1)==1) m1=rep(m1,records)
  if(length(m2)==1) m2=rep(m2,records)
  
  dbh2=numeric()
  for(i in 1:records) dbh2[i]=findOneDendroDBH(dbh1[i],m1[i],m2[i],func)
  return(dbh2)
}

#1b. this loop says the following:
##1. Assigns the first dbh of the growth column as the first dbh.
##2. Says the following:
##2i.If new.band=0 (no band change), we have a measure, and we have a previous dbh2, use Condit's function to determine next dbh2 based on caliper measurement. 
##2ii. If new.band=0, we have a measure, and the previous dbh2 is NA, use Condit's function by comparing the new measure with the most recent non-NA dbh2.
##2iii. If new.band=0 and the previous measure is NA, give dbh2 a value of NA.
##2iv. If new.band=1 (band and measurement change), we have a measure, and there's a new dbh, assign that dbh to dbh2.
##2v. If new.band=1, we have a measure, and there's no new dbh (indicating a new dbh wasn't recorded when the band was changed), dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vi. UNCOMMON If new.band=1 , measure is NA, and the dbh in the original column is unchanged , dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vii. UNCOMMON If new.band=1, measure is NA, and dbh is different, dbh2 is the new dbh plus the mean of the differences of the previous dbh2's. 


library(zoo)

for(stems in names(all_stems)) {
  tree.n <- all_stems[[stems]]
  tree.n$dbh2 <- NA
  tree.n$dbh2[1] <- tree.n$dbh[1]
  
  tree.n$dbh2 <- as.numeric(tree.n$dbh2)
  tree.n$measure <- as.numeric(tree.n$measure)
  tree.n$dbh <- as.numeric(tree.n$dbh)
  
  q <- mean(unlist(tapply(tree.n$measure, tree.n$dendroID, diff)), na.rm=TRUE)
    
  for(i in 2:(nrow(tree.n))){
    tree.n$dbh2[[i]] <- 
      
      ifelse(tree.n$new.band[[i]] == 0 & tree.n$survey.ID[[i]] == 2014.01 & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
      tree.n$dbh[[i]],
      
      ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & !is.na(tree.n$dbh2[[i-1]]),
      findDendroDBH(tree.n$dbh2[[i-1]], tree.n$measure[[i-1]], tree.n$measure[[i]]),
               
      ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & is.na(tree.n$dbh2[[i-1]]), 
      findDendroDBH(tail(na.locf(tree.n$dbh2[1:i-1]), n=1), tail(na.locf(tree.n$measure[1:i-1]), n=1), tree.n$measure[[i]]),
                      
      ifelse(tree.n$new.band[[i]] == 0 & is.na(tree.n$measure[[i]]), NA,
                             
      ifelse(tree.n$new.band[[i]]==1 & !is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
       tree.n$dbh[[i]],
                                    
       ifelse(tree.n$new.band[[i]] == 1 & !is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
        max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1: i-1]), na.rm = T),
                                           
       ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
       max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=T),
                                                  
       ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
       tree.n$dbh[i] + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=TRUE),
       tree.n$dbh2))))))))
  }
  all_stems[[stems]] <- tree.n
}


######################################################################################
##1c. troubleshoot with individual tags
dendro_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")
intra <- dendro_2018[dendro_2018$intraannual==1, ]
test <- intra[intra$tag==12025, ] #12025 has band replaced

dendro_2017 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2017.csv")
intra <- dendro_2017[dendro_2017$intraannual==1, ]
test <- intra[intra$tag==60459, ] #60459 has band replaced but with NAs for a few measurements. The following code should be tried with 10671 as well.

library(zoo)

test$dbh2 <- NA
test$dbh2[1] <- test$dbh[1]
q <- mean(unlist(tapply(test$measure, test$dendroID, diff)), na.rm=TRUE)

for(i in 2:nrow(test)) {
  test$dbh2[[i]] <- 

    ifelse(test$new.band[[i]] == 0 & !is.na(test$measure[[i]]) & !is.na(test$dbh2[[i-1]]), 
    findDendroDBH(test$dbh2[[i-1]], test$measure[[i-1]], test$measure[[i]]),
    
    ifelse(test$new.band[[i]] == 0 & !is.na(test$measure[[i]]) & is.na(test$dbh2[[i-1]]), 
    findDendroDBH(tail(na.locf(test$dbh2[1:i-1]), n=1), tail(na.locf(test$measure[1:i-1]), n=1), test$measure[[i]]),
    
    ifelse(test$new.band[[i]] == 0 & is.na(test$measure[[i]]),
    NA,
     
    ifelse(test$new.band[[i]]==1 & !is.na(test$measure[[i]]) & !identical(test$dbh[[i]], test$dbh[[i-1]]),
    test$dbh[[i]],
      
    ifelse(test$new.band[[i]] == 1 & !is.na(test$measure[[i]]) & identical(test$dbh[[i]], test$dbh[[i-1]]),
    max(test$dbh2[1: i-1], na.rm = T) + mean(diff(test$dbh2[1: i-1]), na.rm = T),
   
    ifelse(test$new.band[[i]] == 1 & is.na(test$measure[[i]]) & identical(test$dbh[[i]], test$dbh[[i-1]]),
    max(test$dbh2[1: i-1], na.rm = T) + mean(diff(test$dbh2[1:(i-1)]), na.rm=T),
          
    ifelse(test$new.band[[i]] == 1 & is.na(test$measure[[i]]) & !identical(test$dbh[[i]], test$dbh[[i-1]]),
    test$dbh[i] + mean(diff(test$dbh2[1:(i-1)]), na.rm=TRUE),
    test$dbh2)))))))
}


##after that, next step is to bring in the 2010 data


#######################################################################################
#2 Graph the dbh growth per stem in a given year #####
## based off McMahon code: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4314258/

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
band18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

library(chron)
band18$date <- paste0(band18$month, sep="/", band18$day, sep="/", band18$year)
band18$doy <- julian(band18$month, band18$day, band18$year, origin=c(01,01,2018))

band18$date <- as.Date(band18$date, format="%m/%d/%Y")
band18$date <- factor(band18$date, ordered=TRUE)




#2a. for-loop graphs ####
#this code makes graphs for every dendroband stemID
library(ggplot2)

pdf(file = "dbh_growth_dendrobands.pdf")
for (j in names(all_stems)){
  dendro <- all_stems[[j]]
  
  dendro$date <- paste0(dendro$month, sep="/", dendro$day, sep="/", dendro$year)
  dendro$date <- as.Date(dendro$date, format="%m/%d/%Y")
  #dendro$date <- factor(dendro$date, ordered=TRUE)
  
  #dendro$doy <- julian(dendro$month, dendro$day, dendro$year, origin=c(01,01,2018))
  
  q <- ggplot(dendro, aes(x = date, y = dbh2)) +
    geom_line(color = "#0c4c8a") +
    labs(title = "Tree Growth from Dendrobands 2011-2018",
         subtitle = paste0("Tag: ", dendro$tag, sep=", ", 
                           "Stemtag:", dendro$stemtag, sep=", ",
                           "StemID: ", dendro$stemID),
         x = "Date",
         y = "DBH in mm") +
    theme_minimal()
    #facet_wrap(c("tag", "stemtag"), labeller="label_both")
  print(q)
}
dev.off()

###
test <- subset(intra, intra$tag == 10671)
plot(test$doy, test$measure, xlab = "Day of the year", ylab = "DBH (cm)", pch = 18, 
     col = "red", main = "Cumulative annual growth")
###

test <- subset(intra, intra$tag == 10671)
p <- ggplot(test) +
  aes(x = doy, y = measure) +
  geom_line(color = "#0c4c8a") +
  labs(title = paste0("Dendroband Growth 2018 ", "_10671"),
       x = "Date 2018",
       y = "Caliper measurements") +
  theme_minimal()
print(p)
dev.off()
########################################################################################
#3 find variability of tree growth by species by year #####

#2010 not included because only one measurement
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[1-8]*.csv")

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
    
    all_sp[[spec]] <- sprange
  }
  all_files[[j]] <- all_sp
}
names(all_files) <- date

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
#########################################################################################
#4. growth variability graphs ####
library(ggplot2)
library(RColorBrewer)

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/results")
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

######################################################################################
#5. troubleshooting for-loop ##############################################
dendro_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

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