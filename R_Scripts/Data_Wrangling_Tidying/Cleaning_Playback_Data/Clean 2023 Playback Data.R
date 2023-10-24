#### Clean 2023 Playback Data ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 8/23/2023

# Last modified: 9/11/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# Read in metadata files
fwp_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWPR6.csv")
fwp_dj <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWP_DANIEL.csv")
# add in the playback data from Region 5
umbel_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_UMBEL.csv")
# add in UMBEL's datasheet once you get this as well

# Pull out the number of surveys from Region 6
fwp <- rbind(fwp_ak,fwp_dj)
# separate the first column
temp <- fwp %>% separate(col = survey_id, into = c("site","ID"), sep = "#")
r6_surveys <- temp %>% filter(site %in% c("ROB","SNO","CUL","CLA"))
r7_surveys <- temp %>% filter(!(site %in% c("ROB","SNO","CUL","CLA")))

