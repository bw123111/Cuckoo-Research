############ Power Analysis for Playback Sites ################

# this is a script to examine how many playback sites we should shoot for given the cuckoo occupancy in previous years

# Created 6/15/2023

######### Install and load pacakges #########
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

########### Code ##############

# this is less of a power analysis and more of an analysis to make sure that we have a good shot of getting enough detections to be able to see an effect or run some analyses on this

# simulate sampling at different sites 
# draw from occupancy estimated from Mark's class project (only use BBCU) to simulate visits to each site 