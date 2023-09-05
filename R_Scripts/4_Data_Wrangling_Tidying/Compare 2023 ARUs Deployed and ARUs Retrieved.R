#### Compare ARUs Deployed and ARUs Retrieved #####

# this is a script to read in datasheets for monitors that have been deployed and monitors that have been retrieved and see which sites are missing (should be 20 that aren't accounted for)

# Created 9/5/2023

# Last updated 9/5/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

#### Code #####

# Read in current dataset for monitors deployed and monitors retrieved (downloaded from Survey123)
deployed <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_Metadata_Cleaned9-5.csv") %>% clean_names()
  
retrieved <- read.csv("./Data/Metadata/Outputs/2023_ARURetrieval_Metadata_Cleaned9-5.csv") %>% clean_names()

# Pull out the site_id columns
pts_deployed <- deploy$point_id

pts_retrieved <- retrieve$point_id


ARUS_still_out <- deploy %>% filter(!(point_id %in% pts_retrieved))
# Why are there 15 of these, but there were 160 deployed and 140 retrieved????????
