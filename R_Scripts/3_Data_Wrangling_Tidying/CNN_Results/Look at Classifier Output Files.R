### Look at Classifier Output Files ###################

## Purpose: to look at output files from the classifier 

# Created 10/19/2023

# Last modified: 10/19/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)



##### Input Which Site and Working Directory ####################

# load in the 2020 classifier scores
cnn20 <- fread("./Data/Classifier_Results/2020_BBCU_Classifier_Results_annotations_standardmodel.csv")
# get the min and the max of the scores 
min(cnn20$score) # -4
max(cnn20$score) # 14.6
hist(cnn20$score)
mean(cnn20$score) # average score is -3.5

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
