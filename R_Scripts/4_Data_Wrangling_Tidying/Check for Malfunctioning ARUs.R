############# Check for Malfunctioning ARUs #########

# this is a script to read in the deployment and retrieval data from 2023 and clean the data so it can be used

# Created 9/5/2023

# Last updated 9/26/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)

##### CODE #######

ret_dat <- read.csv("./Data/Metadata/Outputs/2023_ARURetrieval_Metadata_Cleaned9-28.csv")

# Filter ARU ID containing SMM
songmeter <- ret_dat %>% filter(grepl("SMM", aru_id))
