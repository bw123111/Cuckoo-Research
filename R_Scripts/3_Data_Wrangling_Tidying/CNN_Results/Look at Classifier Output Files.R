### Look at Classifier Output Files ###################

## Purpose: to look at output files from the classifier 

# Created 10/19/2023

# Last modified: 1/16/2024

#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)



##### Input Which Site and Working Directory ####################
##### 2020 Model 1.0 #####
# load in the 2020 classifier scores
cnn_20 <- fread("./Data/Classifier_Results/2020_BBCU_Classifier_Results_annotations_standardmodel.csv")
# get the min and the max of the scores 
min(cnn_20$score) # -4
max(cnn_20$score) # 14.6
hist(cnn_20$score)
mean(cnn_20$score) # average score is -3.5

# pull out the files that are annotated that have a positive annotation
checked20 <- cnn20[annotation == 1 | annotation == 0]
hist(checked20$score)
# looks like they checked a wide distribution of scores, not just the top
pos20 <- cnn20[annotation == 1]
min(pos20$score) #-3.7
max(pos20$score) #14.6
hist(pos20$score) # looks like this was a wide distribution of scores, not just the top scoring 
count_20pos <- cnn20[annotation == 1, .N]
print(count_20pos) #881 annotations that were positive
count_20neg <- cnn20[annotation == 0, .N] # 120 annotations that were negative
# total of 1001 annotations looked at (I'm assuming these were the highest scoring files)
count_20noann <- cnn20[is.na(annotation) == TRUE, .N]
nrow(cnn20)- count_20noann # total of 1001 files annotated

##### 2021 Model 1.0 #####
# Look at the 2021 classifier files
cnnv1_R6 <- fread("./Data/Classifier_Results/2022_FWPR6_top10scoring_clips_persite_annotations.csv")

#### 2023 Model 2.0 ####
# Look at CNN Model 2.0
cnnv2_R623 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
# Remove the first column
cnnv2_R723 <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR7_Audio.csv")
cnnv2_UMBEL <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio.csv")


#### ARCHIVE : Moved to fixing scores from missed 2023 files######
# Combine new scores file
cnnv2_R623_new <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores_New/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
# Combine these together to write to output for clip extraction
cnnR6_all <- rbind(cnnv2_R623_new, cnnv2_R623)
#write.csv(cnnR6_all,"F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio.csv")
tail(cnnR6_all) # This looks good
# Do the same with UMBEL
cnnv2_UMBEL_new <- fread("F:/CNN_Classifier_Files/Model_2.0/Model_Scores_New/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio_New.csv")
cnnUMBEL_all <- rbind(cnnv2_UMBEL_new,cnnv2_UMBEL)
#write.csv(cnnUMBEL_all,"F:/CNN_Classifier_Files/Model_2.0/Model_Scores/predictions_epoch-10_opso-0-10-1-2023_UMBEL_Audio.csv")

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
r6_orig <- fread("C:/Users/ak201255/Documents/Backups/RedoingCNNWithAdditionalData_1-31/Scores/predictions_epoch-10_opso-0-10-1-2023_FWPR6_Audio_later.csv")
r6_orig[,c("path","point","file_id") := tstrsplit(file,'\\',fixed = TRUE)]
unique(r6_orig$point)
r6_orig <- r6_orig[point == "MISO-032"]
r6_orig[,c("point_id","date","time_ext") := tstrsplit(file_id,'_',fixed = TRUE)]
