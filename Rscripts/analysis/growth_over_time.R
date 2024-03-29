######################################################
# Purpose: Determine growth over time from dendroband measurements
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created March 2018, updated August 2019
######################################################
library(tidyverse) #3,4
library(zoo) #5
library(chron)
library(ggplot2) #6, 4
library(data.table) #3
library(RColorBrewer) #4
library(lubridate) #2


#1. format dendroband data ####

files <- dir("data", pattern="_201[0-9]*.csv")
dates <- c(2010:2019)

#1a. this loop breaks up each year's dendroband trees into separate dataframes by stemID 
##grouping by intraannual ####

make_growth_list <- function(dirs, years){
  all_years_intra <- list()
  for (k in seq(along=dirs)){
    file <- dirs[[k]]
    yr <- read.csv(paste0("data/", file), stringsAsFactors = FALSE)
    yr_intra <- yr[yr$intraannual==1, ]
    yr_intra$dbh <- as.numeric(yr_intra$dbh)
    
    all_years_intra[[k]] <- split(yr_intra, yr_intra$stemID)
    #  if (file == dirs[[1]]){
    #   all_years[[k]] <- split(yr, yr$stemID)
    #  }
    #  else{
    #    all_years[[k]] <- split(yr_intra, yr_intra$stemID)
    #  }
  }
  tent_name <- paste0("trees", sep="_", years)
  names(all_years_intra) <- tent_name
  
  #the below loop takes all the unique stemIDs from each year and rbinds them.
  all_stems_intra <- list()
  
  for(stemID in sort(unique(unlist(sapply(all_years_intra, names))))) {
    all_stems_intra[[paste0("stemID_", stemID)]] <- do.call(rbind, lapply(years, function(year) all_years_intra[[paste0("trees", sep="_", year)]][[stemID]]))
  }
  
  intra_years <- list2env(all_years_intra)
  all_years_intra <<- as.list(intra_years)
  
  intra_stems <- list2env(all_stems_intra)
  all_stems_intra <<- as.list(intra_stems)
}

make_growth_list(files, dates)

##an explanation of the for-loop
#sort(unique(unlist(sapply(all_years, names)))) -> an explainer:
#sapply says find all the names within all_years
#unlist says take all those names (all those stemIDS) and dump them all together
#unique gets rid of the duplicates, and sort sorts them

##grouping by biannual ####
all_years_bi <- list()

for (k in seq(along=dirs)){
  file <- dirs[[k]]
  yr <- read.csv(paste0("data/", file), stringsAsFactors = FALSE)
  yr_bi <- yr[yr$intraannual == 0, ]
  yr_bi$dbh <- as.numeric(yr_bi$dbh)
  
  all_years_bi[[k]] <- split(yr_bi, yr_bi$stemID)
}
tent_name <- paste0("trees", sep="_", years)
names(all_years_bi) <- tent_name

#the below loop takes all the unique stemIDs from each year and rbinds them.
all_stems_bi <- list()

for(stemID in sort(unique(unlist(sapply(all_years_bi, names))))) {
  all_stems_bi[[paste0("stemID_", stemID)]] <-  do.call(rbind, lapply(years, function(year) all_years_bi[[paste0("trees", sep="_", year)]][[stemID]]))
}



###############################################################################
#2. calculate growth over time using McMahon RDendrom package ####
#see https://rdrr.io/github/seanmcm/RDendrom/f/vignettes/RDendrom_vignette.Rmd

devtools::install_github("seanmcm/RDendrom")
library(RDendrom)

#this function includes both the code to reformat SCBI data and the code to subsequently use the RDendrom functions. Running the function, which will yield two graphs showing the current dbh and dbh growth over time, can be done by entering in the stemID number.

#if an error occurs, run through the function manually, and let Sean know
#https://github.com/seanmcm/RDendrom
calculate_dbh <- function(stem_no){
  stem <- paste0("stemID_", stem_no)
  test_intra <- all_stems_intra[[stem]]
  
  ##6a. format data and run code
  test_intra <- setnames(
    test_intra, 
    old=c("treeID", "stemID", "sp", "dbh", "measure", "year", "new.band"), 
    new=c("TREE_ID", "UNIQUE_ID", "SP", "ORG_DBH", "GAP_WIDTH", "YEAR", "NEW_BAND"),
    skip_absent=TRUE)
  
  newcols <- c("SKIP", "ADJUST", "REMOVE")
  test_intra[,newcols] <- 0
  test_intra$SITE <- "SCBI"
  test_intra$ORG_DBH <- test_intra$ORG_DBH/10
  
  
  test_intra$DOY <- as.Date(with(test_intra, paste(YEAR, month, day, sep="-")), "%Y-%m-%d")
  test_intra$DOY <- yday(test_intra$DOY)
  test_intra$SITE <- "SCBI"
  
  #creates separate column creating band numbers starting at 1, then increasing by 1 for each NEW_BAND=1 change
  band.index <- as.numeric(table(test_intra$dendroID))
  test_intra$BAND_NUM <- unlist(mapply(rep, seq(length(band.index)), length.out = band.index))
  
  #remove NAs in caliper measurements
  test_intra <- subset(test_intra, complete.cases(test_intra$GAP_WIDTH))
  
  #beginning of RDendrom functions
  get.optimized.dendro(test_intra, OUTPUT.folder = "results/McMahon_code_output")
  
  param.table.name = "Param_table.csv"
  Dendro.data.name = "Dendro_data.Rdata"
  Dendro.split.name = "Dendro_data_split.Rdata"
  OUTPUT.folder <- "results/McMahon_code_output"
  
  param.table <- read.csv(file = paste(OUTPUT.folder, param.table.name, sep = "/"))
  load(file = paste(OUTPUT.folder, Dendro.data.name, sep = "/")) # loads Dendro.complete
  load(file = paste(OUTPUT.folder, Dendro.split.name, sep = "/")) #loads Dendro.split
  load(file = paste(OUTPUT.folder, "Dendro_Tree.Rdata", sep = "/")) #loads Dendro.tree
  
  get.extra.metrics(param.table, Dendro.split, OUTPUT.folder = OUTPUT.folder)
  param.table.extended <- read.csv(file = paste(OUTPUT.folder, param.table.name, sep = "/"))
  
  
  ##6b. graphs
  make.dendro.plot.ts(ts.data = Dendro.split[[4]], params = param.table[3, ], day = seq(365))
  
  make.dendro.plot.tree(Dendro.ind = Dendro.tree[[1]], param.tab = subset(param.table, TREE_ID == Dendro.tree[[1]]$TREE_ID[1]))
}

calculate_dbh(1609)


plot(Dendro.tree, params=param.table)

ggplot(Dendro.complete, aes(x = YEAR, y = DBH_TRUE)) +
  geom_line(color = "#0c4c8a") +
  labs(title = "Tree Growth from Dendrobands 2011-2018",
       subtitle = paste0("Tag: ", Dendro.complete$tag, sep=", ", 
                         "Stemtag:", Dendro.complete$stemtag, sep=", ",
                         "StemID: ", Dendro.complete$UNIQUE_ID),
       x = "Date",
       y = "DBH in mm") +
  theme_minimal()
print(q)

###############################################################################
#3. Growth variability over time SCBI ####
#2010 not included because only one measurement
dirs <- dir("data", pattern="_201[1-9]*.csv")

date <- c(2011:2019)
filename <- paste(date, "range", sep="_")

all_sp <- list()
all_files <- list()

#this nested for-loop first makes a list of each species' average growth (max-min) in a year. Then, it combines all the years into one list (all_files).
for (j in seq(along=dirs)){
  year <- read.csv(paste0("data/", dirs[[j]]))
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
    #also removed values == 0 (this never happens, plus leaving it in gives a skewed average if checking this during the middle of the growing season, before the second biannual census)
    sprange <- subset(sprange, !is.na(sprange$growth) & sprange$growth <= 50 & sprange$growth != 0)
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
step1 <- lapply(all_files, rbindlist, use.names=FALSE)
step2 <- reduce(step1, merge, by = "sp", all=TRUE)

#round to 2nd decimal
step2[ ,c(2:10)] <- round(step2[ ,c(2:10)], digits=2)

#find range of years
step2$mingrowth_mm <- apply(step2[, 2:9], 1, min, na.rm=TRUE)
step2$maxgrowth_mm <- apply(step2[, 2:9], 1, max, na.rm=TRUE)
step2$avg_growth_range_mm <- step2[, "maxgrowth_mm"] - step2[, "mingrowth_mm"]
step2$median_growth_mm <- apply(step2[, 2:9], 1, median, na.rm=TRUE)

write.csv(step2, "results/growth_variability_by_sp.csv", row.names=FALSE)
###############################################################################
#4. growth variability graphs ####
cols <- colnames(step2[, c(2:10)])
step3 <- step2[, c(1:10)]
step3 <- step3 %>%
  gather(cols, key = "year", value = "avg_growth")
step3$year <- ifelse(grepl("2011", step3$year), 2011,
               ifelse(grepl("2012", step3$year), 2012,
               ifelse(grepl("2013", step3$year), 2013,
               ifelse(grepl("2014", step3$year), 2014,
               ifelse(grepl("2015", step3$year), 2015,
               ifelse(grepl("2016", step3$year), 2016,
               ifelse(grepl("2017", step3$year), 2017,
               ifelse(grepl("2018", step3$year), 2018,
                                                2019))))))))
step3$year <- as.character(step3$year)

pdf("results/mean_growth_by_species.pdf", width=12)

#median of the avg growth for all dendro species
ggplot(data = step3, aes(x = sp)) +
  geom_bar(aes(y = avg_growth, fill=year), stat = "identity", position = "dodge") +
  labs(title="Mean Annual Growth by Species", x="Species", y="Growth (mm)") +
  theme_minimal()

#this graph shows the average range of growth per species. The lower numbers means the avg max and avg min are closer together. Almost all species are under 10mm, which means on average each species grows less than 1cm per growing season (1 cm according to dendroband measurements).
ggplot(data = step2) +
  aes(x = sp, weight = avg_growth_range_mm) +
  geom_bar(fill = "#0c4c8a") +
  labs(title="Avg (Dendroband) Growth Range by Species", x="Species", y="Growth (mm)") +
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
################################################################################
#5. loop to create timeseries of dbh measurements manually ####

##before we knew Sean was working on a package (RDendrom), Valentine and I tried to create the same functionality manually (#5 and #6 in this script). Since we do have RDendrom, this manual work is deprecated, but I've decided to leave it here in case it's needed later.
## *** to run this section, you need to run section #1 above first. ****
                         
#description of loop ####
##1. First, assigns the first dbh of the growth column as the first dbh.
##2. Second, is conditional:
##2i.If new.band=0 (no band change), we have a measure, and we have a previous dbh2, use Condit's function to determine next dbh2 based on caliper measurement. 
##2ii. If new.band=0, we have a measure, and the previous dbh2 is NA, use Condit's function by comparing the new measure with the most recent non-NA dbh2.
##2iii. If new.band=0 and the previous measure is NA, give dbh2 a value of NA.
##2iv. If new.band=1 (band and measurement change), we have a measure, and there's a new dbh, assign that dbh to dbh2.
##2v. If new.band=1, we have a measure, and there's no new dbh (indicating a new dbh wasn't recorded when the band was changed), dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vi. UNCOMMON If new.band=1 , measure is NA, and the dbh in the original column is unchanged , dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vii. UNCOMMON If new.band=1, measure is NA, and dbh is different, dbh2 is the new dbh plus the mean of the differences of the previous dbh2's. 

##intraannual data ####
for(stems in names(all_stems_intra)) {
  tree.n <- all_stems_intra[[stems]]
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
  all_stems_intra[[stems]] <- tree.n
}

#correction factor for 2013 census data. was going to complete this, but then Sean McMahon figured out his code.
# for(stems in names(all_stems)) {
#   tree.n <- all_stems[[stems]]
# 
#   tree.nsub <- tree.n[tree.n$survey.ID %in% c(2010:2014.01), ]
#   tree.n$dbh2 <- ifelse(unique(tree.nsub$dbh2[!tail(tree.nsub$dbh2, n=1)]), tree.n$dbh2,
#                         ifelse(tree.n$survey.ID == 2013.16 & tree.n$survey.ID == 2014.01, 
#                                
#                                abs(diff(tail(tree.n$dbh, n=2))) + tree.n$dbh2)....
#   #Dendrobands: if dbh 2010:2013.16 same, then take difference of 2014.01 and 2013.06, and add to entire 2010:2013.16 measurements.
#                         
#   all_stems[[stems]] <- tree.n
# }

##biannual data ####
for(stems in names(all_stems_bi)) {
  tree.n <- all_stems_bi[[stems]]
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
  all_stems_bi[[stems]] <- tree.n
}

#correction factor for 2013 census data: see above in intraannual code


############################
#6. Graph the dbh growth per stem in a given year ####
#for-loop graphs ####
#this code makes graphs for every dendroband stemID
pdf(file = "results/dbh_growth_dendrobands.pdf")
for (j in names(all_stems_intra)){
  dendro <- all_stems_intra[[j]]
  
  dendro$date <- paste0(dendro$month, sep="/", dendro$day, sep="/", dendro$year)
  dendro$date <- as.Date(dendro$date, format="%m/%d/%Y")
  #dendro$date <- factor(dendro$date, ordered=TRUE)
  
  #dendro$doy <- julian(dendro$month, dendro$day, dendro$year, origin=c(01,01,2018))
  
  q <- ggplot(dendro, aes(x = date, y = dbh2)) +
    geom_line(color = "#0c4c8a") +
    labs(title = "Tree Growth from Dendrobands 2011-2019",
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
