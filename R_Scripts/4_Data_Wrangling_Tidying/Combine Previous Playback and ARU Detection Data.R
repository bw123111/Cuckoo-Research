####### Combining Previous Playback and ARU Detection Data ########


# A script to read in playback data from 2020, 2021, and 2022 as well as the ARU data and output a datasheet for use in ArcGIS

# Created 10/2/2023

# Last updated 10/2/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor")
load_packages(packages)

#### Code ############

# read in region 6 2022 playack data
r6_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_BBCUPlaybackSessionResults_FWPR6.csv") %>% clean_names() %>% rename(aru_id = aru_point)

# need to link this with the metadata to link ARU ID to point ID
r6_22_sum <- r6_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(aru_id) %>% 
  summarize(bbcu_detected = sum(bbcu))
# need to ask Nikie about this metadata

# add on lat and long


# Read in region 7 2022 playback data
r7_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_R7_PlaybackSurveyData.csv") %>% clean_names() %>% rename(aru_id = point)

# need to link this with the metadata to link ARU ID to point ID
r7_22_sum <- r7_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(aru_id) %>% 
  summarize(bbcu_detected = sum(bbcu))

# add on lat and long


# Read in UMBEL 2022 playback data
umbel_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022MMR_CuckooPlaybackData_UMBEL.csv") %>% clean_names() 
# replace the _ in the point id with -
umbel_22$point_id <-  str_replace(umbel_22$point_id, "_", "-")

# create a new column with ones and twos for bbcu
umbel_22_sum <- umbel_22 %>% 
  mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
  group_by(point_id) %>% 
  summarize(bbcu_detected = sum(bbcu))


# add on lat and long 


# rbind them together


#### CODE GRAVEYARD #####
# umbel_22 %>% mutate(bbcu = case_when(species == "BBCU" ~ 1)) 
