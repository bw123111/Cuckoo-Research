########## Num ARUs for 2023 ##################
library(tidyverse)


# To do
# Read in the ARU datasheet
## break up by organization, calculate percentage failure rate


#################################

# Create a function to remove the unwanted straum and add in a new column for the land cover type

remove_rename_strata <- function(surveylocs){
  lcov_to_exclude <- c(11,12,21,22,23,24,31,81,82)
  surveylocs_trimmed <- surveylocs %>% filter(!stratum %in% lcov_to_exclude)
  surveylocs_trimmed <- surveylocs_trimmed %>% mutate(landcover = case_when(
    stratum == 11 ~ "Open Water",
    stratum == 12 ~ "Perinneal Ice/Snow",
    stratum == 21 ~ "Developed, Open Space",
    stratum == 22 ~ "Developed, Low Intensity",
    stratum == 23 ~ "Developed, Medium Intensity",
    stratum == 24 ~ "Developed, High Intensity",
    stratum == 31 ~ "Barren Land",
    stratum == 41 ~ "Deciduous Forest",
    stratum == 42 ~ "Evergreen Forest",
    stratum == 43 ~ "Mixed Forest",
    stratum == 51 ~ "Dwarf Scrub",
    stratum == 52 ~ "Shrub/Scrub",
    stratum == 71 ~ "Grassland/Herbaceous",
    stratum == 72 ~ "Sedge/Herbaceous",
    stratum == 73 ~ "Lichens",
    stratum == 74 ~ "Moss",
    stratum == 81 ~ "Pasture/Hay",
    stratum == 82 ~ "Cultivated Crops",
    stratum == 90 ~ "Woody Wetlands",
    stratum == 95 ~ "Emergent Herbaceous Wetlands"
  ))
  return(surveylocs_trimmed)
}

#################################

# Read in the csv for each site

miso_pts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\Missouri_SurveyPoints_2023.csv")
yell_pts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\Yellowstone_SurveyPoints_2023.csv")
mush_pts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\Musselshell_SurveyPoints_2023.csv")

# remove points with strata in strata to exclude and rewrite after moving the old one to archives
new_miso <- remove_rename_strata(miso_pts)
# rewrite new csv
#write.csv(new_miso,".\\Data\\Spatial_Data\\GRTS_Points_2023\\Missouri_SurveyPoints_2023.csv")
new_yell <- remove_rename_strata(yell_pts)
#write.csv(new_yell,".\\Data\\Spatial_Data\\GRTS_Points_2023\\Yellowstone_SurveyPoints_2023.csv")
new_mush <- remove_rename_strata(mush_pts)
#write.csv(new_mush,".\\Data\\Spatial_Data\\GRTS_Points_2023\\Musselshell_SurveyPoints_2023.csv")


# miso only: 
# read in  points csv and divide it by longitude: -106.684202
# write separate csvs
miso_r6 <- new_miso %>% filter(lon_WGS84 > -106.684202)
miso_UMBEL <- new_miso %>% filter(lon_WGS84 < -106.684202)
write.csv(miso_r6,".\\Data\\Spatial_Data\\GRTS_Points_2023\\Missouri_SurveyPointsR6_2023.csv",row.names=FALSE)
write.csv(miso_UMBEL,".\\Data\\Spatial_Data\\GRTS_Points_2023\\Missouri_SurveyPointsUMBEL_2023.csv",row.names=FALSE)



# copy paste
# The first iteration of survey points for summer 2023 black-billed cuckoo habitat surveys. Includes the GRTS main sample and over sample for habitat surveys, repeat monitoring points from previous years for habitat and playback surveys, land cover values from 2019 data, and cadastrel (land ownership) data. 
# 
# The new GRTS points are for habitat surveys, which will be conducted with only ARUs, no playbacks.
# Habitat surveys will include ARU deployment and vegetation surveys before June 1st and ARU retrieval after August 15th.
# 
# The repeat monitoring points will include the same surveys as the habitat points but will also include 2-4 playback surveys.
