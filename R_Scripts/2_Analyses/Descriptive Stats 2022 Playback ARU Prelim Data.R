####### Descriptive Statistics 2022 Playback ARU Prelim Data ########

# A script to read in a cleanfor used file for playback data and conduct preliminary analysis and visualization

# Created 1/31/2023

# Last updated 1/31/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor","lubridate")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


#### Data ######
# read in data
# Site level data for cuckoos accross all regions
pb_sitedat <-read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SiteLevelCuckoo_11-29.csv") 
sum(pb_sitedat$detection_hist_bbcu) # 4 sites that found cuckoo in playbacks
pb_pres <-pb_sitedat[pb_sitedat$detection_hist_bbcu ==1,]


# Read in site level cuckoo for ARU
aru_sitedat <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_ARUSurveys_SiteLevelBBCU10-11.csv")
sum(aru_sitedat$bbcu)
aru_sitedat <- aru_sitedat %>% rename(site_id = site)
# sites that are just in the ARU site dat
arus_only <- aru_sitedat %>% anti_join(pb_sitedat, by = "site_id")
# restrict the ARU data to just the area that also had playbacks
aru_sitedat <- aru_sitedat %>% filter(site_id %in% pb_sitedat$site_id)
# 8 site with bbcu
# index the 
aru_pres <- aru_sitedat[aru_sitedat$bbcu == 1,]

# naive occupancy
nrow(aru_pres)/nrow(aru_sitedat) # = 0.175 (17.5% site occupancy)
nrow(pb_pres)/nrow(pb_sitedat) # = 0.1 (10% site occupancy)



# the same: CUL, JUD
# ARU only: 
# Figure out which ones aren't included 
unique_to_aru <- aru_pres %>% anti_join(pb_pres, by = "site_id")
# 6 sites unique to aru detection
unique_to_pb <- pb_pres %>% anti_join(aru_pres, by = "site_id")
# 2 sites unique to pb detection