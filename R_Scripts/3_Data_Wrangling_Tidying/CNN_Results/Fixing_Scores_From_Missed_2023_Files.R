##### Clearing up the Mess of Scores Stuff #####
# Smh
# Purpose: to join together the final scores files after running the later part of the Region 6 2023 data 

# Create 2/2/2024
# Last updated 2/2/2024

#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)


##### Data #####
# Read in the datasets from each of the runs
# First run: full data without MISO-032
cnnv2r6_1 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/Archive/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
# Second run: early MISO-032 and MISO-204
cnnv2r6_2 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores_New/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
# Third run: later MISO-032 that was missed the first time
cnnv2r6_3 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores_New2/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")




# Combine these together to write to output for clip extraction
cnnR6_all <- rbind(cnnv2r6_1, cnnv2r6_2, cnnv2r6_3)
#write.csv(cnnR6_all,"F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")




### Checking through issue #####
# Look through region 6 to find the problem
cnnr6 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
#cnnr6 %>% separate(file, by = "_")
cnnr6[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
# Look at just MISO-032
miso_032 <- cnnr6[point == "MISO-032"]
miso_204<- cnnr6[point == "MISO-204"]
miso_204[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]
unique(miso_204$date)
# Split out the dates
miso_032[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]
unique(miso_032$date) # This only goes up to 14   
# Check the backup scores 
r6_orig1 <- fread("C:/Users/ak201255/Documents/Backups/RedoingCNNWithAdditionalData_1-31/Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio_firstrun.csv")
r6_orig2 <- fread("C:/Users/ak201255/Documents/Backups/RedoingCNNWithAdditionalData_1-31/Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio_later.csv")
r6_orig1[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
unique(r6_orig1$point)
r6_orig1_point <- r6_orig1[point == "MISO-032"]
r6_orig[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]

# Looking at the archived scores file
r6_backup <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/Archive/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
r6_backup[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
unique(r6_orig$point)

r6_current <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
r6_current[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
unique(r6_current$point)
r6_current_point <- r6_current[point == "MISO-032"]
r6_current_point[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]
unique(r6_current_point$date)

# Do the same with UMBEL
#cnnv2_UMBEL_new <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores_New/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio_New.csv")
#cnnUMBEL_all <- rbind(cnnv2_UMBEL_new,cnnv2_UMBEL)
#write.csv(cnnUMBEL_all,"F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio.csv")
# Checking the UMBEL files 
cnnUMBEL <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio.csv")
cnnUMBEL[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
unique(cnnUMBEL$point)
cnnUMBEL[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]
date_check <- cnnUMBEL[point == "MISO-197"]
unique(date_check$date)
