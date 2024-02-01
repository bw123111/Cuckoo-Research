####### Check Scores Outputs ########

# A script to read in the scores output from the clip extraction 

# Created 1/23/2023
# last modified 1/23/2023

#### Setup ####
packages <- c("tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


#### Code #####
fwpr6_scores <- read.csv('F:/Cuckoo_Acoustic_Data/2023/2023_FWPR6_Data/2023_FWPR6_Clips/2023_FWPR6_topclip_perperiod/2023_FWPR6_topclips_perSiteperPeriod.csv')
# 7378 clips = 36,890 seconds = 10 hours
test1 <- fwpr6_scores %>% filter(!(score < -1))
# filtering out those with a score less than -1, there are 4302 (.58 of the original data) for Region 6
# Does this vary from Region 5, where we had our lowest levels of cuckoo activity?
test2 <- fwpr6_scores %>% filter(!(score < -3))
# filtering out those with a score less than -3, there are 5686 (.77 of the original data) for Region 6

fwpr5_scores <- read.csv('F:/Cuckoo_Acoustic_Data/2023/2023_FWPR5_Data/2023_FWPR5_Clips/2023_FWPR5_topclip_perperiod/2023_FWPR5_topclips_perSiteperPeriod.csv') # 5990

test3 <- fwpr5_scores %>% filter(!(score < 0))
# filtering out those with a score less than -3, there are 4807 (.80 of the original data) for Region 6
# Filtering out those with score less than 0, we would be going through 2907 out of 5412 clips (.53 of data)