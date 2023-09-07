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
deployed <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_Metadata_Cleaned9-7.csv") %>% clean_names()

# Check for duplicates
# points_deployed <- unique(deployed$point_id)
deployed_nodup <- deployed[duplicated(deployed$point_id)==FALSE,] # 154 points
  
retrieved <- read.csv("./Data/Metadata/Outputs/2023_ARURetrieval_Metadata_Cleaned9-7.csv") %>% clean_names()

# Check for duplicates
points_retrieved <- retrieved$point_id
# dup_points <- retrieved[duplicated(retrieved$point_id)==TRUE,]
# no duplicated values 

# filter out the points that are still out
ARUS_still_out <- deployed_nodup %>% filter(!(point_id %in% points_retrieved))


# Clean up this data frame
ARUS_still_out <- ARUS_still_out %>% select(river, point_id, aru_id, x, y)

# Write this to a csv to send to collaborators
write.csv(ARUS_still_out,"./Data/Metadata/Outputs/2023_ARUsStillOut_9-7.csv", row.names = FALSE)










##### Code Graveyard ####
# OLD: Pull out the site_id columns
#pts_deployed <- deployed$point_id
#pts_retrieved <- retrieved$point_id

#ARUS_still_out %>% filter(river == "Yellowstone")
# Just a mismatch of one, had to take into account that some monitors deployed twice for repairs


