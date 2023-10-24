##################### Header ############################

# This script is for renaming the acoustic files from UMBEL 2022 

# Status: 

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
directory <- "E:/Test_Files/ARU0283_1627"



# Pull out the file names for the current file
UMBEL_smallfolder <- list.files(directory)

# Pull the ARU ID out of the directory
aru_id <- gsub("^(E:/)(.*/)(ARU)(.*)_(.*)","\\4",directory)

# Remove the zero from the aru_id if it starts with a zero
if(grepl("0.*",aru_id)==TRUE){
  aru_id <- gsub("^(0)(.*)","\\2",aru_id)
}

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


