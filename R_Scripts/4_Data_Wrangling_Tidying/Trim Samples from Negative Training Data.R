#### Trim Samples from Negative Training Data ###################

## Purpose: to read in a dataframe of files, their file paths, and edit them to a specified sample

# Created 9/27/2023

# Last modified: 9/27/2023

# Current status:


#### Setup #################################
packages <- c("data.table","tidyverse","janitor","tuneR")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)


##### Code ####################


negative_files <- read.csv("./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data.csv")

writing_path <- "F:/Training_Data/Cuckoo_Negative_onOneDrive/Trimmed_Files/"


# create a for loop to trim the audio and write it out

for (i in 1:nrow(negative_files)){
  # create a value for the complete file path using the file_path column
  path <- negative_files$file_path[i,]
  # create a value for the file name using the file_name column
  name <- negative_files$file_name[i,]
  # create a complete file path for this row
  complete_file_path <- paste(path,name)
  
  # read in the audio file for this row
  audio <- readWave(complete_file_path)
  # create a value for the starting time of the sample
  start <- negative_files$sample_start_s[i,]
  # create a value for the ending time of the sample
  end <- negative_files$sample_end_s[i,]
  # create a new, trimmed audio using these values
  trimmed_audio <- audio[start:end]
  
  # write the trimmed audio to the trimmed_files folder
  writeWave(trimmed_audio, paste(writing_path,name,".wav"))
}
