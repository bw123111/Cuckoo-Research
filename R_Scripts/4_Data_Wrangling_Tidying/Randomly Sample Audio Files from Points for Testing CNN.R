#### Randomly Sample Audio Files from Points for Testing CNN ###################

## Purpose: to randomly sample acoustic files to use to test the model

# Created 10/18/2023

# Last modified: 10/18/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)
# Read in the edit_names function
source("./R_Scripts/6_Function_Scripts/Edit_Names_In_Audio_Files_List.R")


##### Input Which Site and Working Directory ####################

# Create a vector for your current point
# Format for habitat points: MISO-###
current_point <- "84-2"

# Read in the directory of the folder you're looking into
directory <- "F:/Cuckoo_Acoustic_Data/2022/2022_UMBEL_Data/2022_UMBEL_Audio/84-2"

# Region 6: F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio_Unnamed/
# UMBEL: F:/Cuckoo_Acoustic_Data/2023/2023_UMBEL_Data/2023_UMBEL_Audio_Unnamed/


##### Sample Audio Files from Points ####################

# Pull out the file names for the current file
files_list <- list.files(directory)
audio_files <- as.data.frame(files_list) %>% rename(file_names = files_list)


# run the function on the audio files you're working with 
output <- edit_names(audio_files)

# group the files by month, day and diurnal period
test_files <- output %>% 
  group_by(month, period) %>% 
  sample_n(1) %>% 
  filter(!(month == "05")) # excluding May on the premise that the soundscape won't be very (if at all) different from early June so training data from June is likely to capture the same soundscape, also May has low representation in our test dataset so even if there aren't many training files from early June they proportionally represent May

# combine date and time back into a file name column, create column for point ID, and select wanted columns
test_files <- test_files %>% 
  unite(file_name, c(date,time), sep = "_") %>% 
  mutate(point_id = current_point) %>% 
  select(point_id, file_name, month, period)

# Create a name to write your output to
output_name <- paste("./Data/Training_Data/Outputs/Negative_Files_To_Vet/", current_point, "_Negative_Files.csv", sep = "")

# Append this to the existing .csv for Negative Training Files
write.csv(training_files, file = output_name, row.names = FALSE)