######### Split and Wrangle ARU Testing Data #################

# This is a script for reading in the ARU testing file, creating inventories for each organization, and counting how many ARUs are useable for the field season

# Created: 4/25/2023
# Last updated: 4/25/2023


######## install and load pacakges #########
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap","tmap")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############

# Read in points
mush_locs <- fread(".\\Data\\Spatial_Data\\GRTS_Points_2023\\Musselshell_SurveyPoints_2023.csv")
mush_sf <- mush_locs %>% 
  st_as_sf(coords=c("lon", "lat")) %>% st_set_crs(4326)
#proj_bound <- st_bbox(locs_sf)
plot(mush_sf)