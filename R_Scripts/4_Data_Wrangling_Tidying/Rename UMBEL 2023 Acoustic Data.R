####### UMBEL Renaming 2023 ########


# A script to rename the UMBEL data, which has the folder names labeled with the SD card ID

# Created 9/28/2023

#### Setup ####
packages <- c("stringr","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##### Functions ########
# Create a function to add a prefix to the name
add_prefix <- function(file_name, prefix){
  new_name <- paste(prefix,file_name,sep="_")
  return(new_name)
}

# Create a function to remove any existing prefixes from the name
trim_name <- function(file_name){
  new_name <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6}).WAV")
  return(new_name)
}

#### Read in Current Datasheets #####


umbel_path <- "F:/Cuckoo_Acoustic_Data/2023/UMBEL_Test/Test_UMBEL_Unnamed/"

# Read in metadata 
metadata <- read.csv("C:/Users/ak201255/Documents/Cuckoo-Research/Data/Metadata/Outputs/2023_ARURetrieval_Metadata_Cleaned9-28.csv")
# sd_card_id is the name of the column


# Establish the base directory
base_dir <- umbel_path

# Pull out the directories within this one
all_dirs <- list.dirs(base_dir, full.names = TRUE)

# Filter out the base directory itself
sub_dirs <- all_dirs[all_dirs != base_dir]


for (folder in sub_dirs) {
  # Get the last folder name from the path
  sd_id <- basename(folder)
  print(paste("sd id is",sd_id))
  # Get a list of file names in the current subdirectory
  files_in_folder <- list.files(folder, full.names = TRUE)
  #print(files_in_folder)
  #  ????? Relate SD ID to point ID - find where in the metadata the SD ID is an pull the correct point name to go along with it
  # Find the row in the metadata where sd_card_id matches sd_id
  metadata_row <- metadata[metadata$sd_card_id == sd_id, ]
  
  # Extract the point_id from the matching row and establish this as the prefix
  prefix <- metadata_row$point_id
  print(paste("prefix is",prefix))
  
  
  # Iterate through the list of file names in the subdirectory
  for (file_name in files_in_folder) {
    # Call the trim_names function 
    trimmed_name <- trim_name(file_name)
    
    # Call the add_prefix function to rename the file
    new_name <- add_prefix(basename(trimmed_name), prefix)
    
    print(new_name)
    # Rename the file using file.rename
    #file.rename(file_name, file.path(dirname(file_name), new_name))
  }
  # ????? rename the folder to be the prefix
  # Rename the folder using file.rename
  new_folder_path <- file.path(dirname(folder), point_id)
  
  if (!file.rename(folder, new_folder_path)) {
    # Handle the case where renaming fails (e.g., due to permission issues)
    print(paste("Failed to rename folder:", folder))
  } else {
    # Print a message indicating a successful rename
    print(paste("Renamed folder to:", point_id))
  }
}

#### CODE GRAVEYARD ########## 
# for (folder in sub_dirs) {
#   # Get the last folder name from the path
#   sd_id <- basename(folder)
#   print(paste("SD ID is",sd_id))
#   # Get a list of file names in the current subdirectory
#   files_in_folder <- list.files(folder, full.names = TRUE)
#   #print(files_in_folder)
#   # Create the prefix using the last folder name
#   # sd <- last_folder
#   # print(paste("SD ID is",prefix))
#   
#   # match the SD ID to the point ID in the metadata and use that to create the prefix value
#   # Iterate through the list of file names in the subdirectory
#   #for (file_name in files_in_folder) {
#     
#     # Call the add_prefix function to rename the file
#     #  new_name <- add_prefix(basename(trimmed_name), prefix)
#     
#     #  print(new_name)
#     # Rename the file using file.rename
#     #file.rename(file_name, file.path(dirname(file_name), new_name))
#   #}
# }