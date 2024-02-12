####### Renaming 2023 ########


# A script to rename the 2023 data formatted with folder names labeled with the point ID

# Created 9/28/2023
# last modified 12/1/2023

#### Setup ####
packages <- c("stringr","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


#### Establish path to folders of files you want to rename #####
# you only need to change this, then run the rest of the code
input_path <- "F:/Cuckoo_Acoustic_Data/2023/2023_UMBEL_Data/2023_UMBEL_Audio/"
#r6_output_path <- "F:/Cuckoo_Acoustic_Data/2023/R6_Test/Test_R6_Renamed/"


##### Functions ########
# Create a function to add a prefix to the name
add_prefix <- function(file_name, prefix){
  new_name <- paste(prefix,file_name,sep="_")
  return(new_name)
}

# Create a function to remove any existing prefixes from the name
trim_name <- function(file_name){
  new_name <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6}).WAV|([[:digit:]]{8})_([[:digit:]]{6}).wav")
  return(new_name)
}


#### Rename the files #########################
# Establish the base directory
base_dir <- input_path

# Pull out the directories within this one
all_dirs <- list.dirs(base_dir, full.names = TRUE)

# Filter out the base directory itself
sub_dirs <- all_dirs[all_dirs != base_dir]


for (folder in sub_dirs) {
  # Get the last folder name from the path
  last_folder <- basename(folder)
  print(last_folder)
  # Get a list of file names in the current subdirectory
  files_in_folder <- list.files(folder, full.names = TRUE)
  #print(files_in_folder)
  # Create the prefix using the last folder name
  prefix <- last_folder
  print(paste("prefix is",prefix))
  
  
  # Iterate through the list of file names in the subdirectory
  for (file_name in files_in_folder) {
    # Call the trim_names function 
    trimmed_name <- trim_name(file_name)
    #print(trimmed_name)
    
    # Call the add_prefix function to rename the file
    new_name <- add_prefix(basename(trimmed_name), prefix)
    
    print(new_name)
    # Rename the file using file.rename
    file.rename(file_name, file.path(dirname(file_name), new_name))
  }
}



######### Code Graveyard ########
# # Create an emtpy list for the file names
# file_names_list <- list()
# 
# # Iterate through each folder in the directories and pull out the file names
# for (folder in sub_dirs){
#   # Get a list of file names in the current subdirectory
#   files_in_sub_dir <- list.files(folder, full.names = FALSE)
#   
#   # Store the file names in the list with the subdirectory path as the list name
#   file_names_list[[folder]] <- files_in_sub_dir
# }


# for (folder in sub_dirs) {
#   # Get the last folder name from the path
#   last_folder <- basename(folder)
#   print(last_folder)
#   # Get a list of file names in the current subdirectory
#   files_in_folder <- list.files(folder, full.names = TRUE)
#   #print(files_in_folder)
#   # Create the prefix using the last folder name
#   prefix <- last_folder
#   print(paste("prefix is",prefix))
#   
#   new_name <- gsub("([[:digit:]]{8}_[[:digit:]]{6}.WAV)|(.*)_([[:digit:]]{8}_[[:digit:]]{6}.wav)", paste(prefix,"\\2"),files_in_folder)
#   print(new_name)
#   # Rename the file using file.rename
#   #file.rename(file_name, file.path(dirname(file_name), new_name))
# 
# }

# change_name <- function(file_names, prefix){
#   # pattern, replacement, character strings
#   new_name <- gsub("(.*)([[:digit:]]{8}_[[:digit:]]{6}.WAV)|(.*)([[:digit:]]{8}_[[:digit:]]{6}.wav)", paste(prefix,"\\2"),file_name)
#   return(new_name)
# }