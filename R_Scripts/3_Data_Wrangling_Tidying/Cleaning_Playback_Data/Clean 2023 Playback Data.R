#### Clean 2023 Playback Data ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 8/23/2023

# Last modified: 10/24/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# Missing Data: 
# Metadata for LMA#1 and LMA#2
# Brandi's data
# UMBEL data from their crews
# coordinates for playback sites BSB, CLA, LMA

# Read in metadata files
fwp_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWPR6.csv")
fwp_dj <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWP_DANIEL.csv")
# add in the playback data from Region 5
umbel_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_UMBEL.csv")
# add in UMBEL's datasheet once you get this as well

# get all total surveys
pb_all <- rbind(fwp_ak,fwp_dj,umbel_ak)
# remove certain lines
pb_all <- pb_all %>% filter(!survey_id %in% c("84#2b","84#3b","203-1_2","^change this to 203_2"))
# separate by site
temp <- pb_all %>% separate(col = survey_id, into = c("site","ID"), sep = "#")
all_sites <- unique(temp$site) # total of 29 sites, 3 surveys at each site = 87 playback surveys

# pull in 2023_playbackpoints-FWP and UMBEL and filter out only the sites with their site in the list of points used in 2023
points_fwp <- read.csv("./Data/Monitoring_Points/2023_PlaybackPoints_FWP.csv") %>% rename(long = x, lat = y) %>% select(point_id, lat,long)
points_umbel <- read.csv("./Data/Monitoring_Points/2023_Playback_Survey_Points_UMBEL.csv") %>% rename(lat = latitude,long = longitude) %>% select(point_id,lat,long) 
# remove the sites that aren't formatted correctly and weren't used
points_umbel <- points_umbel[-c(60:65),]
points_all <- rbind(points_fwp,points_umbel)
# average the sites
points_avg <- points_all %>% separate(col = point_id, into = c("site","id"), sep = "-") %>% group_by(site) %>% summarize(lat_avg = mean(lat), long_avg = mean(long))
# export this for use in ArcGIS
write.csv(points_avg, "./Data/Playback_Results/2023/Outputs/2023_PlaybackSiteLocations_All_10-24.csv", row.names = FALSE)

pb_locs <- points_avg %>% filter(site %in% all_sites) # there are two here that are missing

### MISC #####
# # Pull out the number of surveys from Region 6
# fwp <- rbind(fwp_ak,fwp_dj)
# # separate the first column
# temp <- fwp %>% separate(col = survey_id, into = c("site","ID"), sep = "#")
# r6_surveys <- temp %>% filter(site %in% c("ROB","SNO","CUL","CLA"))
# r7_surveys <- temp %>% filter(!(site %in% c("ROB","SNO","CUL","CLA")))

