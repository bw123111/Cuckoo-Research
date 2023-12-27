#### Create Deliverables for Northwestern Energy ################

# This is a script for creating deliverables for Northwestern Energy

# Created: 12/21/2023
# Last updated: 12/21/2023


#### Install and Load Packages ####
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


####### 1. Number of ARU’s and number of playbacks completed in the Northwestern Energy project area (Missouri River upstream of Fort Peck Reservoir) ######

# Read in the cleaned ARU deployment metadata 
metadata <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_MetadataFull_Cleaned10-24.csv")

# Select only those within the upper MISO boundaries
## From Set Project Region Bounding Box Script
# only values that are less than -108.0743650
# only values that are greater than 47.4279918
xmin_upperMISO <- -108.0743650
ymin_upperMISO <- 47.4279918

up_MISO_ARU <- metadata %>% filter(x < -108.0743650 & y > 47.4279918)

# Select the unique point_ids
arus <- unique(up_MISO_ARU$point_id) # 73 unique sites


# Repeat with playback survey metadata
playbacks <- 


##### 2. How many locations had cuckoos heard during playbacks (I know my crew’s 2 YBCU, but if you or anyone else got any and what river they were on, would be great!) #######
# WBB - MISO
# ROB and CUL - Lower MISO
# PRD - YELL