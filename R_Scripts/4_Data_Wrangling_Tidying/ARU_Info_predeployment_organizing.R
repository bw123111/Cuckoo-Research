######### Split and Wrangle ARU Testing Data #################

# This is a script for reading in the ARU testing file, creating inventories for each organization, and counting how many ARUs are useable for the field season

# Created: 4/24/2023
# Last updated: 4/24/2023


######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############

# Load in ARU testing data
aru_all <- read_csv(".\\Data\\ARU_Info\\2023_ARUInventory_UMBEL_FWP.csv") %>% clean_names()
class(aru_all$aru_model) # character
nrow(aru_all)

# First, we need to create new datasheets for the different organizations and write them to csvs
aru_UMBEL <- aru_all %>% filter(aru_owner == "APR")
aru_FWPR7 <- aru_all %>% filter(aru_owner == "FWPR7")
aru_FWPR6 <- aru_all %>% filter(aru_owner == "FWPR6")
aru_FWPR5 <- aru_all %>% filter(aru_owner == "FWPR5")
# Check that you're capturing all the data
nrow(aru_UMBEL)+nrow(aru_FWPR5)+nrow(aru_FWPR6)+nrow(aru_FWPR7) # correct number

# Write these files to .csv
# write.csv(aru_UMBEL,".\\Data\\ARU_Info\\2023_ARUInventory_APR-UMBEL.csv",row.names=FALSE)
# write.csv(aru_FWPR7,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR7.csv",row.names=FALSE)
# write.csv(aru_FWPR6,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR6.csv",row.names=FALSE)
# write.csv(aru_FWPR5,".\\Data\\ARU_Info\\2023_ARUInventory_FWPR5.csv",row.names=FALSE)


# START HERE 4/25 : FILTER OUT THE B TEAM AS WELL
# Split out the ones that are good to go and the ones that aren't
aru_good <- aru_all %>% filter(use_2023 =="yes")
aru_bad <- aru_all %>% filter(use_2023 =="no")
nrow(aru_good)+nrow(aru_bad)
# 3 missing?
aru_miss <- aru_all %>% filter(is.na(use_2023) ==TRUE) # this accounts for the three missing ones


# make this into a function
count_arus <- function(data){
  ARUs_touse <- data %>% filter(use_2023 == "yes") 
  ARUS_touse <- ARUs_touse %>% filter(use_as_b_team!="yes")
  ARUmodel_table <- ARUs_touse %>% group_by(aru_model) %>% summarize(n=n())
  return(ARUmodel_table)
}

# Summarize the number of each type of ARU and sum the total ARUs available to use
UMBEL_count <- count_arus(aru_UMBEL)
sum(UMBEL_count$n) # 76
FWPR7_count <- count_arus(aru_FWPR7)
sum(FWPR7_count$n) # 53
FWPR6_count <- count_arus(aru_FWPR6)
sum(FWPR6_count$n) # 13
FWPR5_count <- count_arus(aru_FWPR5)
sum(FWPR5_count$n) # 24

# In deployments, randomly sample the ARU model from these tables


########### Snippings ############

# # Split out the number of useable ARUs and their model for each organization
# UMBEL_use <- aru_UMBEL %>% filter(use_2023 == "yes")
# UMBEL_usetotal <- nrow(UMBEL_use) #76
# class(aru_UMBEL$aru_model)
# # group by model and summarize how many of each 
# UMBEL_mod_table <- UMBEL_use %>% group_by(aru_model) %>% summarize(n=n())
# # in deployments, randomly draw from these
