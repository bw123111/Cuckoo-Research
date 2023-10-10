####### Combining Previous Playback and ARU Detection Data ########


# A script to read in playback data from 2020, 2021, and 2022 as well as the ARU data and output a datasheet for use in ArcGIS
# Older version archived

# STATUS: need to fill in the missing data from the umbel data and then run this script and combine them

# Created 10/6/2023

# Last updated 10/6/2023

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

r5_22_sum <- r5_22 %>%
  select(point_id, bbcu_detected, lat, long)

# Region 6 2022 playback Data ###################

# Read in playback data
r6_22 <- read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_FWPR6_Cleaned10-9.csv") %>% clean_names() 

# Summarize
r6_22_sum <- r6_22 %>% 
  group_by(point_id, lat, long) %>% 
  summarize(bbcu_detected = sum(bbcu, na.rm = TRUE)) %>% 
  select(point_id, bbcu_detected, lat,long)


# Region 7 2022 playback data ####################

# Read in playback data
r7_22 <- read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_FWPR7_Cleaned10-6.csv") %>% clean_names() 

# need to link this with the metadata to link ARU ID to point ID
r7_22_sum <- r7_22 %>% 
  group_by(point_id, lat, long) %>% 
  summarize(bbcu_detected = ifelse(sum(bbcu,na.rm = TRUE)>=1,1,0)) %>% 
  select(point_id, bbcu_detected, lat,long)


# # join the datasets
# r7_playback <- left_join(r7_22_sum,r7_metadat, by = "aru_id")
# # Need to check into the missing rows ?????????????????????


# UMBEL 2022 playback data ######################
# Read in playack data
umbel_22 <- read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_UMBEL_Cleaned10-9.csv") %>% clean_names() 

# create a new column with ones and twos for bbcu
umbel_22_sum <- umbel_22 %>% 
  group_by(point_id,lat,long) %>% 
  summarize(bbcu_detected = sum(bbcu))

## Waiting on updated playback data


#### Rbind all playback data and export for use in ArcPro ####################
all_playbacks <- rbind(r5_22_sum,r6_22_sum,r7_22_sum, umbel_22_sum)

# Export the data to use in ArcGIS
write.csv(all_playbacks,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SummedAllOrgs10-9.csv", row.names = FALSE)

########## ARU CODE #############

# read in data
aru_r5 <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR5.csv") %>%
  clean_names() %>%
  select(point_id, latitude, longitude, bbcu_presence)  %>%
  rename(lat = latitude) %>%
  rename(long = longitude)

aru_r6 <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR6.csv") %>%
  clean_names() %>%
  select(point_id, lat, long, bbcu_presence) 

aru_r7 <- read_csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_FWPR7_new.csv") %>%
  clean_names() %>%
  rename(lat = latitude) %>%
  rename(long = longitude) %>% 
  select(point_id, lat, long, bbcu_presence) 
# Check why there's an NA in BBCU presence here??????????????????????????????


aru_umbel <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_UMBEL.csv") %>%
  clean_names() 


# read in metadata
aru_meta <- read.csv("./Data/Metadata/Outputs/2022_ARUDeployment_Metadata_UMBEL_Cleaned10-9.csv") %>% clean_names() %>% select(point_id,lat, long)

# combine aru detections with metadata to get the right lat long
aru_umbel <- left_join(aru_umbel,aru_meta, by = "point_id") %>%
  select(point_id, lat, long, bbcu_presence)

# combine all the data
allaru <- rbind(aru_umbel,aru_r5,aru_r6,aru_r7)

# export for use in arcgis
write.csv(allaru,"./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_ARUDetections_Combined_Cleaned10-9.csv", row.names = FALSE)
