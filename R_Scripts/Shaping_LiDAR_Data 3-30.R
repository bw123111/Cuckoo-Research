#setwd("C:\\Users\\micha\\Documents\\Anna_R_Stuff")
# Load in packages
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap")
source("C:\\Users\\micha\\Documents\\Anna_R_Stuff\\Land_Cover_GRTS\\Scripts\\Install_Load_Packages.R")
load_packages(packages)

#### setup of buff ############
# Read in hydrology layer
hydro <- st_read("E:\\MT_Spatial_Data\\MT_Lakes_Streams\\hd43a\\hd43a.shp")
# Combined study area
names <- c("Missouri River","Yellowstone River","Musselshell River")
proj_hydro <- hydro %>% filter(NAME %in% names)
proj_hydro <- proj_hydro %>% dplyr::select(NAME, geometry)
# Separate by river
hydro_miso <- hydro %>% filter(NAME == "Missouri River") %>% dplyr::select(NAME, geometry)
hydro_mush <- hydro %>% filter(NAME == "Musselshell River") %>% dplyr::select(NAME, geometry)
hydro_yell <- hydro %>% filter(NAME == "Yellowstone River") %>% dplyr::select(NAME, geometry)

buff <- st_buffer(proj_hydro, dist=400)

# Create a buffer layer for each river
buff_miso <- st_buffer(hydro_miso, dist = 400)
buff_mush <- st_buffer(hydro_mush, dist = 400)
buff_yell <- st_buffer(hydro_yell, dist = 400)
######## Read in LCOV ############

mapview(lcov)

# read in land cover data for each river 
lcov_miso <- terra::rast("D:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_MissouriLandcover.tiff")
lcov_mush <- terra::rast("D:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_MusselshellLandcover.tiff")
lcov_yell <- terra::rast("D:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_YellowstoneLandcover.tiff")


# yellowstone LiDAR layers #############################
# dawson_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Hillshade.tif")
# crs(dawson_19) <- "EPSG:32100"
# dawson_19_test <- resample(dawson_19, lcov_yell, method = "near")
# dawson_19_test <- extend(dawson_19_test, lcov_yell, snap = "near")
#writeRaster(dawson_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Dawson19_HillshadeEdited.tif") 
dawson_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Dawson19_HillshadeEdited.tif")

# custer_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Hillshade.tif")
# #plot(custer_19, main = "Musselshell Hillshade")
# crs(custer_19) <- "EPSG:32100"
# # resample it to be a 30x30
# red_custer_19 <- resample(custer_19, lcov_yell, method = "near")
# # extend it to match the buff layer so you can overlay it
# custer_19_test <- extend(red_custer_19, lcov_yell, snap = "near")
# writeRaster(custer_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Custer19_HillshadeEdited.tif") 
custer_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Custer19_HillshadeEdited.tif")

# rosebud_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Hillshade.tif")
# crs(rosebud_19) <- "EPSG:32100"
# rosebud_19_test <- resample(rosebud_19, lcov_yell, method = "near")
# rosebud_19_test <- extend(rosebud_19_test, lcov_yell, snap = "near")
# writeRaster(rosebud_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif") 
rosebud_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif")

# treasure_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\TREASURE_2019_TRcntyQL1\\Hillshade.tif")
# crs(treasure_19) <- "EPSG:32100"
# treasure_19_test <- resample(treasure_19, lcov_yell, method = "near")
# treasure_19_test <- extend(treasure_19_test, lcov_yell, snap = "near")
# writeRaster(treasure_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\TREASURE_2019_TRcntyQL1\\Treasure19_HillshadeEdited.tif") 
treasure_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif")

# park_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\PARK_2020_PACntyQL2\\Hillshade.tif")
# crs(park_19) <- "EPSG:32100"
# park_19_test <- resample(park_19, lcov_yell, method = "near")
# park_19_test <- extend(park_19_test, lcov_yell, snap = "near")
# writeRaster(park_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\PARK_2020_PACntyQL2\\Park19_HillshadeEdited.tif") 
park_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\PARK_2020_PACntyQL2\\Park19_HillshadeEdited.tif")


# combine LiDAR layers
lidar_yell <- sum(dawson_19,custer_19, rosebud_19,treasure_19,park_19,na.rm=TRUE)
lidar_yell2 <- sum(dawson_19,custer_19, rosebud_19,treasure_19,na.rm=TRUE)

plot(lcov_yell)
plot(lidar_yell, add = TRUE)
# this works

# old plotting code to validate the combination against
# plot(lcov_yell, main = "Standard Plot")
# plot(custer_19, add = TRUE)
# plot(dawson_19, add=TRUE)
# plot(rosebud_19, add=TRUE)
# plot(treasure_19, add=TRUE)


# writeRaster(lidar_yell, "E:\\MT_Spatial_Data\\MT_LiDAr\\Yellowstone_LiDARDataExtent.tif")
#writeRaster(lidar_yell2, "E:\\MT_Spatial_Data\\MT_LiDAr\\Yellowstone_LiDARDataExtent_NoPark.tif")
# 
lcov_yell_reduced <- mask(lcov_yell,lidar_yell2)
plot(lcov_yell_reduced)
writeRaster(lcov_yell_reduced,"E:\\MT_Spatial_Data\\For_GRTS\\\\NLCD_2019_YellowstoneLandcover_MaskedToLidar_NoPark.tiff")
# all LiDAR for Yellowstone is done

# Missouri River LiDAR ##################################
# valley_18 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\VALLEY_2018_VAcnty\\Hillshade.tif")
# crs(valley_18) <- "EPSG:32100"
# valley_18_test <- resample(valley_18, lcov_miso, method = "near")
# valley_18_test <- extend(valley_18_test, lcov_miso, snap = "near")
# plot(lcov_miso)
# plot(valley_18_test, add = TRUE)
# writeRaster(valley_18_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\VALLEY_2018_VAcnty\\Valley18_HillshadeEdited.tif") 
valley_18 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\VALLEY_2018_VAcnty\\Valley18_HillshadeEdited.tif")

# phillips_18 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\PHILLIPS_2018_PHcntyS\\Hillshade.tif")
# crs(phillips_18) <- "EPSG:32100"
# phillips_18_test <- resample(phillips_18, lcov_miso, method = "near")
# phillips_18_test <- extend(phillips_18_test, lcov_miso, snap = "near")
# plot(lcov_miso)
# plot(phillips_18_test, add = TRUE)
# writeRaster(phillips_18_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\PHILLIPS_2018_PHcntyS\\Phillips19_HillshadeEdited.tif") 
phillips_18 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\PHILLIPS_2018_PHcntyS\\Phillips19_HillshadeEdited.tif")


# dummy raster for Upper Missouri River Breaks National Monument LiDAR data that I can't access right now
#Making a Dummy Raster https://rspatial.org/spatial/8-rastermanip.html
monument_refuge <- terra::rast(ncol=36,nrow=18,xmin=-109.880833,xmax=-108.288889,ymin=47.551111,ymax=47.825278)

# res(monument_refuge) <- 30
# plot(monument_refuge,main = "PRE Coordinate Projection")
#monument_refuge <- monument_refuge %>% terra::project("EPSG:3210", method = "near")
crs(monument_refuge) <- "+proj=lcc +lat_0=44.25 +lon_0=-109.5 +lat_1=49 +lat_2=45 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs"
crs(monument_refuge) <- "EPSG:32100"
set.seed(0)
values(monument_refuge) <- runif(ncell(monument_refuge))
plot(monument_refuge,main="Check")

plot(lcov_miso)
lines(x=71930,y=NULL,col="red")
plot(monument_refuge)
plot(phillips_18)

# extend the dummy raster
monument_refuge_test <- resample(monument_refuge, lcov_miso, method = "near")
monument_refuge_test <- extend(monument_refuge_test, lcov_miso, snap = "near")
#this one isn't plotting
plot(monument_refuge_test,main="Post Resamp and Extend")
plot(monument_refuge_test)
#writeRaster(monument_refuge_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\Placeholder_Monument_Refuge_LiDAR_Area.tif") 

# still isn't showing up on the lcov layer???? something weird going on here
plot(lcov_miso, main = "Standard Plot")
#plot(monument_refuge, add = TRUE)
# not visualizing in the right area? change the extent 
plot(valley_18, add=TRUE)
plot(phillips_18, add=TRUE)
plot(monument_refuge_test,add=TRUE)

# combine the rasters
lidar_miso <- sum(valley_18,phillips_18,monument_refuge_test,na.rm = TRUE)
plot(lcov_miso)
plot(lidar_miso,add=TRUE)

# export the raster
writeRaster(lidar_miso, "E:\\MT_Spatial_Data\\MT_LiDAr\\Missouri_LiDARDataExtent.tif")

lcov_miso_reduced <- mask(lcov_miso,lidar_miso)
plot(lcov_miso_reduced)
# writeRaster(lcov_miso_reduced,"E:\\MT_Spatial_Data\\For_GRTS\\\\NLCD_2019_MissouriLandcover_MaskedToLidarNoDummy.tiff")


# Musselshell River LiDAR #######################################

# wheatland_17 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\WHEATLAND_2017_MshellRvrTribs\\Hillshade.tif")
# crs(wheatland_17) <- "EPSG:32100"
# wheatland_17_test <- resample(wheatland_17, lcov_miso, method = "near")
# wheatland_17_test <- extend(wheatland_17_test, lcov_miso, snap = "near")
# writeRaster(wheatland_17_test, "D:\\MT_Spatial_Data\\MT_LiDAr\\WHEATLAND_2017_MshellRvrTribs\\Wheatland19_HillshadeEdited.tif") 
wheatland_17 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\WHEATLAND_2017_MshellRvrTribs\\Wheatland19_HillshadeEdited.tif")

# lcov_mush_reduced <- mask(lcov_mush,wheatland_17)
# plot(lcov_mush_reduced)
# 
# writeRaster(lcov_mush_reduced,"E:\\MT_Spatial_Data\\For_GRTS\\\\NLCD_2019_MusselshellLandcover_MaskedToLidar.tiff")

#Good to go



# Code Graveyard ###################
# merge_test <- merge(dawson_19,custer_19)
# merge2 <- merge(merge_test,rosebud_19)
# merge3 <- merge(merge_test,treasure_19)
# 
# plot(lcov_yell)
# plot(merge3, add = TRUE)
# # this works!
# # you can only merge two at a time?
# 
# 
# # try a spatraster collection?
# rlist <- list(dawson_19,custer_19,rosebud_19,treasure_19)
# collect_rasts <- sprc(rlist)
# merge_test2 <- merge(collect_rasts)
# 
# plot(lcov_yell)
# plot(merge_test2,add=TRUE)
# # can't get these to combine??
# 
# lidar_yell <- c(dawson_19_test,custer_19_test,rosebud_19_test,treasure_19_test)
# # export this as a shapefile
# ext(lidar_yell)
# ext(lcov_yell)
# plot(lidar_yell)
# plot(lcov_yell, main = "Combo Plot")
# plot(lidar_yell, add = TRUE)
# # why isn't this combining like I want it to? maybe its a relic of plotting it?
# # this isn't plotting right?


