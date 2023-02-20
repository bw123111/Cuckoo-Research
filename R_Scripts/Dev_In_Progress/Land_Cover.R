############### Land Cover Sampling Data ###############

library(data.table)
library(sf)
library(ggmap)
library(terra)
library(raster)
library(mapview)
library(tidyverse)
library(rgdal)
library(XML)
library(methods)

########### 1: Load in the data and visualize it #############
# load in locations data
locs_dat <- fread(".\\Data\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
## Don't open a shapefile with fread
# Do I need to remove NAs or can I do that later? Missing values in coordinates not allowed
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) 


# Bounding box coordinates from MRLC download 2/15:
ymin_proj <- 44.94910
ymax_proj <- 49.03619
xmin_proj <- -112.35849
xmax_proj <- -103.97674

# pull up the basemap to see if you have the right bounding box area
#have to give st_bbox an object
proj_bound <- st_bbox(locs_sf)
# or not?
# proj_bound <- st_bbox() no you do have to give it an object
# lets reset the boundaries to what we want, the order is"
#xmin, ymin, xmax, ymax
proj_bound[1] <- xmin_proj
proj_bound[2] <- ymin_proj
proj_bound[3] <- xmax_proj
proj_bound[4] <- ymax_proj

# let's now grab a basemap from stamenmap just to check our bounding box is set up correctly
basemap_orig <- get_stamenmap(as.numeric(proj_bound),maptype = "terrain-background", zoom=8)

# take a look:
ggmap(basemap_orig)
ggmap(basemap_orig)+geom_sf(data = locs_sf,
                            inherit.aes=FALSE,
                            mapping=aes(geometry=geometry, color = organization))
# Looks good!



# Next lets take a look at the landcover data
# read the file in as a spatraster
## 2019
lcov <- terra::rast("D:\\MT_Spatial_Data\\NLCD_2019_Land_Cover_L48_20210604_MRafobliFr55aJu210wR.tiff")
# visualize it quickly
plot(lcov)
## just for funsies, lets look at the others:
## 2016
lcov16 <- terra::rast("D:\\MT_Spatial_Data\\NLCD_2016_Tree_Canopy_L48_20190831_MRafobliFr55aJu210wR.tiff")
plot(lcov16)

lcov01 <- terra::rast("D:\\MT_Spatial_Data\\NLCD_2001_Land_Cover_L48_20210604_MRafobliFr55aJu210wR.tiff")
plot(lcov16)

## Looks like for the land cover data we need to fix the projection system (it is slanted, so we need to reproject it into the montana state plane system)
# we also need to assign values to the land cover data
# get this from the legend:
lcov_cats <- read_csv("D:\\MT_Spatial_Data\\NLCD_landcover_legend_2018_12_17_MRafobliFr55aJu210wR.csv")
# remove unnamed categories
lcov_cats <- na.omit(lcov_cats)
lcov_cats
# make a matrix of the values and the corresponding land cover
# find out how many elements we need
list <- c(0,70,209, 222, 217,235, 171, 179, 104, 28, 181, 204, 223, 220, 184, 108)
length(list)
# create an empty matrix
cats <- matrix(nrow=16, ncol=2)
colnames(cats) <- c("ID","Landcover")
# input the corresponding values from the dataframe
cats[,1] <- c(0,70,209, 222, 217,235, 171, 179, 104, 28, 181, 204, 223, 220, 184, 108)
#match these up with the values from the land cover
cats[,2] <- c("null","open_water","ice_snow","developed_open","developed_low","developed_med","developed_high","barren","deciduous_forest","evergreen_forest","mixed_forest","shrub_scrub","grasslands_herbaceous","pasture_hay","woody_wetlands","herbaceous_wetlands")

# now that the numbers in the legend have the correct levels, we just need to change them to be the land cover class
levels(lcov)

# need to find a way to rename the IDs to the values that make sense or line up the cats with the raster file___________________________________

# lets look at the other land cover data to see if it helps us
change_index <- xmlParse("D:\\MT_Spatial_Data\\NLCD_2001_2019_change_index_L48_20210604_MRafobliFr55aJu210wR.tiff.aux.xml")
root_changeIndex <- xmlRoot(change_index)
print(root_changeIndex[1])




###### making a raster stack #######
# check the resolution and extent
res(lcov)
ext(lcov)
crs(lcov)
# lets check the levels to this data
levels(lcov_proj)

# check the differences between lcov and the basemap
# Convert basemap to a raster so that we can make these match
basemap <- na.omit(basemap_orig)
basemap <- rast(basemap_orig)
res_wanted <- res(basemap)
ext(basemap)
crs(basemap)


# make the resolution and extent match the basemap 
# create a mask for your raster stack
mask_raster <- rast()
ext(mask_raster) <- c(xmin = xmin_proj, xmax = xmax_proj , ymin = ymin_proj, ymax = ymax_proj)
res(mask_raster) <- res_wanted
crs(mask_raster) <- "EPSG:32100"
mask_raster[]<-0
plot(mask_raster)

# they are in different coordinate systems, we want them to both be 32100 so that we can make a raster stack
lcov_proj <- lcov %>% terra::project("EPSG:32100", method = "near")
## NOTE: this takes a while 
basemap_proj <- basemap %>% terra::project("EPSG:32100", method = "near")
# resample both of your raster files to make them match 
basemap_proj <- resample(basemap,mask_raster, method = "near")
lcov_proj <- resample(lcov, mask_raster, method = "near")

# testing results:
plot(lcov)
plot(basemap_proj)
crs(basemap_proj)
plot(basemap_proj)

# did correctly crop it to the right area but there's nothing on the map - we first need to reprojuect 
# Didn't reproject them
crs(basemap_proj)
crs(lcov_proj)
crs(lcov)

ext(lcov_proj)
ext(basemap_proj)
# map the spatial extents of each 

# rename the levels in the landcover database
plot(lcov_proj)
plot(basemap_proj)
landcov_extents <- ext(lcov)
basemap_extents <- ext(basemap)

ext(lcov)
ext(basemap)

#plot(landcov_extents,xlim=c(-))
str(lcov)


###### 2: Set the boundaries of the survey area in the river valleys ##########
## Would it be easier to make this layer within ArcGIS?

# METHOD 1: get some feature layer and then draw a buffer around it 
## rivers/streams in MT: https://msl.mt.gov/geoinfo/msdi/hydrography/
# Read in this data from the D: MT_Spatial_Data drive - convert the shp files to a .tif or something
## downloading NHDH_MT_Shape

# read in the file
rivers <- st_read("D:\\MT_Spatial_Data\\NHDH_MT_Shape_20221025\\NHDWaterbody.shp")
# should work but it looks like there's a bug in sf
rivers <- readOGR("D:\\MT_Spatial_Data\\NHDH_MT_Shape_20221025\\NHDWaterbody.shp")
rivers_new <- st_as_sf(rivers)
mapview(rivers_new)
# doesn't look like this will be helpful
## TRY READING IN THE OTHER SHAPEFILES

# METHOD 2: change the values in raster data to a polygon
# try extract() function? https://geocompr.robinlovelace.net/raster-vector.html
# look in Mark's labs
#get polygons for home ranges instead of the raster output from the original 
#homerangeRD <- getverticeshr(red.deerUD)
#as.data.frame(homerangeRD)
#class(homerangeRD)



## Drawing a buffer: "Geometrical operations" in this source: https://cran.r-project.org/web/packages/sf/vignettes/sf1.html


##### 3: Within this area, subset each of the land cover types and establish your unit size #######
# Unit size has to be all within one land cover type - how large are the pixels on the map? This would be the resolution 
# could do it so that your unit size is larger than the pixels but you choose what the majority of pixels are to count witihn that strata and only sample within those locations of the pixel 



#### 4: Implement stratified random sampling within each of the strata #########




###### CODE GRAVEYARD ####
lcov_test <- crop(lcov, basemap_proj, snap = "near")



basemap_test <- basemap_proj %>% projectRaster(crs=32100)
basemap2 <- rast(basemap_proj)
basemap3 <- basemap2
basemap3 <- basemap2 %>% projectRaster(from = basemap2, to = basemap3, crs = 32100)