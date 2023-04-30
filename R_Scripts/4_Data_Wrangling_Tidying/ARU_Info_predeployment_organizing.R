######### Split and Wrangle ARU Testing Data #################

# This is a script for reading in the ARU testing file, creating inventories for each organization, and counting how many ARUs are useable for the field season

# Created: 4/24/2023
# Last updated: 4/28/2023


######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############

# Load in ARU testing data
aru_all <- read_csv(".\\Data\\ARU_Info\\2023_ARUInventory_UMBEL_FWP.csv") %>% clean_names()
#class(aru_all$aru_model) # character
#nrow(aru_all)

# First, we need to create new datasheets for the different organizations and write them to csvs
aru_UMBEL <- aru_all %>% filter(aru_owner == "APR")
aru_FWP <- aru_all %>% filter(aru_owner == "FWPR7"| aru_owner == "FWPR6" | aru_owner == "FWPR5")
aru_FWPR7 <- aru_all %>% filter(aru_owner == "FWPR7")
aru_FWPR6 <- aru_all %>% filter(aru_owner == "FWPR6")
aru_FWPR5 <- aru_all %>% filter(aru_owner == "FWPR5")
# Check that you're capturing all the data
#nrow(aru_UMBEL)+nrow(aru_FWPR5)+nrow(aru_FWPR6)+nrow(aru_FWPR7) # correct number

# Write these files to .csv
# write.csv(aru_UMBEL,".\\Data\\ARU_Info\\2023_ARUInventory_APR-UMBEL.csv",row.names=FALSE)
# write.csv(aru_FWPR7,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR7.csv",row.names=FALSE)
# write.csv(aru_FWPR6,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR6.csv",row.names=FALSE)
# write.csv(aru_FWPR5,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR5.csv",row.names=FALSE)


# Split out the ones that are good to go and the ones that aren't
aru_good <- aru_all %>% filter(use_2023 =="yes")
aru_bad <- aru_all %>% filter(use_2023 =="no")
#nrow(aru_good)+nrow(aru_bad)
# 3 missing?
aru_miss <- aru_all %>% filter(is.na(use_2023) ==TRUE) # this accounts for the three missing ones


# Function to count the ARUs
count_arus <- function(data){
  aru_touse <- data %>% filter(use_2023 == "yes") # filter out only the ARUs that tested well and are configured
  aru_touse <- aru_touse %>% filter(!use_as_b_team %in% "yes") # filter out only the ARUs that are to not be used as backups
  ARUmodel_table <- aru_touse %>% group_by(aru_model) %>% summarize(n=n()) # summarize the types of each model
  return(ARUmodel_table)
}

# Summarize the number of each type of ARU and sum the total ARUs available to use
UMBEL_count <- count_arus(aru_UMBEL)
sum(UMBEL_count$n) # 73   # 45 points already, need to select 28 new
FWP_count <- count_arus(aru_FWP)
FWPR7_count <- count_arus(aru_FWPR7)
sum(FWPR7_count$n) # 49
FWPR6_count <- count_arus(aru_FWPR6)
sum(FWPR6_count$n) # 13
FWPR5_count <- count_arus(aru_FWPR5)
sum(FWPR5_count$n) # 24


# For deployments, we want to randomly sample the ARU model for each point from these tables
## In deployments, randomly sample the ARU model from these tables
trim_arus <- function(data){
  aru_touse <- data %>% filter(use_2023 == "yes") # filter out only the ARUs that tested well and are configured
  aru_touse <- aru_touse %>% filter(!use_as_b_team %in% "yes") # filter out only the ARUs that are to not be used as backups
  return(aru_touse)
}
# checked: function works well

# Run the function to pull out the useable ARUs on the UMBEL and FWP data
UMBEL_filtered <- trim_arus(aru_UMBEL)
FWP_filtered <- trim_arus(aru_FWP)
# randomly draw from this column to populate the ARU model column in the other data


# Read in final survey points
UMBEL_points <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_UMBEL_BaseGRTSandRepeats_noARUModel.csv") %>% clean_names()
R5_points <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_BaseGRTSandRepeats.csv") %>% clean_names()
str(R5_points)
# Since there are TBDs in the long and lat column, they are being read in as characters, so let's fix these
R5_points$lon_wgs84 <- as.numeric(R5_points$lon_wgs84)
R5_points$lat_wgs84 <- as.numeric(R5_points$lat_wgs84)
R6_points <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_R6_BaseGRTSandRepeats.csv") %>% clean_names()
str(R6_points)
R7_points <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone River\\2023_R7_BaseGRTSandRepeats.csv") %>% clean_names()
str(R7_points)

# Create a dataframe for all the FWP points
FWP_points <- rbind(R5_points,R6_points,R7_points)
str(FWP_points)

# Resample the aru model from the aru data
FWP_points$aru_model <- sample(FWP_filtered$aru_model, size = nrow(FWP_points), replace=FALSE)
# test
#nrow(FWP_points)
nrow(FWP_points %>% filter(aru_model=="SMM"))
nrow(FWP_points %>% filter(aru_model=="AM1.2.0"))

#nrow(FWP_filtered)
nrow(FWP_filtered %>% filter(aru_model=="SMM"))
nrow(FWP_filtered %>% filter(aru_model=="AM1.2.0"))
# This is working now

# split apart the data by organization and export it
r5_new <- FWP_points %>% filter(river=="Musselshell")
r6_new <- FWP_points %>% filter(river=="Missouri")
r7_new <- FWP_points %>% filter(river=="Yellowstone")

# export the data
# write.csv(FWP_points,".\\Data\\Spatial_data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_FWPAll_BaseGRTSandRepeats.csv",row.names=FALSE)
# write.csv(r5_new,".\\Data\\Spatial_data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_BaseGRTSandRepeats.csv",row.names=FALSE)
# write.csv(r6_new,".\\Data\\Spatial_data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_R6_BaseGRTSandRepeats.csv",row.names=FALSE)
# write.csv(r7_new,".\\Data\\Spatial_data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone River\\2023_R7_BaseGRTSandRepeats.csv",row.names=FALSE)

# Repeat with UMBEL 
nrow(UMBEL_points)
nrow(UMBEL_filtered)
# filter out the repeat playbacks sites
umbel_grts <- UMBEL_points %>% filter(!siteuse_new %in% "Repeat_Playbacks")
umbel_rp <- UMBEL_points %>% filter(siteuse_new == "Repeat_Playbacks")

umbel_grts$aru_model <- sample(UMBEL_filtered$aru_model, size = nrow(umbel_grts), replace=FALSE)
# test to make sure these are correct
nrow(umbel_grts %>% filter(aru_model =="AM1.0.0"))
nrow(umbel_grts %>% filter(aru_model =="AM1.1.0"))
nrow(umbel_grts %>% filter(aru_model =="AM1.2.0"))
# good to go 

# combine umbel grts back with umbel rp
umbel_new <- rbind(umbel_grts,umbel_rp)

# write this to csv
write.csv(umbel_new,".\\Data\\Spatial_data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_UMBEL_BaseGRTSandRepeats.csv",row.names=FALSE)


# UMBEL_toedit <- UMBEL_toedit %>% mutate(ARU_model=sample(UMBEL_list,replace=FALSE))
# length(UMBEL_toedit %>% filter(ARU_model=="AM1.0.0"))

# read in the repeat points data
repeats <- read_csv(".\\Data\\ARU_Info\\Repeat_Monitoring_Points_2023.csv") %>% clean_names()

## Post GRTS Data Processing ####
AM1 <- rep("AM1.0.0", times = 9)
AM1.1 <- rep("AM1.1.0", times = 37)
AM2 <- rep("AM1.2.0", times = 27)
UMBEL_list <- c(AM1,AM1.1,AM2)

test <- sample(UMBEL_list,replace=FALSE)
length(test=="AM1.0.0")
# Giving 73??


########### Snippings ############

# FWP_points <- bind_rows(R5_points,R6_points,R7_points)
# str(FWP_points)
# # siteuse_new got split into two columns
# FWP_points$test <- coalesce(FWP_points$sitesuse_new,FWP_points$siteuse_new) 
# FWP_points <- FWP_points %>% select(-siteuse_new)
# FWP_points <- FWP_points %>% select(-sitesuse_new)


# # Split out the number of useable ARUs and their model for each organization
# UMBEL_use <- aru_UMBEL %>% filter(use_2023 == "yes")
# nrow(UMBEL_use)
# test <- UMBEL_use %>% filter(!use_as_b_team %in% "yes") # this is zero
# nrow(test)
# UMBEL_usetotal <- nrow(UMBEL_use) #76
# class(aru_UMBEL$aru_model)
# # group by model and summarize how many of each 
# UMBEL_mod_table <- UMBEL_use %>% group_by(aru_model) %>% summarize(n=n())
# # in deployments, randomly draw from these
