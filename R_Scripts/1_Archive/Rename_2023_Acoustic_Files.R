####### Rename 2023 Acoustic Files ########


# A script to create functions involved in renaming files

# Created 9/27/2023

#### Setup ####
library(tidyverse)
library(janitor)
library(stringr)



##### Functions from Create Functions File ######

# Create a function to add a prefix to the name
add_prefix <- function(file_name, prefix){
  new_name <- paste(prefix,file_name,sep="_")
  return(new_name)
}

# Create a function to remove any existing prefixes from the name
# trim_name <- function(file_name){
#   new_name <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6}).WAV")
#   return(new_name)
# }

# Create a function to remove any existing prefixes from the name
trim_name <- function(file_name){
  # Attempt to extract the desired pattern
  extracted <- str_extract(file_name, "([[:alnum:]_]+)_\\d{8}_\\d{6}")
  
  # If extraction is successful, return the extracted value; otherwise, return the original file name
  if (!is.na(extracted)) {
    return(extracted)
  } else {
    warning ("Unable to trim name")
  }
}


#### Read in Current Datasheets #####

r6_path <- "F:/Cuckoo_Acoustic_Data/2023/R6_Test/Test_R6_Unnamed/"
umbel_path <- "F:/Cuckoo_Acoustic_Data/2023/UMBEL_Test/Test_UMBEL_Unnamed2/"

# Establish the base directory
base_dir <- r6_path

# Pull out the directories within this one
all_dirs <- list.dirs(base_dir, full.names = TRUE)

# Filter out the base directory itself
sub_dirs <- all_dirs[all_dirs != base_dir]

# Create an emtpy list for the file names
file_names_list <- list()

# Iterate through each folder in the directories and pull out the file names
for (folder in sub_dirs){
  # Get a list of file names in the current subdirectory
  files_in_sub_dir <- list.files(folder, full.names = FALSE)
  
  # Store the file names in the list with the subdirectory path as the list name
  file_names_list[[folder]] <- files_in_sub_dir
}

#file_names_list$"F:/Cuckoo_Acoustic_Data/2023/R6_Test/Test_R6_Unnamed//CUL-1"

# First, test if the names of the sites are already assigned to the data
folder_names <- basename(sub_dirs)

# Check if "MISO", "MUSH", or "YELL" are in any of the last_folders
check_folder_site_names <- function(names_of_folders){
  contains_strings <- grepl("MISO|MUSH|YELL", names_of_folders)
  contains_any_string <- function(contains_strings) {
    return(any(contains_strings))
  }
  result <- contains_any_string(contains_strings)
  return(result)
}

# Put in folder names into the function
test1 <- check_folder_site_names(folder_names)



# If TRUE, rename the data by reading in the directory names and adding that as a prefix
if (test1 == TRUE){
  for (file in directory){
    add_prefix(name, file)
  }
}

for (folder in sub_dirs) {
  # Get the last folder name from the path
  last_folder <- basename(folder)
  #print(last_folder)
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
    
    ##### THIS PART NOT WORKING ########
    
    # Call the add_prefix function to rename the file
    new_name <- add_prefix(basename(trimmed_name), prefix)
    
    print(new_name)
    # Rename the file using file.rename
    #file.rename(file_name, file.path(dirname(file_name), new_name))
  }
}

# If FALSE , read in the metadata and match them up