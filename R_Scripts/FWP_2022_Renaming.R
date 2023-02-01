##################### Header ############################

# This script is for renaming the acoustic files from FWP 2022 deployment (Brandi and Nikki)

# Status: 

# 12/5/22: I went through with the updated metadata brandi sent (FWP_CuckooSiteMetadata_20-22) and assigned point IDs to all the FWP data currently collected. The point IDs consist of three letters, either the first three of the site name or the first two and second one if there were two names in the site ID, followed by a dash and then the number of the point within that site (1-3). In the case of McGraw and Pfaffinger, the sites between the years had shifted, so I gave the point ID a "2" after the main number to establish that it is different than the other if the points on the GIS layer were significantly far from each other. If the points were touching each other, they remained the same


#################### Read in libraries ##########################

library(tidyverse)
library(janitor)


################## Setup - Run This Once At the Start of Analysis ################################################

# Read in metadata 
metadata <- read_csv("C:/Users/annak/OneDrive/Documents/UM/Research/UM Masters Thesis R Work/Data/Metadata/2022_ARUDeployment_Metadata_FWPR5.csv")
# Take out the weird NA values 
metadata <- metadata %>% filter(is.na(ARU_ID)==FALSE) %>% clean_names()

# Choose just 2022 data
metadata <- metadata %>% separate(date_deployed, into = c("Day","Month","Year"), sep = "/")
metadata <- metadata %>% filter(Year == "2022") 

# Create a function to add a prefix to the name
add_prefix <- function(file_name, prefix){
  new_name <- paste(prefix,file_name,sep="_")
  return(new_name)
}

# Create a function to remove any existing prefixes from the name
trim_name <- function(file_name){
  new_name1 <- str_extract(file_name,"([[:digit:]]{8})_([[:digit:]]{6})")
  new_name <- paste(new_name1,".wav",sep="")
  return(new_name)
}


# Create an empty vector of a list of all the folders you've run so far
folders_ran <- vector()

folders_w_errors <- vector()




########################## Renaming Individual Folders ############################################

# Only thing to change between folders:
## Assign the directory to the current file you're working with 
## ADD IN THE DATA FOLDER FOR SOME
directory <- "D:/2022_FWPR5_Audio/SMM05157"
# Make sure that the folder names in the directory are in this format: YYYY_ARUID



# Pull out the file names for the current file
FWP_smallfolder <- list.files(directory)

# Pull the ARU ID out of the directory
## First test whether there is a "Data" folder, then test if there is a year in front of the audio ID
if(grepl("Data",directory)==TRUE){
  aru_extract <- gsub("^(D:/)(.*/)(\\d{4})_(.*)(/Data)","\\4",directory)
} else if (grepl("[[:upper:]]{1}:/.*/\\d{4}_.*", directory)==TRUE){
  aru_extract <- gsub("^(D:/)(.*/)(\\d{4})_(.*)","\\4",directory)
} else {
  aru_extract <- gsub("^(D:/)(.*/)(.*)","\\3",directory)
}
#print(aru_id)

# Remove the zero from the aru_id if it starts with a zero
if(grepl("0.*",aru_extract)==TRUE){
  aru_id <- gsub("^(0)(.*)","\\2",aru_extract)
} 

# Relate the ARU ID to the GPS ID in the metadata 
lpoint_id <- metadata %>% filter(aru_id==aru_extract) %>% select(point_id)
if(length(lpoint_id$point_id)==0){
  print(paste("Folder with error is:",str_extract(directory,"\\d{4}_.*")))
  folders_w_errors <- append(folders_w_errors,str_extract(directory,"ARU.*_.*"))
  stop("ARU ID not in metadata")
} else {
  # Create this single value data frame into a character object
  point_id <- as.character(lpoint_id)
}


# List out the current file names
current_files <- FWP_smallfolder
trimmed_files <- c()
# Trim out any excess characters at the beginning of the file
# Nest within an if loop with a grepl function
if(grepl("(.*)([[:digit:]]{8})_([[:digit:]]{6}).wav|[[:digit:]]{8})_([[:digit:]]{6})(.*).wav|(.*)([[:digit:]]{8})_([[:digit:]]{6})(.*).wav",current_files[1])==TRUE){
  print("trimming name")
  for(i in FWP_smallfolder){
    trimmed_file <- trim_name(i)
    trimmed_files <- append(trimmed_files,trimmed_file)
  }
  setwd(directory)
  file.rename(from=current_files,to=trimmed_files)
  FWP_smallfolder <- list.files(directory)
}


# Create a new vector that has the file names reassigned with a prefix
for(i in FWP_smallfolder){
  new_names <- add_prefix(FWP_smallfolder,point_id)
}

setwd(directory)
current_files <- FWP_smallfolder
file.rename(from=current_files,to=new_names)

# Append the name of the folder you just ran to the list of folders that have been run
folders_ran <- append(folders_ran,point_id )


