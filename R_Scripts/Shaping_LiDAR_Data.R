#setwd("C:\\Users\\micha\\Documents\\Anna_R_Stuff")
# Load in packages
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


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


# read in land cover data for each river 
lcov_miso <- terra::rast("E:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_MissouriLandcover.tiff")
lcov_mush <- terra::rast("E:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_MusselshellLandcover.tiff")
lcov_yell <- terra::rast("D:\\MT_Spatial_Data\\For_GRTS\\NLCD_2019_YellowstoneLandcover.tiff")


# yellowstone LiDAR layers
# dawson_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Hillshade.tif")
# crs(dawson_19) <- "EPSG:32100"
# dawson_19_test <- resample(dawson_19, lcov_yell, method = "near")
# dawson_19_test <- extend(dawson_19_test, lcov_yell, snap = "near")
#writeRaster(dawson_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Dawson19_HillshadeEdited.tif") 
dawson_19 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\Dawson_2019_DawsonQL1\\Dawson19_HillshadeEdited.tif")

# custer_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Hillshade.tif")
# #plot(custer_19, main = "Musselshell Hillshade")
# crs(custer_19) <- "EPSG:32100"
# # resample it to be a 30x30
# red_custer_19 <- resample(custer_19, lcov_yell, method = "near")
# # extend it to match the buff layer so you can overlay it
# custer_19_test <- extend(red_custer_19, lcov_yell, snap = "near")
# writeRaster(custer_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Custer19_HillshadeEdited.tif") 
custer_19 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\CUSTER_2019_CUcntyQL1\\Custer19_HillshadeEdited.tif")

# rosebud_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Hillshade.tif")
# crs(rosebud_19) <- "EPSG:32100"
# rosebud_19_test <- resample(rosebud_19, lcov_yell, method = "near")
# rosebud_19_test <- extend(rosebud_19_test, lcov_yell, snap = "near")
# writeRaster(rosebud_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif") 
rosebud_19 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif")

# treasure_19 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\TREASURE_2019_TRcntyQL1\\Hillshade.tif")
# crs(treasure_19) <- "EPSG:32100"
# treasure_19_test <- resample(treasure_19, lcov_yell, method = "near")
# treasure_19_test <- extend(treasure_19_test, lcov_yell, snap = "near")
# writeRaster(treasure_19_test, "E:\\MT_Spatial_Data\\MT_LiDAr\\TREASURE_2019_TRcntyQL1\\Treasure19_HillshadeEdited.tif") 
treasure_19 <- terra::rast("D:\\MT_Spatial_Data\\MT_LiDAr\\ROSEBUD_2019_RScntyQL1\\Rosebud19_HillshadeEdited.tif")

#Add park 2020 ___________________________
#look at sf package 
# merge is from raster package
combined_yell <- sum(dawson_19,custer_19, rosebud_19,treasure_19,na.rm=TRUE)

plot(lcov_yell)
plot(sum_test, add = TRUE)
# this works

plot(lcov_yell, main = "Standard Plot")
plot(custer_19, add = TRUE)
plot(dawson_19, add=TRUE)
plot(rosebud_19, add=TRUE)
plot(treasure_19, add=TRUE)

merge_test <- merge(dawson_19,custer_19)
merge2 <- merge(merge_test,rosebud_19)
merge3 <- merge(merge_test,treasure_19)

plot(lcov_yell)
plot(merge3, add = TRUE)
# this works!
# you can only merge two at a time?


# try a spatraster collection?
rlist <- list(dawson_19,custer_19,rosebud_19,treasure_19)
collect_rasts <- sprc(rlist)
merge_test2 <- merge(collect_rasts)

plot(lcov_yell)
plot(merge_test2,add=TRUE)
# can't get these to combine??

lidar_yell <- c(dawson_19_test,custer_19_test,rosebud_19_test,treasure_19_test)
# export this as a shapefile
ext(lidar_yell)
ext(lcov_yell)
plot(lidar_yell)
plot(lcov_yell, main = "Combo Plot")
plot(lidar_yell, add = TRUE)
# why isn't this combining like I want it to? maybe its a relic of plotting it?
# this isn't plotting right?


# Missouri River LiDAR
valley_18 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\MT_Valley_2018_MilkRvrHinsdale\\Hillshade.tif")
crs(valley_18) <- "EPSG:32100"
valley_18_test <- resample(valley_18, lcov_miso, method = "near")
valley_18_test <- extend(valley_18_test, lcov_miso, snap = "near")

phillips_18 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\PHILLIPS_2018_PHcntyS\\Hillshade.tif")
crs(phillips_18) <- "EPSG:32100"
phillips_18_test <- resample(phillips_18, lcov_miso, method = "near")
phillips_18_test <- extend(phillips_18_test, lcov_miso, snap = "near")


# dummy raster for UMRBNM
dummy <- terra::rast(ncol=36,nrow=18,xmin=)

plot(lcov_yell, main = "Standard Plot")
plot(custer_19_test, add = TRUE)
plot(dawson_19_test, add=TRUE)

# combine the rasters
lidar_miso <- c(valley_18_test,phillips_18_test)



# Musselshell River LiDAR

wheatland_17 <- terra::rast("E:\\MT_Spatial_Data\\MT_LiDAr\\WHEATLAND_2017_MshellRvrTribs\\Hillshade.tif")
crs(wheatland_17) <- "EPSG:32100"
wheatland_17_test <- resample(wheatland_17, lcov_miso, method = "near")
wheatland_17_test <- extend(wheatland_17_test, lcov_miso, snap = "near")

