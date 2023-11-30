####### Clean 2022 Playback Data ########


# A script to read in playback data from 2021 and export a clean file for use in analysis and visualization
# First formatting them for use in ARCGIS - summarizing cuckoo detection for each site 
# Next formatting them for us in modeling (later)

# Created 11/29/2023

# Last updated 11/29/2023


#### Setup ###############
packages <- c("stringr","tidyverse","janitor","lubridate")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


#### Functions #####
# Create a survey ID column that is just the site, a #, then 1 (since in 2022 only one survey was conducted) 
separate_site_make_survey_id <- function(dataframe){
  dataframe <- dataframe %>% 
    separate(point_id, into = c("site_id", "point"), sep = "-" , remove = FALSE) %>%
    mutate(survey_id = paste(site_id,"#1"))
  dataframe$survey_id <- str_replace(dataframe$survey_id," ", "")
  return(dataframe)
}

#### Code ######

pb_21 <- read.csv("./Data/Playback_Results/2021/Raw_Data/2021_BBCUPlaybackResults_UMBEL_AKEdits_1129.csv")
# Create columns for site_id and survey_id
pb_21_dat <- separate_site_make_survey_id(pb_21)
# replace NA in the playback_detection column with "no_data"
#pb_21_dat <- pb_21_dat %>% mutate(playback_detection = ifelse(is.na(playback_detection),"no_data",playback_detection))

# Summarize by site
pb_21_summed <- pb_21_dat %>% group_by(site_id) %>% summarize(lat_avg = mean(lat, na.rm = TRUE), long_avg = mean(long, na.rm = TRUE),detection_hist_bbcu = max(playback_detection, na.rm = TRUE)) 
# replace -Inf with no_data
#pb_21_summed %>% str_replace(-Inf, "no_data")
# NEED TO FIX THIS LATER

# write to .csv for ArcGIS
write.csv(pb_21_summed,"./Data/Playback_Results/2021/Outputs/2021_PlaybackResultsSummarized_11-29.csv", row.names = FALSE)
