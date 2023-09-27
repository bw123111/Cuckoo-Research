#### Randomly Sample Audio Files from Points ###################

## Purpose: to randomly sample acoustic files to use as negative training data
# Need 73 30 min files 

# Created 9/25/2023

# Last modified: 9/26/2023

# Current status: LEFT OFF WITH UM 009, COUPLE OF SD CARDS THAT AREN'T TRACKED IN RED
# need to go through each of the habitat points I pulled out and run them through this script, then decide which of the other points to pull and consult Tessa on the balance of positive training data vs negative training data


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
current_point <- "MISO-123"

# Read in the directory of the folder you're looking into
directory <- "F:/Cuckoo_Acoustic_Data/2023/2023_UMBEL_Data/2023_UMBEL_Audio_Unnamed/CO006"

# Region 6: F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio_Unnamed/
# UMBEL: F:/Cuckoo_Acoustic_Data/2023/2023_UMBEL_Data/2023_UMBEL_Audio_Unnamed/


##### Sample Audio Files from Points ####################

# Pull out the file names for the current file
files_list <- list.files(directory)
audio_files <- as.data.frame(files_list) %>% rename(file_names = files_list)


# run the function on the audio files you're working with 
output <- edit_names(audio_files)

# group the files by month, day and diurnal period
training_files <- output %>% 
  group_by(month, period) %>% 
  sample_n(1) %>% 
  filter(!(month == "05")) # excluding May on the premise that the soundscape won't be very (if at all) different from early June so training data from June is likely to capture the same soundscape, also May has low representation in our test dataset so even if there aren't many training files from early June they proportionally represent May

# combine date and time back into a file name column, create column for point ID, and select wanted columns
training_files <- training_files %>% 
  unite(file_name, c(date,time), sep = "_") %>% 
  mutate(point_id = current_point) %>% 
  select(point_id, file_name, month, period)

# Create a name to write your output to
output_name <- paste("./Data/Training_Data/Outputs/Negative_Files_To_Vet/", current_point, "_Negative_Files.csv", sep = "")

# Append this to the existing .csv for Negative Training Files
write.csv(training_files, file = output_name, row.names = FALSE)



#### CODE GRAVEYARD ########
# # try append = TRUE
# write.csv(training_files, "./Data/Training_Data/Outputs/Negative_Files.csv", row.names = FALSE, append = TRUE)

# # Function: input is a dataframe of audio files
# edit_names <- function(list_of_files){
#   
#   # First, test if there is the ARU ID in the file name
#   if(grepl("(.*)([[:digit:]]{8})_([[:digit:]]{6}).wav",audio_files[1]) == TRUE){
#     print("SongMeter Data")
#     # separate into SD ID, date and time
#     data_new <- list_of_files %>% separate(file_names, into = c("name","file_type"), sep = "\\.(?=[^.]*$)")
#     # remove the summary data
#     data_new <- data_new[!grepl("Summary", data_new$name), ]
#     # split the file name into date and time 
#     data_new <- data_new %>% separate(name, into = c("sd_id","date","time"), sep = "_")
#     #    data_new <- data_new %>% select(date, time)
#     
#     # Next, test if there is a .wav or .WAV added onto the end of the files
#   } else if (grepl("\\.WAV|\\.wav$",audio_files[1]) == TRUE){
#     print("Removing .wav")
#     # separate into SD ID, date and time
#     data_new <- list_of_files %>% separate(file_names, into = c("name","file_type"), sep = "\\.(?=[^.]*$)")
#     # split the file name into date and time 
#     data_new <- data_new %>% separate(name, into = c("date","time"), sep = "_")
#     
#   } else {
#     # split the file name into date and time 
#     data_new <- list_of_files %>% separate(file_names, into = c("date","time"), sep = "_")
#     data_new <- data_new %>% select(date, time)
#   }
#   # add a new column for am or pm files
#   data_new <- data_new %>% mutate(period = ifelse(grepl("23|1", time), "nocturnal","diurnal"))
#   # add a month column
#   data_new$month <- substr(data_new$date, 5, 6)
#   data_new %>% select(date, time, month, period)
#   return(data_new)
# }
