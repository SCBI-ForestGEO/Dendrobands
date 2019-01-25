# code for making dendroband maps
##this can potentially be done with the fgeo package for the main census data. It is not being used here, but is referenced at bottom.

setwd("E:/Github_SCBI/Dendrobands/data")

#we are using dendro_trees for this code as opposed to "scbi.dendroAll_YEAR.csv" because 1. dendro_trees reflects the data in the all of the YEAR files and 2. dendro_trees has the necessary mapping information in lx/ly, gx/gy, NAD83X/Y, AND lat/lon in decimal degrees.

dendro_trees <- read.csv("E:/Github_SCBI/Dendrobands/data/dendro_trees.csv")

#to start off, filter by all the trees that are alive as of the end of last year's fall survey.
bands_2018 <- dendro_trees[is.na(dendro_trees$mortality.year), ]
bands_2018 <- bands_2018[complete.cases(bands_2018[, c("NAD83_X", "NAD83_Y")]),] # remove one tree with missing coordinates
##this should be fixed when 131352 is found with 2018 data!!!!


library(ggplot2)
library(rgdal)
scbi_plot <- readOGR("V:/SIGEO/GIS_data/20m_grid.shp")
deer <- readOGR("V:/SIGEO/GIS_data/deer_exclosure_2011.shp")
roads <- readOGR("V:/SIGEO/GIS_data/SCBI_roads_edits.shp")
streams <- readOGR("V:/SIGEO/GIS_data/SCBI_streams_edits.shp")
survey_areas <- readOGR("V:/SIGEO/GIS_data/dendroband surveys/dendroband (bi)annual/biannual_survey_areas.shp")

#convert all shp to dataframe so that it can be used by ggplot
library(broom)
scbi_plot_df <- tidy(scbi_plot)
deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
survey_areas_df <- tidy(survey_areas)

library(ggrepel)
library(sf)

map <- ggplot() +
  geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group))+
  geom_path(data=roads_df, aes(x=long, y=lat, group=group), 
            color="#996600", linetype=2)+
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color="blue")+
  geom_path(data=survey_areas_df, aes(x=long, y=lat, group=group), size=1.5)+
  geom_point(data=bands_2018, aes(x=NAD83_X, y=NAD83_Y), shape=19)+
  geom_text(data=bands_2018, aes(x=NAD83_X, y=NAD83_Y, label=tag), 
            size=3, hjust=1.25, nudge_y=-1, nudge_x=1, check_overlap=TRUE)+
  labs(subtitle="Dendrobands_Biannual_2019")+
  coord_sf(crs = "crs = +proj=merc", xlim=c(747350,747800), ylim=c(4308500, 4309125))

#x and y give the x/yposition on the plot; sprintf says to add 0 for single digits, the x/y=seq(...,length.out) says fit the label within these parameters, fitting the length of the label evenly.
##

rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1) , size=5.25, color="black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size=5.4, color="black")

#now, we add the row and column labels
##to get rid of the graticules (the lat/lon labels and lines), you need to have both "theme" calls in the following function. 
library(ggthemes)

pdf("dendroband_biannual_map.pdf", width = 8.5, height=11)
map + 
  rows + 
  cols +
  theme_map()+
  theme(panel.grid.major = element_line(colour = 'transparent'))
dev.off()

  


#############################################################################
#the below code makes a basic plot as well, but overlapping labels (with each other) were an issue.
##need to find a way to not have overlapping labels. It seems the best way to do this is in ggplot

coordinates(bands_2018) <- c("NAD83_X", "NAD83_Y")

plot(scbi_plot)+
  plot(deer, add = T, border = "black")+
  plot(streams, add = T, col = "blue")+
  plot(roads, add = T, col = "#996600", lty=2)+
  plot(survey_areas, add=T, col = "#000000", lwd=2)+
  plot(bands_2018, add = T, pch = 21, cex = 0.5)+
  text(bands_2018, labels=bands_2018$tag, cex=0.6, pos = 4) 

#the immediate code below is another way to add text, but does so only for ggplot when calling coord_cartesian

library(grid)
grob_hor <- grobTree(textGrob("01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20",x=0.1125, y=0.025, hjust=0, vjust=0, rot=1.1, gp=gpar(col="black", fontsize=12, lwd=0.5, lineheight=0.9)))

grob_vert <- grobTree(textGrob("01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32",x=0.1, y=0.035, hjust=0, vjust=0.1, rot=91.5, gp=gpar(col="black", fontsize=11.75)))


##it is worth mentioning that the fgeo package does indeed (easily) map data from the dendrobands survey. However, as it was built to specifically accommodate the data that Suzanne sends out from the main censuses, the package mainly works with data that is in a very specific format (e.g. having gx and gy as opposed to what we find most useful of lx and ly).

##this is being left here for reference.

devtools::install_github("forestgeo/fgeo", upgrade = "never")

bands_2018 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2018.csv")

map_bands <- bands_2018 %>%
  filter(survey.ID >= 2018.14)

#autoplot(sp(map_bands))


         