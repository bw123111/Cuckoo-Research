############### Land Cover Sampling Data ###############

# library(data.table)
# library(sf)
# library(ggmap)
# library(terra)
# library(raster)
# library(mapview)
# library(tidyverse)
# library(rgdal)
# library(XML)
# library(methods)

packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

############ TO DO ##############

# Reach out to Andy and the Spatial Analysis lab 

# NLCD R package

# try exporting it from Arc with just one field (flat) and then take it into R 
## Might be multi band and it's just mapping one of the bands 


########### Survey Points Data, Bounding Box and Basemap #############
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



#################### Landcover Data ##########################
# read the file in as a spatraster
# Pull into ArcGIS
## 2019
#lcov2 <- raster("E:\\MT_Spatial_Data\\MRLC_Data\\NLCD_2019_Land_Cover_L48_20210604_MRafobliFr55aJu210wR.tiff")
#plot(lcov2)
lcov <- terra::rast("E:\\MT_Spatial_Data\\MRLC_Data\\NLCD_2019_Land_Cover_L48_20210604_MRafobliFr55aJu210wR.tiff")
# visualize it quickly
lcov_subset <- subset(lcov,1)
nlayer(lcov)
plot(lcov)
terra::plotRGB(lcov_subset,r=2, g=3, b=4, main = "2019 Land Cover", stretch = "lin")
#levels(lcov)
#cats(lcov)
## Why so much development?? This land cover type is wrong - should be cultivated crops

# Renaming the categories with FedData
# Working with NLCD data: https://smalltownbigdata.github.io/feb2021-landcover/feb2021-landcover.html
# load in the legend 
legend <- pal_nlcd()
# make a vector of all the values we have in our study area and select those from the legend object

vals <- unique(lcov[[1]])

df <- legend[legend$ID %in% vals$Red,]
# There are none of the values in Red that line up with values in legend - once again becuase it's reading it in as RGB values









# Trying to download again
# Latitude: 
#ymin <- 44.99590
#ymax <- 49.01381
#xmax <- -103.97005
#xmin <- -112.81392
#lvls <- levels(lcov)
#length(lvls)

# lcov2 <- terra::rast("E:\\MT_Spatial_Data\\MRLC_Data_LC_Only\\NLCD_2019_Land_Cover_L48_20210604_wL2onyRXwRRRtc1Y7tTR.tiff")
# # visualize it quickly
# plot(lcov2, main = "2019 Land Cover - New Download")
### Same as before
# the values in the "red" category correspond to the land cover types
## just for funsies, lets look at the others:
## 2016
##lcov16 <- terra::rast("D:\\MT_Spatial_Data\\NLCD_2016_Tree_Canopy_L48_20190831_MRafobliFr55aJu210wR.tiff")
##plot(lcov16)
## 2001
##lcov01 <- terra::rast("D:\\MT_Spatial_Data\\NLCD_2001_Land_Cover_L48_20210604_MRafobliFr55aJu210wR.tiff")
##plot(lcov16)

## Looks like for the land cover data we need to fix the projection system (it is slanted, so we need to reproject it into the montana state plane system)
# we also need to assign values to the land cover data


######### Matrix for Renaming Values ############
#make a matrix of the values and the corresponding land cover
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
levels(lcov)

# now that the numbers in the legend have the correct levels, we just need to change them to be the land cover class
levels(lcov)
lcov[[2]]
# change the levels in the red column to match up with the levels in the cats matrix
##LOOK IN HEBBLEWHITE CODE FOR THIS

# need to find a way to rename the IDs to the values that make sense or line up the cats with the raster file___________________________________

# # OLD from the legend provided (codes are wrong):
# lcov_cats <- read_csv("D:\\MT_Spatial_Data\\NLCD_landcover_legend_2018_12_17_MRafobliFr55aJu210wR.csv")
# # remove unnamed categories
# lcov_cats <- na.omit(lcov_cats)
# lcov_cats






################ Set the boundaries of the survey area in the river valleys ######################

# read in the file
hydro <- st_read("E:\\MT_Spatial_Data\\MT_Lakes_Streams\\hd43a\\hd43a.shp")
#mapview(hydro)
#plot(hydro) - plotting this data takes a very long time
#str(hydro)

# Filter out only the rivers in our study area
names <- c("Milk River", "Missouri River","Yellowstone River","Musselshell River")
proj_hydro <- hydro %>% filter(NAME %in% names)
proj_hydro <- proj_hydro %>% dplyr::select(NAME, geometry)
#str(proj_hydro)
plot(proj_hydro, main = "Study Area Rivers")
crs(proj_hydro)

## Drawing a buffer: "Geometrical operations" in this source: https://cran.r-project.org/web/packages/sf/vignettes/sf1.html
# I want to create a new shapefile that consists of polygons of the buffers around the rivers
buff <- st_buffer(proj_hydro, dist = 1500)
plot(buff, main = "1500 m Buffer Around Rivers")
# what distance to use? 
## google earth measuring distance from river to edge of cottonwood habitat
## 105 m
## 350 seems to get areas close to the river without going to far out of the river valley
#1,500 seems to be the max for areas in the lower missouri and yellowstone
#st_crs(proj_hydro)$units
# now plot these rivers on the land cover data


############# MT LiDAR Data #####################
# Load in the downloads from the MT LiDAR
## Load in CHM data - What is this??
musselshell_CHM <- terra::rast("D:\\Musselshell_Spatial_Data\\CHM.tif")
plot(musselshell_CHM, main = "Musselshell CHM")

## Read in digital surface model
musselshell_DSM <- terra::rast("D:\\Musselshell_Spatial_Data\\DSM.tif")
plot(musselshell_DSM, main = "Musselshell Digital Surface Model")
## Find a way to zoom in on this to see more of what you're working with

## Read in HF DEM
musselshell_HFDEM <- terra::rast("D:\\Musselshell_Spatial_Data\\HFDEM.tif")
plot(musselshell_HFDEM, main = "Musselshell HFDEM") 

## Read in hillshade
musselshell_Hillshade <- terra::rast("D:\\Musselshell_Spatial_Data\\Hillshade.tif")
plot(musselshell_Hillshade, main = "Musselshell Hillshade")

## Read in intensity
musselshell_Intensity <- terra::rast("D:\\Musselshell_Spatial_Data\\Intensity.tif")
plot(musselshell_Intensity, main = "Musselshell Intensity")

# What do these tell us?___________________________________

################## Making a raster stack ##############################
# check the resolution and extent
#res(lcov)
#ext(lcov)
#crs(lcov)
# lets check the levels to this data
#levels(lcov_proj)

# create a mask for your raster stack
# mask_raster <- rast()
# ext(mask_raster) <- c(xmin = xmin_proj, xmax = xmax_proj , ymin = ymin_proj, ymax = ymax_proj)
# res(mask_raster) <- res_wanted
# crs(mask_raster) <- "EPSG:32100"
# mask_raster[]<-0
# plot(mask_raster)

# We want the land cover raster to be in the same projection as the rivers and buffers dataset 
lcov_proj <- lcov %>% terra::project("EPSG:32100", method = "near")
## NOTE: this takes a while 


# testing results:
plot(lcov)
crs(lcov_proj)
ext(lcov_proj)
landcov_extents <- ext(lcov)
#plot(landcov_extents,xlim=c(-))
str(lcov)


########### Put the river data and survey buffers onto the land cover data ######
# Check if the rivers line up with the land cover data 

dev.off()
plot(lcov_proj)
plot(proj_hydro,add = TRUE)








##### 3: Within this area, subset each of the land cover types and establish your unit size #######
# Unit size has to be all within one land cover type - how large are the pixels on the map? This would be the resolution 
# could do it so that your unit size is larger than the pixels but you choose what the majority of pixels are to count witihn that strata and only sample within those locations of the pixel 



#### 4: Implement stratified random sampling within each of the strata #########


############# OLD basemap code ##################
# OLD: Basemap code
# check the differences between lcov and the basemap
# Convert basemap to a raster so that we can make these match
# basemap <- na.omit(basemap_orig)
# basemap <- rast(basemap_orig)
# res_wanted <- res(basemap)
# ext(basemap)
# crs(basemap)
# basemap_proj <- basemap %>% terra::project("EPSG:32100", method = "near")
# # resample both of your raster files to make them match 
# basemap_proj <- resample(basemap,mask_raster, method = "near")
# lcov_proj <- resample(lcov, mask_raster, method = "near")
# plot(basemap_proj)
# crs(basemap_proj)
# ext(basemap)
# basemap_extents <- ext(basemap)

###### CODE GRAVEYARD ####

## Resources https://gis.stackexchange.com/questions/273372/how-to-access-the-attribute-table-of-a-tif-map-in-r
# https://stackoverflow.com/questions/47885065/crop-raster-with-polygon-in-r-error-extent-does-not-overlap
# lcov_test <- crop(lcov, basemap_proj, snap = "near")
# 
# 
# 
# basemap_test <- basemap_proj %>% projectRaster(crs=32100)
# basemap2 <- rast(basemap_proj)
# basemap3 <- basemap2
# basemap3 <- basemap2 %>% projectRaster(from = basemap2, to = basemap3, crs = 32100)


# # lets look at the other land cover data to see if it helps us
# change_index <- xmlParse("D:\\MT_Spatial_Data\\NLCD_2001_2019_change_index_L48_20210604_MRafobliFr55aJu210wR.tiff.aux.xml")
# root_changeIndex <- xmlRoot(change_index)
# print(root_changeIndex[1])


# METHOD 2: change the values in raster data to a polygon
# try extract() function? https://geocompr.robinlovelace.net/raster-vector.html
# look in Mark's labs
#get polygons for home ranges instead of the raster output from the original 
#homerangeRD <- getverticeshr(red.deerUD)
#as.data.frame(homerangeRD)
#class(homerangeRD)
## Would it be easier to make this layer within ArcGIS?

# METHOD 1: get some feature layer and then draw a buffer around it 
## rivers/streams in MT: https://msl.mt.gov/geoinfo/msdi/hydrography/
# Read in this data from the D: MT_Spatial_Data drive - convert the shp files to a .tif or something
## downloading NHDH_MT_Shape

# # read in the file
# rivers <- st_read("D:\\MT_Spatial_Data\\NHDH_MT_Shape_20221025\\NHDWaterbody.shp")
# # should work but it looks like there's a bug in sf
# rivers <- readOGR("D:\\MT_Spatial_Data\\NHDH_MT_Shape_20221025\\NHDWaterbody.shp")
# rivers_new <- st_as_sf(rivers)
# mapview(rivers_new)
# # doesn't look like this will be helpful
# ## TRY READING IN THE OTHER SHAPEFILES


# ggmap(lcov_proj)+geom_sf(data = buff,
#                          inherit.aes=FALSE,
#                          mapping=aes(geometry=geometry, color = NAME))
# # Error ggmap() only works with data types ggmap
# 
# ggplot() + geom_sf(data = buff) + geom_raster(data = lcov_proj)
# # error can't use spatraster