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

coordinates(bands_2018) <- c("NAD83_X", "NAD83_Y")

plot(scbi_plot)+
  plot(deer, add = T, border = "black")+
  plot(streams, add = T, col = "blue")+
  plot(roads, add = T, col = "#996600", lty=2)+
  plot(survey_areas, add=T, col = "#000000", lwd=2)+
  plot(bands_2018, add = T, pch = 21, cex = 0.5)+
  text(bands_2018, labels=bands_2018$tag, cex=0.6, pos = 4) 

##need to find a way to not have overlapping labels. It seems the best way to do this will be in ggplot
ggplot() +
  geom_polygon(data=counties, aes(x=long, y=lat, group=group))+  
  geom_point(data=mapdata, aes(x=x, y=y), color="red")


#














library(ggmap)
test <- get_map(location=c(lon=mean(bands_2018$lon, na.rm=TRUE), lat=mean(bands_2018$lat, na.rm=TRUE)), maptype="terrain", source="osm")


map <- leaflet() %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>% 
  addMarkers(data=bands_2018, weight=2, fill=TRUE, fillColor="blue", fillOpacity = 0.25) %>%
  addScaleBar(position = "bottomleft") %>%
  addLayersControl(
    baseGroups = c("Map", "Topo", "Relief"),
    options = layersControlOptions(collapsed = FALSE)
  )














##it is worth mentioning that the fgeo package does indeed (easily) map data from the dendrobands survey. However, as it was built to specifically accommodate the data that Suzanne sends out from the main censuses, the package mainly works with data that is in a very specific format (e.g. having gx and gy as opposed to what we find most useful of lx and ly).

##this is being left here for reference.

devtools::install_github("forestgeo/fgeo", upgrade = "never")

bands_2018 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2018.csv")

map_bands <- bands_2018 %>%
  filter(survey.ID >= 2018.14)

#autoplot(sp(map_bands))


         