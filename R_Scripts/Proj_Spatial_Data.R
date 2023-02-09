# reading in shapefile of cuckoo locations

###### Needs more digging into this #####

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
#install.packages("tidyterra")
library(tidyterra) ## has the functions geom_spatraster() and geom_spatraster_contour()
library(ggspatial) ## used for north arrow and scale bar
library(ggnewscale) ## allows us to plot rasters with different colorscales in ggplot.
library(leaflet) # for using WMS files in R


# Load in location file
## Method 1: read it directly into a spatial object
locs <- st_read(".\\Data\\Spatial_Data\\2022_AllSurveyPoints.shp")
# Look at the structure
str(locs)
# Check the projection 
crs(locs, proj =TRUE)
## it says the projection is longlat

# Method 2: read data into a data table and then make it into a spatial object
locs_dat <- fread(".\\Data\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
## Don't open a shapefile with fread
# Do I need to remove NAs or can I do that later? Missing values in coordinates not allowed
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) 

class(locs_sf)
crs(locs_sf)
# no coordinate system
locs_sf <- locs_sf %>% st_set_crs(32100) 

# project it
## MT state plane - lambert system?
#crs(locs) <- "+proj=lambert +datum=WGS84 +no_defs"
# this is throwing an error - how do you project this?

# for quickly visualizing
mapview(locs_sf)

ggplot() +
  geom_sf(data = locs_sf)

           
# Get a basemap from stamenmaps

# set bounding box
MT_bound <- st_bbox(locs)
MT_bound <- st_bbox(st_buffer(locs_sf, dist = .1))
# units?
#xmin, ymin, xmax, ymax

#MT_bound[1] <- MT_bound[1]-5# assign it a number 
# might require you to put names in 
## can go through and add buffer

# load in background map
basemap <- get_stamenmap(as.numeric(MT_bound),maptype = "terrain-background", zoom=6)
#can also set the zoom level (10 default)
#http://maps.stamen.com/terrain-background/#9/47.0010/-109.6450

str(basemap)
basemap_rast <- rast(basemap)
# plot this to check how it looks
plot(basemap_rast)
class(basemap)

# project it to match
basemap_proj <- basemap %>%
  projectRaster(32100) 



# Put the basemap with the data
ggplot() +
  geom_sf(data = locs_sf) +
  geom_raster(data = basemap)

crs(basemap)

ggmap(basemap)+
  geom_sf(data = locs_sf,
          inherit.aes=FALSE,
          mapping=aes(geometry=geometry)) # specify the geometry within the sf file you're reading in 
# inherit.aes tells it to bring the aesthetics in from the previously specified sf, not basemap 
# need to edit bounding box 



##### Using leaflet to read in WMS files #####
#https://inbo.github.io/tutorials/tutorials/spatial_wms_services/
# More info on leaflet
#https://rspatial.org/terra/spatial/9-maps.html
land_cov <- "http://www.opengis.net/wms https://www.mrlc.gov/geoserver/schemas/wms/1.3.0/capabilities_1_3_0.xsd"

leaflet() %>% 
  setView(lng=-107.305, lat=46.27724, zoom=15) %>%
  addWMSTiles(
    land_cov,
    layers="NLCD_2019_Land_Cover_L48"
  )



# code graveyard
#locations_plot <- ggmap(locs_sf, extent="normal") + geom_sf(data=locs) 
#, mapping=aes(fill=organization),color=c("red","orange","green","blue")
#locations_plot <- ggmap(basemap, extent="normal") + geom_sf(data=locs) 
#locations_plot