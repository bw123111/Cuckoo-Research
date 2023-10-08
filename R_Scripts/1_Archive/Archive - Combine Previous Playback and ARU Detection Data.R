####### Combining Previous Playback and ARU Detection Data ########


# A script to read in playback data from 2020, 2021, and 2022 as well as the ARU data and output a datasheet for use in ArcGIS

# Created 10/2/2023

# Last updated 10/4/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)

#### Code ############

# Region 5 2022 Playback Data ###############
# Read in playback and metadata, clean names, rename, and select the one that you want
r5_22 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR5.csv") %>% 
  clean_names() %>% 
  rename(lat = latitude, long = longitude, bbcu_detected = playback_cuckoo_detection)

r5_playback <- r5_22 %>%
  select(point_id, bbcu_detected, lat, long)

# Region 6 2022 playback Data ###################

# Read in playback data
r6_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_BBCUPlaybackSessionResults_FWPR6.csv") %>% clean_names() %>% rename(aru_id = aru_point)

# Add a point ID column to match the metadata
r6_22 <- r6_22 %>% mutate(point_id = case_when(
  aru_id == "05169_1" ~ "CUL-1",
  aru_id == "05169_2" ~ "CUL-2",
  aru_id == "05169_3" ~ "CUL-3",
  aru_id == "FWP_R6_001_C4" ~ "ROB-1",
  aru_id == "FWP_R6_002_C5" ~ "ROB-2",
  aru_id == "FWP_R6_003_C6" ~ "ROB-3",
  aru_id == "FWP_R6_004_C7" ~ "SNO-1",
  aru_id == "FWP_R6_005_C8" ~ "SNO-2",
  aru_id == "FWP_R6_006_C9" ~ "SNO-3"))

# Link this with the metadata to link ARU ID to point ID
r6_22_sum <- r6_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(point_id) %>% 
  summarize(bbcu_detected = sum(bbcu))

# Read in the metadata
r6_metadat <- read.csv('C:/Users/annak/OneDrive/Documents/UM/Research/Coding_Workspace/Cuckoo-Research/Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR6.csv') %>% clean_names()

# Combine them into the finished dataset for exporting 
r6_playback <- left_join(r6_22_sum, r6_metadat, by = "point_id") %>% select(point_id, bbcu_detected, lat, long)
# done 

# Create a datasheet to check with Nikie ########
r6_tocheck <- r6_22 %>% mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% group_by(aru_id) %>% summarize(bbcu_detected = sum(bbcu))
# Write this
write.csv(r6_tocheck, "./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_ARUandDetection_FWPR6.csv", row.names = FALSE)
# write the playback data as well
r6_playback_demo <- left_join(r6_22_sum, r6_metadat, by = "point_id")  
r6_playback_demo <- r6_playback_demo %>% select(point_id, aru_id, bbcu_detected, lat, long)
write.csv(r6_playback_demo,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveysSummarized_FWPR6.csv", row.names = FALSE)

# Region 7 2022 playback data ####################

# Read in playback data
r7_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_R7_PlaybackSurveyData.csv") %>% clean_names() %>% rename(aru_id = point)

# need to link this with the metadata to link ARU ID to point ID
r7_22_sum <- r7_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(aru_id) %>% 
  summarize(bbcu_detected = sum(bbcu))
# Remove the spaces in the ARU ID column
r7_22_sum$aru_id <- str_replace(r7_22_sum$aru_id," ", "")

# add on lat and long
# Read in metadata
r7_metadat <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR7.csv") %>% clean_names() %>% rename(long = longitude, lat = latitude) %>% select(point_id, aru_id, lat, long)

# join the datasets
r7_playback <- left_join(r7_22_sum,r7_metadat, by = "aru_id")
# Need to check into the missing rows ?????????????????????

# Need to create a new script for removing the U and space from the Region 7 playback data and joining it to the right name from the metadata, then writing it to outputs 

# UMBEL 2022 playback data ######################
# Read in playack data
umbel_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022MMR_CuckooPlaybackData_UMBEL.csv") %>% clean_names() 
# replace the _ in the point id with -
umbel_22$point_id <-  str_replace(umbel_22$point_id, "_", "-")

# create a new column with ones and twos for bbcu
umbel_22_sum <- umbel_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(point_id) %>% 
  summarize(bbcu_detected = sum(bbcu))


# add on lat and long 
# read in metadata
# umbel_metadat <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_UMBEL.csv") %>% clean_names()
# doesn't have the values we want
umbel_coords <- read.csv("./Data/Monitoring_Points/UMBEL_LetterNamedPoints2022.csv") %>% 
  clean_names() %>% 
  rename(point_id = gps_id) %>%
  select(point_id, lat, long)

# rbind them together
umbel_22_final <- left_join(umbel_22_sum, umbel_coords, by = "point_id")
# need to fix a couple of the points in here 

#### Rbind all playback data and export for use in ArcPro ####################




########## ARU CODE #############

# read in data
aru_r5 <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR5.csv") %>%
  clean_names() %>%
  select(point_id, latitude, longitude, bbcu_presence)

aru_r6 <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR6.csv") %>%
  clean_names() %>%
  select(point_id, lat, long, bbcu_presence) %>% 
  rename(latitude = lat) %>%
  rename(longitude = long)

aru_r7 <- read_csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR7_new.csv") %>%
  clean_names() %>%
  rename(lat = latitude) %>%
  rename(long = longitude) %>% 
  select(point_id, lat, long, bbcu_presence) 
# Check why there's an NA in BBCU presence here??????????????????????????????


aru_umbel <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_UMBEL.csv") %>%
  clean_names() %>%
  rename(lat = latitude) %>%
  rename(long =longitude) %>%
  select(point_id, latitude, longitude, bbcu_presence)

# need to combine this with the umbel points datasheet




#### Rbind all together and export for use in arcpro ####################




#### CODE GRAVEYARD #####
# umbel_22 %>% mutate(bbcu = case_when(species == "BBCU" ~ 1)) 

#summarize(bbcu_detected = ifelse(sum(bbcu>1),1,0))
#select(site, point_id, aru_id, sd_id, lat, long) 