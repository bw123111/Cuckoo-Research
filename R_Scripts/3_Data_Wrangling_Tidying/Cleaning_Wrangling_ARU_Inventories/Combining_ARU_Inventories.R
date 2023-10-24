######### Condensing ARU Metadata for Testing #################


# This is a script for reading in all of the ARU inventories and pulling them into one file

######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

##### Code ##############

# no inventory for FWP R6 and FWP R5
# only reading in UMBEL and FWP R7

UMBEL <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Resources\\ARU_Inventory-Testing\\2022MMR_ARU_Status_All.csv")
UMBEL <- UMBEL %>% clean_names()
# super long, just select the needed rows and columns
#BBCU -06
UMBEL <- UMBEL %>% select(1:9)
UMBEL <- UMBEL %>% filter(is.na(aru_owner)==FALSE)
UMBEL <- UMBEL %>% select(aru_owner,aru_id,sd_id, unit_condition)

# R7
R7 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Resources\\ARU_Inventory-Testing\\InventoryARUsRegion7.csv")
R7 <- clean_names(R7)

# reorder the columns and rbind them
R7 <- R7 %>% rename(aru_owner=region) %>% select(aru_owner,aru_id,sd_id,unit_condition)
R7 <- R7 %>%mutate(aru_owner = str_replace(aru_owner, "7", "FWPR7"))

aru_inventory <- rbind(R7,UMBEL)
aru_inventory <- aru_inventory %>% mutate(unit_condition = str_replace(unit_condition,"Good","good"))


# export it
write.csv(aru_inventory,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Resources\\ARU_Inventory-Testing\\2022_ARUInventory_UMBEL_FWPR7.csv")
