####### Clean Current Training Data From Google Sheets ########


# This is a script to read in the training data I currently have and remove unnecessary files so I can make sure it is all backed up

# Created 9/6/2023

# Last edited 9/20/2023

#### Setup ####
library(tidyverse)
library(janitor)


#### Read in Current Datasheets #####

# Read in sheet for UMBEL data and FWP data
umbel <- read.csv("./Data/Training_Data/Raw_Data/Raw_Audio_Processed_UMBEL_9-27.csv") %>% clean_names()
fwp <- read.csv("./Data/Training_Data/Raw_Data/Raw_Audio_Processed_FWPR6_7_9-27.csv") %>% clean_names()


###### Process Data ####
# make these into one datasheet by selecting the same columns and rbinding them 
umbel_tojoin <- umbel %>% select(filename,
                                 bbcu_bird_net,
                                 bbcu_verified,
                                 ybcu_bird_net,
                                 ybcu_verified,
                                 num_bbcu_5_sec_clips,
                                 num_ybcu_5_sec_clips,
                                 good_for_confusion_spp,
                                 num_clips_poor_quality_audio,
                                 num_rattle_clips,
                                 raven_annotation,
                                 cleaned_for_pitt,
                                 notes)
fwp_tojoin <- fwp %>% select(filename,
                             bbcu_bird_net,
                             bbcu_verified,
                             ybcu_bird_net,
                             ybcu_verified,
                             num_bbcu_5_sec_clips,
                             num_ybcu_5_sec_clips,
                             good_for_confusion_spp,
                             num_clips_poor_quality_audio,
                             num_rattle_clips,
                             raven_annotation,
                             cleaned_for_pitt,
                             notes)

alldat <- rbind(umbel_tojoin,fwp_tojoin)
# need to convert the poor quality audio column to numeric
# alldat$num_clips_poor_quality_audio <- as.numeric(alldat$num_clips_poor_quality_audio) this is making them all NAs
## Why does this data go blank after the first couple hundred rows?

# Pull out rows labeled as completed
dat_complete <- alldat %>% filter(raven_annotation == "complete")

# Make a separate datasheet with just the files with YBCU and BBCU
dat_cuckoo <- dat_complete %>% filter(bbcu_verified == 1 | ybcu_verified== 1)

# Also filter out the ones that you still need to double check
dat_tocheck <- alldat %>% filter(bbcu_verified == "u" | ybcu_verified== "u")

dat_tocheck <- alldat %>% filter(cleaned_for_pitt == "pending")

#write.csv(dat_cuckoo, "./Data/Training_Data/Outputs/Cuckoo_Positive_9-6.csv")



##### Pulling Confusion Species #####
# pull data with confusion species from these sheets
confspp_files <- alldat %>% 
  # filter out confusion species files
  filter(good_for_confusion_spp == 1)


confspp_files <- confspp_files %>%
  separate(filename, 
           into = c("point_id", "file_name"), 
           sep = "_", 
           remove = FALSE, 
           extra = "merge", 
           fill = "right", 
           convert = TRUE)


# create new columns to match other negative training data
confspp_files <- confspp_files %>%  
  # specify that these are confusion species 
  mutate(location = "confusion_spp") %>% 
  separate(file_name,into = c("date", "time"),sep = "_",remove = FALSE) %>%
  # Create a month column
  mutate(month = substr(file_name, 5, 6)) %>% 
  # Create a period column
  mutate(period = ifelse(grepl("23|1", time), "nocturnal","diurnal")) %>%
  # Create a new column for aru_model
  ## PRD and AME is Songmeter
  mutate(aru_model = ifelse(grepl("PRD|AME", confspp_files$point_id)==TRUE,"SongMeter Micro","AudioMoth"))

# select the columns to match the other training data'
confspp_files_final <- confspp_files %>% select(point_id,file_name,month,period, location, aru_model)

# read in the other negative training data
other_neg <- read.csv("./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data_nopath_nosample.csv")

total_neg <- rbind(other_neg,confspp_files_final)
# Write this data
write.csv(total_neg,"./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data_Hab_ConfusionSpp.csv", row.names = FALSE)





##### Check quantity of data #####

# Checking how much data we have
bbcu_clipcount <- sum(dat_cuckoo$num_bbcu_5_sec_clips, na.rm = TRUE)
# 430 5 second clips of data
bbcu_clipcount - sum(dat_cuckoo$num_clips_poor_quality_audio, na.rm = TRUE)
# 264 high quality clips


sum(dat_cuckoo$num_ybcu_5_sec_clips, na.rm = TRUE)
# 31

birdnet_files <- dat_complete %>% filter(bbcu_bird_net == "Y" | ybcu_bird_net == "Y")
birdnet_posfiles <- dat_cuckoo %>% filter(bbcu_bird_net == "Y" | ybcu_bird_net == "Y") 
sum(birdnet_posfiles$num_bbcu_5_sec_clips, na.rm=TRUE) # Number of training data clips that were from birdnet 27

playback_files <- dat_cuckoo %>% filter(filename %in% c("CUL-1PB_20230712_071248",
                                                        "CUL-1PB_20230713_071338",
                                                        "CUL-2PB_20230712_075125",
                                                        "CUL-2PB_20230713_073334",
                                                        "CUL-3PB_20230712_081832",
                                                        "ROB-3PB_20230712_104615",
                                                        "WBB-1PB_20230620_102700_Edited"))
sum(playback_files$num_bbcu_5_sec_clips) # 140 clips from playback data

# 106 files from data with known playbacks

# For meeting with Tessa: Get stats of how many clear audio files you have, how many from BirdNet, etc



#### Pull Negative Data ######

datneg_confus <- dat_complete %>% filter(good_for_confusion_spp == "1")







#### Old Code #####
# # Pull out rows labeled as completed
# umbel_complete <- umbel %>% filter(raven_annotation == "complete")
# fwp_complete <- fwp %>% filter(raven_annotation == "complete")
# 
# # Make a separate datasheet with just the files with YBCU and BBCU
# umbel_cuckoo <- umbel_complete %>% filter(bbcu_verified == 1 | ybcu_verified== 1)
# 
# fwp_cuckoo <- fwp_complete %>% filter(bbcu_verified == 1 | ybcu_verified== 1)
# 
# # Also filter out the ones that you still need to double check
# umbel_tocheck <- umbel_complete %>% filter(bbcu_verified == "u" | ybcu_verified== "u")
# 
# fwp_tocheck <- fwp_complete %>% filter(bbcu_verified == "u" | ybcu_verified== "u")

#%>%
# separate the filename column into point id and file name
# separate(filename, into = c("point_id","file_name"),sep = "_")

