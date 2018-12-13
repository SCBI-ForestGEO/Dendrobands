# script to work with dendrobands in format to match McMahon's code
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4314258/

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
band18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

library(chron)
band18$doy <- paste0(band18$month, sep="/", band18$day, sep="/", band18$year)

intra <- subset(band18, band18$intraannual == 1)

tagsintra <- c(unique(intra$tag))
surveys <- c(unique(intra$survey.ID))

intraannual <- split(intra, f=c(intra$tag))

intra$doy <- as.Date(intra$doy, format="%m/%d/%Y")

library(ggplot2)

plot_list = list()
for (i in names(intraannual)){
  
  pdf(file = "Dendrobands_2018.pdf")
  
  dendro <- intraannual[[i]]
  
  ggplot(data = dendro) +
    aes(x = doy, y = measure) +
    geom_line(color = "#0c4c8a") +
    labs(title = paste0("Dendroband Growth 2018 ", i),
         x = "Date 2018",
         y = "Caliper measurements") +
    theme_minimal()
  print(list(dendro))
  dev.off()
}



test <- subset(intra, intra$tag == 10671)
p <- ggplot(test) +
  aes(x = doy, y = measure) +
  geom_line(color = "#0c4c8a") +
  labs(title = paste0("Dendroband Growth 2018 ", i),
       x = "Date 2018",
       y = "Caliper measurements") +
  theme_minimal()
print(p)
dev.off()