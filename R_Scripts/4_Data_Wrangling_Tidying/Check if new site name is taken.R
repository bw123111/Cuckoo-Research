############ Check names script ################

# this is a script to read in all the names of the current points and check if the new name I'm generating is already taken

# Created 6/15/2023

######### Install and load pacakges #########
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

########### Code ##############

# read in the UMBEL playback sites
umbel <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Monitoring_Points\\2023_Playback_Survey_Points_UMBEL.csv")


# read in the FWP playback sites
fwp <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Monitoring_Points\\2023_PlaybackPoints_FWP.csv")


# split apart point ID into the site and the point
umbel_sites <- umbel %>% separate(point_id, into = c("site","num"), sep="-") %>% select(site)
sites1 <- unique(umbel_sites)

fwp_sites <- fwp %>% separate(point_id, into = c("site","num"), sep="-") %>% select(site)
sites2 <- unique(fwp_sites)

# combine all of the site names
all_sites <- rbind(sites1,sites2)


check_new_name <- function(name){
  if(name %in% all_sites$site){
    warning ("Name already in use")
  } else {
    print("Name available")
  }
}

check_new_name("FWP")
check_new_name("PRD")

# check the name you want to add: 
check_new_name("LGC")
check_new_name("BSB")
