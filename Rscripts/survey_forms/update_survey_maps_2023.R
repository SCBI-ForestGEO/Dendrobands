######################################################
# Purpose: Create field maps for dendroband surveys
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created January 2019
# Updated by: Jess Shue - shuej@si.edu March 2023
######################################################

##this can potentially be done with the fgeo package for the main census data. It is not being used here, but is referenced at bottom.

#we are using dendro_trees for this code as opposed to "scbi.dendroAll_YEAR.csv" because 
#1. scbi.dendroAll_BLANK.csv reflects the current trees in the biannual and intrannual survey
#2. dendro_trees has the necessary mapping information in lx/ly, gx/gy, NAD83X/Y, AND lat/lon in decimal degrees.

##THUS make sure dendro_trees and scbi.dendroAll_BLANK are updated when making new maps

dendro_trees <- read.csv("data/dendro_trees.csv")

# reduce to tag, stemtag, NAD83_X and NAD83_Y to add coordinates to current tree list
dendro_trees <- dendro_trees[ , c(1, 2, 23, 24)]

#import the SCBI.dendroAll data to have a list of current trees
bands_2023 <- read.csv("data/scbi.dendroAll_BLANK.csv")

# add coordinates to tree list
bands_2023 <- merge(bands_2023, dendro_trees, by = c("tag", "stemtag"))

library(ggplot2)
library(rgdal)# will be retired at the end of 2023; need to transition to sf/stars/terra
library(broom) #for the tidy function
library(sf) #for mapping
library(ggthemes) #for removing graticules when making pdf


########### Add existing GIS shapefiles #####################

## the source for these files is the ForestGEO-Data repo in Github
scbi_plot <- readOGR("C:/Users/jessh/Documents/GitHub/SCBI/SCBI-ForestGEO-Data/spatial_data/shapefiles/20m_grid.shp")
deer <- readOGR("C:/Users/jessh/Documents/GitHub/SCBI/SCBI-ForestGEO-Data/spatial_data/shapefiles/deer_exclosure_2011.shp")
roads <- readOGR("C:/Users/jessh/Documents/GitHub/SCBI/SCBI-ForestGEO-Data/spatial_data/shapefiles/SCBI_roads_clipped_to_plot.shp")
streams <- readOGR("C:/Users/jessh/Documents/GitHub/SCBI/SCBI-ForestGEO-Data/spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_full.shp")
contour_10m <- readOGR("C:/Users/jessh/Documents/GitHub/SCBI/SCBI-ForestGEO-Data/spatial_data/shapefiles/contour10m_SIGEO_clipped.shp")

## the source for these files is in the dendrobands repo
survey_areas <- readOGR("resources/maps/shapefiles/biannual_survey_areas.shp")
NS_divide <- readOGR("resources/maps/shapefiles/NS_divide1.shp")

#convert all shp to dataframe so that it can be used by ggplot
#if tidy isn't working, can also do: xxx_df <- as(xxx, "data.frame")
scbi_plot_df <- tidy(scbi_plot)
deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
survey_areas_df <- tidy(survey_areas)
NS_divide_df <- tidy(NS_divide)
contour_10m_df <- tidy(contour_10m)

#x and y give the x/yposition on the plot; sprintf says to add 0 for single digits, the x/y=seq(...,length.out) says fit the label within these parameters, fitting the length of the label evenly.
##this code adds the row and column numbers based on coordinates
rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1) , size=5.25, color="black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size=5.4, color="black")

#these are the numbers for the survey areas, following the survey_area shp border areas
section1 <- annotate("text", x= 747730, y= 4308705, label = "1", size=6, fontface=2)
section2 <- annotate("text", x= 747630, y= 4308683, label = "2", size=6, fontface=2)
section3 <- annotate("text", x= 747450, y= 4308717, label = "3", size=6, fontface=2)
section4 <- annotate("text", x= 747445, y= 4309000, label = "4", size=6, fontface=2)
section5 <- annotate("text", x= 747567, y= 4308920, label = "5", size=6, fontface=2)
section6 <- annotate("text", x= 747687, y= 4308923, label = "6", size=6, fontface=2)
section7 <- annotate("text", x= 747520, y= 4309100, label = "7", size=6, fontface=2)
section8 <- annotate("text", x= 747605, y= 4309100, label = "8", size=6, fontface=2)
section9 <- annotate("text", x= 747725, y= 4309045, label = "9", size=6, fontface=2)

#biannual survey map ####
map <- ggplot() +
  geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group))+
  geom_path(data=roads_df, aes(x=long, y=lat, group=group), 
            color="#996600", linetype=2)+
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color="blue")+
  geom_path(data=survey_areas_df, aes(x=long, y=lat, group=group), linewidth=1.1)+
  geom_point(data=bands_2023, aes(x=NAD83_X, y=NAD83_Y), shape=19)+
  geom_text(data=bands_2023, aes(x=NAD83_X, y=NAD83_Y, label=tag), 
            size=3, hjust=1.25, nudge_y=-1, nudge_x=1, check_overlap=TRUE)+
  labs(title="Dendrobands_Biannual_2023")+
  theme(plot.title=element_text(vjust=0.1))


#now, we add the row and column labels
##to get rid of the graticules (the lat/lon labels and lines), you need to have both "theme" calls in the following function. 

pdf("resources/maps/dendroband_biannual_map.pdf", width = 8.5, height=11)
map + 
  rows + 
  cols +
  section1 + section2 + section3 + section4 + section5 + section6 + section7 + section8 + section9 +
  theme_map()+
  theme(panel.grid.major = element_line(colour = 'transparent'))
dev.off() #when printing, choose "fit to page"

#intraannual survey map ####
intra <- subset(bands_2023, intraannual==1)

map_intra <- ggplot() +
  geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group))+
  geom_path(data=roads_df, aes(x=long, y=lat, group=group), 
            color="#996600", linetype=2)+
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color="blue")+
  geom_path(data=NS_divide_df, aes(x=long, y=lat, group=group), linewidth=1.1, color="red")+
  geom_path(data=contour_10m_df, aes(x=long, y=lat, group=group), linetype=3)+
  geom_path(data=deer_df, aes(x=long, y=lat, group=group))+
  geom_point(data=intra, aes(x=NAD83_X, y=NAD83_Y), shape=19)+
  geom_text(data=intra, aes(x=NAD83_X, y=NAD83_Y, label=tag), 
            size=3, hjust=1.25, nudge_y=-1, nudge_x=1, check_overlap=TRUE)+
  labs(title="Dendrobands_Intraannual_2023")


#north and south labels
north <- annotate(geom="text", x=747793, y=4308810, label="N", colour="black", size=5, fontface=2)
south <- annotate(geom="text", x=747795, y=4308775, label="S", colour="black", size=5, fontface=2)

pdf("resources/maps/dendroband_intraannual_map.pdf", width = 8.5, height=11)
map_intra + 
  rows + 
  cols +
  north + south +
  theme_map()+
  theme(panel.grid.major = element_line(colour = 'transparent'))
dev.off() #when printing, choose "fit to page"

