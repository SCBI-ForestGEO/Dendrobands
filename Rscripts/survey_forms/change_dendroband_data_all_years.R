######################################################
# Purpose: Quick code to make changes to all dendroband master data files at once
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.3 - First created June 2019
######################################################

file_list <- dir("data/", pattern="scbi.dendroAll.*$")

# for intraannual
for (i in seq(along=file_list)){
  filename = file_list[[i]]
  
  data_intra <- read.csv(paste0("data/", filename))
 
  data_intra$stemID <- ifelse(data_intra$tag == 30365, 3998, data_intra$stemID)
  data_intra$treeID <- ifelse(data_intra$tag == 30365, 3998, data_intra$treeID)
  data_intra$stemID <- ifelse(data_intra$tag == 131352, 18274, data_intra$stemID)
  data_intra$treeID <- ifelse(data_intra$tag == 131352, 40284, data_intra$treeID)
  
  write.csv(data_intra, paste0(filename, ".csv"), row.names=FALSE)
}
