##################### Header ############################

# This script is a test for renaming files

# Status: the setup works, renaming individual components part pretty much works, just need to figure out how to remove if there is a zero in the beginning of the ARU name in the file (there isn't a zero before the ARU name in the metadata as far as I know) 

#################### Read in libraries ##########################
library(tidyverse)



################## Setup - Run This Once At the Start of Analysis ################################################



# Read in metadata 
metadata <- read_csv("C:/Users/annak/OneDrive/Documents/UM/Research/UM Masters Thesis R Work/Data/Metadata/2022_ARUDeployment_Metadata_UMBEL.csv")
# Take out the weird NA values 
metadata <- metadata %>% filter(is.na(ARU_ID)==FALSE)

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

# Create an empty vector of a list of all the folders you've run so far
folders_ran <- vector()

folders_w_errors <- vector()




########################## Renaming Individual Folders ############################################

# Only thing to change between folders:
## Assign the directory to the current file you're working with 
directory <- "E:/Test_Files/ARU0311_UM040"



# Pull out the file names for the current file
UMBEL_smallfolder <- list.files(directory)

# Pull the ARU ID out of the directory
aru_id <- gsub("^(E:/)(.*/)(ARU)(.*)_(.*)","\\4",directory)

aru_id <- "0123"
# Remove the zero from the aru_id if it starts with a zero
if(grepl("0.*",aru_id)==TRUE){
  aru_id <- gsub("^(0)(.*)","\\2",aru_id)
}
# Error in is.factor(x) : argument "x" is missing, with no default
  
print(aru_id)
# Relate the ARU ID to the GPS ID in the metadata 
point_id <- metadata %>% filter(ARU_ID==aru_id) %>% select(GPS_ID)
if(length(point_id$GPS_ID)==0){
  print(paste("Folder with error is:",str_extract(directory,"ARU.*_.*")))
  folders_w_errors <- append(folders_w_errors,str_extract(directory,"ARU.*_.*"))
  stop("ARU ID not in metadata")
} else {
  # Create this single value data frame into a character object
  point_id <- as.character(point_id)
}



# List out the current file names
current_files <- UMBEL_smallfolder
# Trim out any excess characters at the beginning of the file
# Nest within an if loop with a grepl function
if(grepl("([[:digit:]]{8})_([[:digit:]]{6}).WAV",current_files[1])==FALSE){
  for(i in UMBEL_smallfolder){
    trimmed_files <- trim_name(UMBEL_smallfolder)
  }
  setwd(directory)
  file.rename(from=current_files,to=trimmed_files)
  UMBEL_smallfolder <- list.files(directory)
}

# Create a new vector that has the file names reassigned with a prefix
for(i in UMBEL_smallfolder){
  new_names <- add_prefix(UMBEL_smallfolder,point_id)
}

setwd(directory)
file.rename(from=current_files,to=new_names)
# Throwing the same error? now is returning all true instead of renaming them?

# Append the name of the folder you just ran to the list of folders that have been run
folders_ran <- append(folders_ran,str_extract(directory,"ARU.*_.*") )









################################ Extra stuff ##################################################


# This is what has worked before
# setwd("E:/Test_Files/LOC-1")
# current_files <- list.files(test_bigfolder)
# new_names <- add_prefix(current_files)
# file.rename(from=current_files,to=new_names)

# For FWP data:
# Create a function to cut the name
trim_name <- function(file_name){
  new_name <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6}).WAV")
  return(new_name)
}

################## OLD WAY #########################

# Assign the file path where the folder you're renaming is
bigfolder <- "E:/Test_Files"

# Read in the folder names from the E drive, clip everything after the prefix to just get the ARU ID
UMBEL_ARU <- list.dirs("E:/Test_Files",full.names = FALSE)
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
# Set the working directory
setwd("E:/Test_Files")
getwd()
# Read in the current file names 
current_files <- UMBEL_ARU
# Filter the values that are only in the list of things to rename 
new_names <- test1$GPS_ID
## COULD TRY TO WRAP THIS IN A FOR LOOP
file.rename(from=current_files,to=new_names)
# This is attempting to rename each folder, we need to rename the files within each folder 

UMBEL_ARU <- list.dirs("E:/Test_Files",full.names = FALSE)

#gsub(needle, replacement, haystack)
# Pull out just the ARU ID
UMBEL_ARU <- gsub("^(ARU)(.*)_(.*)","\\2",UMBEL_ARU)
# write a loop to do this:

for(folder in bigfolder){
  # It's reading bigfolder as a string
  # Take in the folder name and spit out the ARU ID for that folder
  UMBEL_ARU <- list.dirs(paste("E:/Test_Files",folder),full.names = FALSE)
  print(UMBEL_ARU)
  #prefix <- UMBEL_ARU <- gsub("^(ARU)(.*)_(.*)","\\2",UMBEL_ARU)
  
  #for(file in folder){
  #  add_prefix(file,)
  #}
}


test1 <- metadata %>% filter(ARU_ID %in% UMBEL_ARU)
# There are five that don't match
# This doesn't account for the acoustic files that aren't in the metadata


# Join them and then remove the ones that don't have an NA in the ARU ID column, then do rename.files()
length(UMBEL_ARU)
51-46
