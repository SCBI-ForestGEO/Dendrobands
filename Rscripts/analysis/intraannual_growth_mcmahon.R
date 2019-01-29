# script to work with dendrobands in format to match McMahon's code
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4314258/

setwd("E:/Github_SCBI/Dendrobands/data")
band18 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2018.csv")

library(chron)
band18$doy <- paste0(band18$month, sep="/", band18$day, sep="/", band18$year)

intra <- subset(band18, band18$intraannual == 1)

tagsintra <- c(unique(intra$tag))
surveys <- c(unique(intra$survey.ID))

intra$doy <- as.Date(intra$doy, format="%m/%d/%Y")
intra$doy <- factor(intra$doy, ordered=TRUE)

intraannual <- split(intra, f=c(intra$tag))




library(ggplot2)

##this code makes graphs for every dendroband individual, with sub-graphs for those trees with multiple stems. The next bit is to do this same graph but be able to show the dendroband measurements but in dbh changes.
pdf(file = "Dendroband_caliper_growth_2018.pdf")
for (i in names(intraannual)){
  
  dendro <- intraannual[[i]]
  
  q <- ggplot(data = dendro) +
    aes(x = doy, y = measure, group=1) +
    geom_line(color = "#0c4c8a") +
    labs(title = paste0("Dendroband Growth 2018 ",sep="_", i),
         x = "Date 2018",
         y = "Caliper measurements") +
    theme_minimal() +
    facet_wrap(c("tag", "stemtag"), labeller="label_both")
  print(q)
}
dev.off()



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