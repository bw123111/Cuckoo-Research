##################### Header ############################

# Purpose: checking the clip extraction file for duplicates 


# Status: 

#################### Setup ##########################

# Libraries
library(tidyverse)
library(here)
library(janitor)



################## Code  ################################################


clips <- read_csv("E:\\2022_UMBEL_Clips\\2022-11-30_2022UMBEL_top10persite\\BBCU\\top10scoring_clips_persite_annotations.csv")


# Check for duplicates
unique(clips$clip)==FALSE

clip_names <- clips$clip
clip_names[ clip_names %in% clip_names[duplicated(clip_names)]]
id[ id %in% id[duplicated(id)] ]