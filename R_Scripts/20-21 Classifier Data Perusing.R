##################### Header ######################

# This is a script for reading in classifier data and checking to see if you have everything (all collaborator's data) before top-down listening


# Status:


#################### Setup #########################


library(tidyverse)
library(data.table)


################### Body #########################

# Read in the classifier data as data table
classifier_20 <- fread("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Classifier Results\\2020_BBCU_Classifier_Results_annotations_standardmodel.csv")
classifier_21 <- fread("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Classifier Results\\2021_BBCU_Classifier_Results.csv")

# read in the metadata as data table
metdat_20 <- fread("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2020_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL_FWP.csv")


# Looking at data
# Split the file column into two columns, one for ID and one for timedate
classifier_20[,c("Moth_ID","timedate") :=tstrsplit(tag,"/",fixed=TRUE)]

classifier_21[,c("Moth_ID","timedate") :=tstrsplit(tag,"/",fixed=TRUE)]



# Checking if the data from the classifier output on UMBEL 2022 ran correctly
scores_82_1 <- fread("E:\\2022_UMBEL_Scores\\2022-10-20_82-1_scores.csv")
scores_82_3 <- fread("E:\\2022_UMBEL_Scores\\2022-10-20_82-3_scores.csv")

unique(scores_82_1$file)
