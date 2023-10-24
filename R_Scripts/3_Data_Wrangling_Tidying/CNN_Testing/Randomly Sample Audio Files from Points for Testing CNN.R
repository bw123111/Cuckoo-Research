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
# Points 
## MISO-152 - Upper Missouri #woody wet #not in training # done
## MISO-189 - Upper Missouri #emergent wet #not in training #done
## MISO-077 - Lower Missouri #decid for #pre seen # done
## MISO-057 - Upper Missouri #evergreen # not in training #done
## MISO-097 - Upper Missouri #Shrub #not in training # done
## MISO-017 - Upper Missouri #Grassland #not in training # done
# Should be about 36 files from the habitat data


# Format for habitat points: MISO-###
current_point <- "MISO-077"

# Read in the directory of the folder you're looking into
directory <- "F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio/MISO-077"

# Region 6: F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio_Unnamed/
# UMBEL: F:/Cuckoo_Acoustic_Data/2023/2023_UMBEL_Data/2023_UMBEL_Audio_Unnamed/


##### Sample Audio Files from Points ####################

# Pull out the file names for the current file
files_list <- list.files(directory)
audio_files <- as.data.frame(files_list) %>% rename(file_names = files_list)


# run the function on the audio files you're working with 
output <- edit_names(audio_files)

# group the files by month, day and diel period
test_files <- output %>% 
  group_by(month, period) %>% 
  sample_n(1) 

# combine date and time back into a file name column, create column for point ID, and select wanted columns
test_files <- test_files %>% 
  unite(file_name, c(date,time), sep = "_") %>% 
  mutate(point_id = current_point) %>% 
  select(point_id, file_name, month, period) %>% 
  unite(file_name, c(point_id, file_name), sep = "_", remove = FALSE )

# Create a name to write your output to
output_name <- paste("./Data/Testing_Data/Outputs/", current_point, "_Test_Files.csv", sep = "")

# Append this to the existing .csv for Negative Training Files
write.csv(test_files, file = output_name, row.names = FALSE)
