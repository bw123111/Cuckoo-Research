############## Figuring Out Musselshell Sites #############
# This is a script for looking at landowner access in the Musselshell river

# Created: 4/24/2023
# Last updated: 4/28/2023


######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############


# pull in region 5 points
mush_base <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_BaseGRTSandRepeats.csv")

landowners_base <- mush_base %>% group_by(landowner) %>% summarize(num=n())

mush_over <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_OverSampleGRTS.csv")

landowners_over <- mush_over %>% group_by(notes) %>% summarize(num=n())
write.csv(landowners_base,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_BaseLandowners.csv")
write.csv(landowners_over,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell River\\2023_R5_OverLandowners.csv")
# group_by landownder and summarize n()