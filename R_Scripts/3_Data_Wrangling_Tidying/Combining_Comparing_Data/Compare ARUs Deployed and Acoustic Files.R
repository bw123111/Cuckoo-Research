#### Compare ARUs Deployed and Acoustic Files on Drive #####

# this is a script to read in datasheets for monitors that have been deployed and list the folders in the acoustic data directory and compare them to ensure there were no monitors deployed that aren't accounted for

# Created 1/22/2024

# Last updated 1/23/2024

#### Install and load pacakges #####
packages <- c("tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)

#### Code #####
# Read in current dataset for monitors deployed and monitors retrieved (downloaded from Survey123)
deployed <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_MetadataFull_Cleaned10-24.csv") %>% clean_names()
umbel_22 <- read.csv("./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_UMBEL_Cleaned1-22.csv") %>% clean_names()
fwp_22 <- read.csv("./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_FWPALL_Cleaned1-22.csv") %>% clean_names()
metadat_21 <- read.csv("./Data/Metadata/Outputs/2021_ARUDeployment_Retrieval_Metadata_UMBEL_Cleaned1-22.csv") %>% clean_names()
metadat_21 %>% filter(data_recorded == 'N') %>% select(point_id)

# Formatting 2023 data
# Check for duplicates
# points_deployed <- unique(deployed$point_id)
deployed_nodup <- deployed[duplicated(deployed$point_id)==FALSE,] # 154 points

# Formatting 2021 data
points1 <- umbel_22$point_id
points2 <- fwp_22$point_id
points_22 <- c(points1,points2)
test <- points_22[duplicated(points_22)==FALSE] # no duplicates

# Formatting 2021 data
points_21 <- metadat_21$point_id
test <- points_21[duplicated(points_21)==FALSE] # no duplicates



# make this a function to list out the names of the acoustic folders
list_audio_files <- function(year, collab){
  acoustic_dat <- "F:/Cuckoo_Acoustic_Data/"
  subfolder <- paste0(acoustic_dat,year,'/',year,'_',collab,'_Data/',year,'_',collab,'_Audio/')
  acoustic_folders <- list.files(subfolder)
  return(acoustic_folders)
}


# Put the function into a loop
years <- c('2021')
collabs <- c('UMBEL')
# ,'FWPR7','FWPR6','FWPR5'

all_audio <- list()
for (year in years){
  print(paste('year is',year))
  for (name in collabs){
    print(paste('name is',name))
    audio_files <- list_audio_files(year, name)
    all_audio <- c(all_audio,audio_files)
    all_audio <- unlist(all_audio,recursive = FALSE)
  }
}

# Compare all_audio with the ARUs deployed
deployed_no_audio_23 <- deployed_nodup %>% filter(!(point_id %in% all_audio))
# MISO-197 retrieved late, need to run through the model
# MISO-091 was the one the landowner picked up 
# 2023: These are good, all accounted for

deployed_no_audio_22 <- points_22[!points_22 %in% all_audio]
# 102-3 no data recorded on SD card
# 103-1 no data recorded on SD card
# MAN-1,MAN-2,MAN-3 removed by humans
# ISA-2 SD card corrupted 
# 2022: All accounted for

deployed_no_audio_21 <- points_21[!points_21 %in% all_audio]
# 101-1, 103-2, 104-2, 104-3, 222-1, 222-3, 223-2, 224-3, 97-3, SIP-1 no data recorded 
#223-3 originally assigned to another point? No audio files  
# MAN-1 ARU went missing
# 2021: All accounted for

#### Code Graveyard ####
# Read in the path to acoustic data
# acoustic_dat <- "F:/Cuckoo_Acoustic_Data/"
# year = "2023"
# collab = "UMBEL"
# subfolder <- paste0(acoustic_dat,year,'/',year,'_',collab,'_Data/',year,'_',collab,'_Audio/')
# acoustic_folders <- list.files(subfolder)
# points_22 <- as.data.frame(points_22, colnames(points_22) <- c('point_id'))