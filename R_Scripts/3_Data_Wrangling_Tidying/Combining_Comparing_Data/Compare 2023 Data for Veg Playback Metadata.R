#### Compare Veg Data, Playbacks, and Metadata ###################

## Purpose: to read in the cleaned veg data and metadata in order to compare which sites are complete and which aren't 

# Created 10/25/2023

# Last modified: 10/25/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# Read in data
veg_dat <- read.csv("./Data/Vegetation_Data/Outputs/2023_VegSurveyData_Cleaned10-25.csv")

# Read in current dataset for monitors deployed and monitors retrieved (downloaded from Survey123)
deployed <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_MetadataFull_Cleaned10-24.csv") %>% clean_names()

playback <- 

# Check for duplicates
# points_deployed <- unique(deployed$point_id)
deployed_nodup <- deployed[duplicated(deployed$point_id)==FALSE,] # 154 points


# Look at how many of the sites have an ARU
aru_sites <- veg_dat %>% filter(aru_present == "yes")
# 152 of these - two missing, need to see if these line up with the two sites that are missing from the retrieval
# find the points that are in the deployment data that arent in veg survey data
aru_missing_veg <- anti_join(deployed_nodup,aru_sites, by = "point_id")

noaru_sites <- veg_dat %>% filter(aru_present == "no")
# need to figure out how many of the playback sites also had an ARU present


# get the numbers for each of them- see if they match up

# compare them to playback_all from Clean 2023 Playback Data