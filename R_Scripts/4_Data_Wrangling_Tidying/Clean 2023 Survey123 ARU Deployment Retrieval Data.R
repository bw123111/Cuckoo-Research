#### Clean 2023 ARU Survey123 Deployment Retrieval Data #####

# this is a script to read in the deployment and retrieval data from 2023 and clean the data so it can be used

# Created 9/5/2023

# Last updated 9/12/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

#### Code #####


# Cleaning Data (Last Updated 9-5)

# Clean Deployment data
# read in the data from the Raw Data folder
deploy <- read.csv("./Data/Metadata/Raw_Data/2023_ARUDeployment_Metadata_9-5.csv") %>% clean_names()

# Remove the first six columns that have metadata from Survey123 that we don't need
deploy <- deploy %>% select(-(1:6))


# Clean Initials 
## Change DJ or DEJ to DAJ

# point_id
## Make sure they are all capital case
deploy$point_id <- toupper(deploy$point_id)

# change any "_" in the data to "-"
deploy <- deploy %>% mutate(point_id = str_replace(point_id, "_", "-"))

# fix the spelling of the point_id
## first separate point ID
deploy_sep <- deploy %>% separate(point_id, into = c("site","point"), sep = "-")
## Pull out the unique values of site
sites <- unique(deploy_sep$site)
# Remove the space in the SD card IDs
deploy_sep <- deploy_sep %>% mutate(sd_card_id = str_replace(sd_card_id, " ", ""))
# Remove the space in the ARU ID
deploy_sep <- deploy_sep %>% mutate(aru_id = str_replace(aru_id, " ", ""))
## Replace any unusual values from sites
deploy_sep <- deploy_sep %>% mutate(site = str_replace(site, "MISS", "MISO"))
deploy_sep <- deploy_sep %>% mutate(site = str_replace(site, "MISI", "MISO"))
# Check that MISS is gone
unique(deploy_sep$site)
## Looks good
# Manually look through the point column to make sure that habitat sites have three numbers
## Need to change MISO 069
## Change row 68, column 6
deploy_sep[68,6] <- "069"
# Change the row with UM022 that should be UM028
deploy_sep[125,17] <- "UM028"
# Unite the columns for site and point
deploy <- deploy_sep %>% 
  unite(col = point_id, c("site","point"), sep="-")

# Write the new, cleaned data to ouputs
write.csv(deploy,"./Data/Metadata/Outputs/2023_ARUDeployment_Metadata_Cleaned9-12.csv", row.names = FALSE)





# Clean retrieval data

# Read in data from Raw Data folder
retrieve <- read.csv("./Data/Metadata/Raw_Data/2023_ARURetrieval_Metadata_9-7.csv") %>% clean_names()

# Remove the first six columns that have metadata from Survey123 that we don't need
retrieve <- retrieve %>% select(-(1:6))

# make sure all point ID are upper case
retrieve$point_id <- toupper(retrieve$point_id)
# separate point ID into site and point for cleaning
retrieve_sep <- retrieve %>% separate(point_id, into = c("site","point"), sep = "-")
# Replace any misspellings
retrieve_sep <- retrieve_sep %>% mutate(site = str_replace(site, "MISI", "MISO"))
retrieve_sep <- retrieve_sep %>% mutate(site = str_replace(site, "YEL-", "YELL-"))
# Remove the space in the SD card IDs
retrieve_sep <- retrieve_sep %>% mutate(sd_card_id = str_replace(sd_card_id, " ", ""))
# Remove the space in the ARU ID
retrieve_sep <- retrieve_sep %>% mutate(aru_id = str_replace(aru_id, " ", ""))
# Edit one point to be the correct format
retrieve_sep[42,5] <- "069"
# Edit the monitor at CUL-3
retrieve_sep[24,6] <- "006"
# Edit the ID that should be ROB-2 but was input as ROB-1
retrieve_sep[26,5] <- "2"
# Change the row with UM022 that should be UM028
retrieve_sep[77,7] <- "UM028"
# Unite the columns
retrieve <- retrieve_sep %>% 
  unite(col = point_id, c("site","point"), sep="-")

# Write the new, cleaned data to ouputs
write.csv(retrieve,"./Data/Metadata/Outputs/2023_ARURetrieval_Metadata_Cleaned9-12.csv", row.names = FALSE)
