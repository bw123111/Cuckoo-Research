# reading in shapefile of cuckoo locations

library(ks)
library(here)
library(plotrix)
library(lattice)
#library(dehabitatHR)
## Error: no package called this?
library(maptools)
library(mapview)
library(ggplot2)
library(colorRamps)
library(sf)
library(terra)
library(tmap)
library(stars)
library(dplyr)
library(ggmap)
library(data.table)
library(tidyverse)


# Load in location file
## Method 1: read it directly into a spatial object
locs <- st_read("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Thesis_ArcGIS_Files\\Cuckoo_Montitoring_Locations\\2022_AllSurveyPoints.shp")
# Look at the structure
str(locs)
# Check the projection 
crs(locs, proj =TRUE)
## it says the projection is longlat

# Method 2: read data into a data table and then make it into a spatial object
# giving a weird 
locs_dat <- fread("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Thesis_ArcGIS_Files\\Cuckoo_Montitoring_Locations\\2022_AllSurveyPoints.shp")
## Don't open a shapefile with fread

# project it
## MT state plane - lambert system?
#crs(locs) <- "+proj=lambert +datum=WGS84 +no_defs"
# this is throwing an error - how do you project this?

#Make a plot using base plot
base::plot(locs$long,locs$lat,col=c("red","blue","green","orange")[locs$organization],ylab="Latitude",xlab="Longitude")
#legend(555000,5742500,unique(locs$organization),col=c("blue","red"),pch=1)
# not showing up on the map 

# for quickly visualizing
mapview(locs)

locations_plot <- ggmap(basemap, extent="normal") + geom_sf(data=locs) 
#, mapping=aes(fill=organization),color=c("red","orange","green","blue")
locations_plot
           
# set bounding box
MT_bound <- st_bbox(locs)
#xmin, ymin, xmax, ymax

#MT_bound[1] <- MT_bound[1]-5# assign it a number 
# might require you to put names in 
## can go through and add buffer

# load in background map
basemap <- get_stamenmap(as.numeric(MT_bound),maptype = "terrain-background", zoom=6)
#can also set the zoom level (10 default)
#http://maps.stamen.com/terrain-background/#9/47.0010/-109.6450

# caltopo for mapping online 