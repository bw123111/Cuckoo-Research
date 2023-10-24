#### Pull Files from Positive Testing Data ###################

## Purpose: to pull out the files from the directories that we will be using to test the CNN

# Created 10/23/2023

# Last modified: 10/23/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)
# Read in the edit_names function
source("./R_Scripts/6_Function_Scripts/Edit_Names_In_Audio_Files_List.R")


#### Pull the correct directory ########

# CUL-1 2023, excluding the playback dates # done
# ROB-1 2023, excluding playback dates used in positive data # done
# 103-3 from 2022 # done
# JON-3 from 2022
# look through these sites until you find a + cuckoo

# Format for habitat points: MISO-###
current_point <- "CUL-1"

# Read in the directory of the folder you're looking into
directory <- "F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio/CUL-1"

files_to_exclude <- list()
  
# for CUL-1: c("CUL-1_20230712_070000.wav","CUL-1_20230713_070000.wav")
  # for ROB: nothing to exclude, survey period for this site started after recording was over

##### Run this code#######

# Pull out the file names for the current file
files_list <- list.files(directory)
audio_files <- as.data.frame(files_list) %>% rename(file_names = files_list)
# exclude the rows from audio files that are in the list of files to exclude
audio_files <- audio_files %>% filter(!file_names %in% files_to_exclude)

# run the function on the audio files you're working with 
output <- edit_names(audio_files)

# group the files by month, day and diurnal period
test_files <- output %>% 
  group_by(month, period) %>% 
  sample_n(1) 


test_files <- test_files %>% 
  unite(file_name, c(id,date,time), sep = "_") %>% 
  mutate(point_id = current_point) %>% 
  select(file_name, point_id, month, period) 


# Create a name to write your output to
output_name <- paste("./Data/Testing_Data/Outputs/", current_point, "_Test_Files.csv", sep = "")

# Append this to the existing .csv for Negative Training Files
write.csv(test_files, file = output_name, row.names = FALSE)

#####
