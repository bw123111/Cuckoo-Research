##################### Header ############################

# Purpose: checking the clip extraction file for duplicates 


# Status: 

#################### Setup ##########################

# Libraries
library(tidyverse)
library(here)
library(janitor)



################## Code  ################################################

#### Model 1.0 #######
clips <- read_csv("E:\\2022_UMBEL_Clips\\2022-11-30_2022UMBEL_top10persite\\BBCU\\top10scoring_clips_persite_annotations.csv")


# Check for duplicates
unique(clips$clip)==FALSE

clip_names <- clips$clip
clip_names[ clip_names %in% clip_names[duplicated(clip_names)]]
id[ id %in% id[duplicated(id)] ]

#### Model 2.0 ####

clips <- read.csv("F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Clips/2023_FWPR6_topclip_perperiod/2023_FWPR6_topclips_perSiteperPeriod.csv")
num_persite <- clips %>% group_by(point_id) %>% summarize(n=n())
# Check out the number of one 
subclips <- clips %>% filter(point_id == "102-5")
unique(subclips$date)
# 102-5 looks good, just need to run clip extraction