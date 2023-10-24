####### Create Functions to Rename Data ########


# A script to create functions involved in renaming files

# Created 9/27/2023

#### Setup ####
library(tidyverse)
library(janitor)


#### Read in Current Datasheets #####

# Check if "MISO" "MUSH" or "YELL" is in the directory 
# if it is, return TRUE, if not, return FALSE

function1(directory){
  
}


# Take the names from the folders and apply them to the files in the directory



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
