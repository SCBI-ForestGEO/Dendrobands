# dendroband survey numbers per year

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[0-8]*.csv")

dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv", stringsAsFactors=FALSE)

survey <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/survey_numbers_by_year.csv")

for (k in seq(along=dirs)){
  path <- dirs[[k]]
  file <- read.csv(path, stringsAsFactors = FALSE)
  
  for (i in seq(along=survey$year[1:9])){
    year <- survey$year[[i]]
    
    if (k==i){
      #n.surveys
      survey$n.surveys <- ifelse(survey$year %in% year, length(unique(round(file$survey.ID[!file$survey.ID %in% c("00", "99")], 2))), survey$n.surveys)
      
      #__.all
      all_bi <- dendro_trees[!dendro_trees$dendro.start.year > year, ]
      survey$biannual.all <- ifelse(survey$year %in% survey$year[[i]], length(unique(all_bi$stemID)), survey$biannual.all)
      
      all_intra <- all_bi[all_bi$intraannual == 1, ]
      survey$intraannual.all <- ifelse(survey$year %in% survey$year[[i]], length(unique(all_intra$stemID)), survey$intraannual.all)
      
      #___.live
      #the min is here because we're interested in seeing the survey numbers as they were at when the growing season started. The only reason to use the max survey.ID is for calculating dead trees and additions.
      if (year == 2013){
        alive <- file[file$survey.ID == max(file$survey.ID), ] 
        #because 2013 new plants added in middle of season
      } else {
        alive <- file[!file$survey.ID %in% "00" & file$survey.ID == min(file$survey.ID), ]
      }
      survey$biannual.live <- ifelse(survey$year %in% survey$year[[i]], length(unique(alive$stemID)), survey$biannual.live)
      
      if (year == 2013){
        alive_intra <- file[file$intraannual == 1 & file$survey.ID == max(file$survey.ID), ] 
        #because 2013 new plants added in middle of season
      } else {
        alive_intra <- file[file$intraannual == 1 & !file$survey.ID %in% "00" & file$survey.ID == min(file$survey.ID), ]
      }
      survey$intraannual.live <- ifelse(survey$year %in% survey$year[[i]], length(unique(alive_intra$stemID)), survey$intraannual.live)
      
      #___.dead
      dead <- file[file$status == "dead" & !file$survey.ID %in% "99" & file$survey.ID == max(file$survey.ID), ]
      survey$biannual.dead <- ifelse(survey$year %in% survey$year[[i]], length(unique(dead$stemID)), survey$biannual.dead)
      
      dead_intra <- file[file$status == "dead" & !file$survey.ID %in% "99" & file$survey.ID == max(file$survey.ID) & file$intraannual == 1, ]
      survey$intraannual.dead <- ifelse(survey$year %in% survey$year[[i]], length(unique(dead_intra$stemID)), survey$intraannual.dead)
      
      #___.added
      new <- dendro_trees[dendro_trees$dendro.start.year %in% survey$year[[i]], ]
      survey$biannual.added <- ifelse(survey$year %in% survey$year[[i]],length(unique(new$stemID)), survey$biannual.added)
      
      new_intra <- dendro_trees[dendro_trees$dendro.start.year %in% survey$year[[i]] & dendro_trees$intraannual == 1, ]
      survey$intraannual.added <- ifelse(survey$year %in% survey$year[[i]],length(unique(new_intra$stemID)), survey$intraannual.added)
      
    }
  }
}
    
write.csv(survey, "survey_numbers_by_year.csv", row.names=FALSE)
