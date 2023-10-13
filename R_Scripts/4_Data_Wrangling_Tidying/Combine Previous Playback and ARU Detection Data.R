####### Combining Previous Playback and ARU Detection Data ########


# A script to read in playback data from 2020, 2021, and 2022 as well as the ARU data and output a datasheet for use in ArcGIS
# Older version archived

# STATUS: need to fill in the missing data from the umbel data and then run this script and combine them

# Created 10/6/2023

# Last updated 10/10/2023

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
nrow(all_playbacks) # 120 points

# sum the number of BBCU and YBCU for each site
sum1 <- all_playbacks %>% group_by(point_id) %>% summarize(count_bbcu = ifelse(sum(bbcu_detected, na.rm = TRUE)>=1,1,0)) 
sum(sum1$count_bbcu, na.rm = TRUE) # 6 sites with bbcu detected
test1 <- all_playbacks %>% group_by(point_id) %>% summarize(missing_dat = ifelse(is.na(bbcu_detected)==TRUE,"missing_data","data"))
sum(test1$missing_dat == "missing_data") # no sites missing data

# Export the data to use in ArcGIS
#write.csv(all_playbacks,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SummedAllOrgs10-9.csv", row.names = FALSE)


# Create a new dataframe with site-level data
pb_site <- all_playbacks %>% separate(point_id, into = c("site","point"), sep = "-", remove = FALSE)
pb_site <- pb_site %>% group_by(site) %>% summarize(bbcu = ifelse(sum(bbcu_detected, na.rm = TRUE)>=1,1,0), lat_avg = mean(lat),long_avg = mean(long)) 
# Descriptive stats
nrow(pb_site) # 40 sites
sites_pos <- pb_site %>% filter(pb_site$bbcu == 1) # 4 sites with BBCU on playbacks
# Export the data to use in ArcGIS
write.csv(pb_site,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SiteLevelBBCU10-11.csv", row.names = FALSE)


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
# Check why there's an NA in BBCU presence here - data loss


aru_umbel <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_MetadataARUPresence_UMBEL.csv") %>%
  clean_names() 


# read in metadata
aru_meta <- read.csv("./Data/Metadata/Outputs/2022_ARUDeployment_Metadata_UMBEL_Cleaned10-9.csv") %>% clean_names() %>% select(point_id,lat, long)

# combine aru detections with metadata to get the right lat long
aru_umbel <- left_join(aru_umbel,aru_meta, by = "point_id") %>%
  select(point_id, lat, long, bbcu_presence)

# combine all the data
allaru <- rbind(aru_umbel,aru_r5,aru_r6,aru_r7)

# See how many points were missing data
allaru %>% filter(is.na(allaru$bbcu)==TRUE) # 7 points had data loss
nrow(allaru) #126 points

# sum the number of BBCU and YBCU for each site
sum3 <- allaru %>% group_by(point_id) %>% summarize(count_bbcu = ifelse(sum(bbcu, na.rm = TRUE)>=1,1,0)) 
sum(sum3$count_bbcu, na.rm = TRUE) #  sites with bbcu
sum4 <- allaru %>% group_by(point_id) %>% summarize(count_ybcu = ifelse(sum(ybcu, na.rm = TRUE)>=1,1,0)) 
sum(sum4$count_ybcu, na.rm = TRUE) #  sites with ybcu



# sum the number of BBCU and YBCU for each site
sum3 <- allaru %>% group_by(point_id) %>% summarize(count_bbcu = ifelse(sum(bbcu_presence, na.rm = TRUE)>=1,1,0)) 
sum(sum3$count_bbcu, na.rm = TRUE) # 15 sites with bbcu detected
test2 <- allaru %>% group_by(point_id) %>% summarize(missing_dat = ifelse(is.na(bbcu_presence)==TRUE,"missing_data","data"))
sum(test2$missing_dat == "missing_data") # no sites missing data

# export for use in arcgis
#write.csv(allaru,"./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_ARUDetections_Combined_Cleaned10-9.csv", row.names = FALSE)


# Create a new dataframe with site-level data
aru_site1 <- allaru %>% separate(point_id, into = c("site","point"), sep = "-", remove = FALSE)
aru_site <- aru_site1 %>% group_by(site) %>% summarize(bbcu = ifelse(sum(bbcu_presence, na.rm = TRUE)>=1,1,0), lat_avg = mean(lat),long_avg = mean(long)) 
# Descriptive stats
nrow(aru_site) # 42 sites
sites_posaru <- aru_site %>% filter(aru_site$bbcu == 1) # 8 sites with BBCU on playbacks
# Export the data to use in ArcGIS
write.csv(aru_site,"./Data/Cuckoo_Presence_Absence_ARU/Model_1.0//2022_ARUSurveys_SiteLevelBBCU10-11.csv", row.names = FALSE)

# how many sites had some kind of missing data?
missing_dat <- aru_site1 %>% group_by(site) %>% summarize(bbcu = ifelse(sum(bbcu_presence)>=1,1,0), lat_avg = mean(lat),long_avg = mean(long)) 
missing_dat %>% filter(is.na(missing_dat$bbcu)==TRUE) # 4 sites missing data
