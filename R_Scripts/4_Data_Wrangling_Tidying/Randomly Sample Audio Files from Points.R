#### Randomly Sample Audio Files from Points ###################

## Purpose: to randomly sample acoustic files to use as negative training data
# Need 73 30 min files 

# Created 9/25/2023

# Last modified: 9/26/2023

# Current status: need to go through each of the habitat points I pulled out and run them through this script, then decide which of the other points to pull and consult Tessa on the balance of positive training data vs negative training data


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


##################### Functions #############################

# Function: input is a dataframe of audio files
edit_names <- function(list_of_files){
  if(grepl("(.*)([[:digit:]]{8})_([[:digit:]]{6}).wav",audio_files[1]) == TRUE){
    # separate into SD ID, date and time
    data_new <- list_of_files %>% separate(file_names, into = c("name","file_type"), sep = "\\.(?=[^.]*$)")
    # remove the summary data
    data_new <- data_new[!grepl("Summary", data_new$name), ]
    # split the file name into date and time 
    data_new <- data_new %>% separate(name, into = c("sd_id","date","time"), sep = "_")
    data_new <- data_new %>% select(date, time)
    
  } else {
    # split the file name into date and time 
    data_new <- list_of_files %>% separate(name, into = c("date","time"), sep = "_")
    data_new <- data_new %>% select(date, time)
  }
  # add a new column for am or pm files
  data_new <- data_new %>% mutate(period = ifelse(grepl("23|1", time), "nocturnal","diurnal"))
  # add a month column
  data_new$month <- substr(data_new$date, 5, 6)
  data_new %>% select(date, time, month, period)
  return(data_new)
}

##### Input Which Site and Working Directory ####################

current_point <- "MISO-163"

# Read in the directory of the folder you're looking into
directory <- "F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Audio_Unnamed/MISO-163"


##### Sample Audio Files from Points ####################

# Pull out the file names for the current file
files_list <- list.files(directory)
audio_files <- as.data.frame(files_list) %>% rename(file_names = files_list)


# run the function on the audio files you're working with 
output <- edit_names(audio_files)

# group the files by month, day and diurnal period
training_files <- output %>% 
  group_by(month, period) %>% 
  sample_n(1)

# combine this back into 
training_files <- training_files %>% 
  unite(file_name, c(date,time), sep = "_") %>% 
  mutate(point_id = current_point) %>% 
  select(point_id, file_name, month, period)

output_name <- paste("./Data/Training_Data/Outputs/Negative_Files_To_Vet/", current_point, "_Negative_Files.csv", sep = "")
# Append this to the existing .csv for Negative Training Files
write.csv(training_files, file = output_name, row.names = FALSE)
