##################### Header Contents ############################
# Intro, when it was created, what does it do, etc 

# This script is for renaming the files contributed by UMBEL/MT Audubon in 2022

#################### Writing in UMBEL Code ######################

#################### Read in libraries ##########################
library(tidyverse)



##################################################################

# read in metadata 
metadata <- read_csv("C:/Users/annak/OneDrive/Documents/UM/Research/UM Masters Thesis R Work/Data/Metadata/2022_ARUDeployment_Metadata_UMBEL.csv")
# Take out the weird NA values 
metadata <- metadata %>% filter(is.na(ARU_ID)==FALSE)

# Assign the file path where the folder you're renaming is
bigfolder <- "E:/Test_Files"



# Create a function to cut the name
trim_name <- function(file_name){
  new_name <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6}).WAV")
  return(new_name)
}


# Create a function to add a prefix to the name
add_prefix <- function(file_name, prefix){
  new_name <- paste(prefix,file_name,sep="_")
  return(new_name)
}



# Read in the folder names from the E drive, clip everything after the prefix to just get the ARU ID
UMBEL_ARU <- list.dirs("E:/2022_UMBEL_Data",full.names = FALSE)

#gsub(needle, replacement, haystack)
# Pull out just the ARU ID
UMBEL_ARU <- gsub("^(ARU)(.*)_(.*)","\\2",UMBEL_ARU)
# Take out the empty first value 
UMBEL_ARU <- UMBEL_ARU[-1]

# Test if all of the ARU_IDs from the acoustic data are in the metadata file
for(i in 1:length(UMBEL_ARU)){
  print(UMBEL_ARU[i]%in%metadata$ARU_ID)
}

# Test if all of the metadata are in the acoustic files  
metadata_list <- metadata$ARU_ID
metadata_list %in% UMBEL_ARU


# Link the GPS_ID with the ARU ID from the list
# Pull in the metadata sheet and filter for the ARU_ID equal to the folder you're trying to rename, then pull the column for GPS_ID to assign to prefix 
# Add it to a list of matched files 
#!(x %in% y) for not i 


test1 <- metadata %>% filter(ARU_ID %in% UMBEL_ARU)
# There are five that don't match
# This doesn't account for the acoustic files that aren't in the metadata


# Join them and then remove the ones that don't have an NA in the ARU ID column, then do rename.files()
length(UMBEL_ARU)
51-46
  
# Final step: rename files
setwd("E:/Test_Files/LOC-1")
current_files <- list.files(test_bigfolder)
new_names <- add_prefix(current_files)
file.rename(from=current_files,to=new_names)

# Test the functions
test3 <- "EXTRA_20220624_010000.WAV"
test4 <- "20220624_010000.WAV"
test_file <- "SMM05169_20220627_115443.WAV"
trim_name(test3)
trim_name(test_file)
# Works
add_prefix(test4,"LOC-1")
# Works
getwd()
# Test out renaming a file by reading in a file path
# Set the working directory to the step above the files 
setwd("E:/Test_Files/LOC-1")
current_files <- list.files(test_bigfolder)
current_files
getwd()
new_names <- trim_name(current_files)
new_names
getwd()
list.files(test_bigfolder)
file.rename(from=current_files,to=new_names)
getwd()