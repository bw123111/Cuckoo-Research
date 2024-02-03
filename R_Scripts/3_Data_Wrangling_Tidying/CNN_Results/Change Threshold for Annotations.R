##### Change Threshold for Annotations #####
# The purpose of this script is to read in the annotations for FWPR5 from when we were annotating them with a threshold of -3 and go through and change any clip with a value between -3 and 0 to auto annotated 

# Created 2/3/2024
# Last updated 2/3/2024

#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
# Load packages
load_packages(packages)


##### Data #####
# Read in the original annotations file
r5_vet <- read.csv("F:/Cuckoo_Acoustic_Data/2023/2023_FWPR5_Data/2023_FWPR5_Clips/2023_FWPR5_topclip_perperiod/2023_FWPR5_topclips_perSiteperPeriod_annotations_orig.csv")
#r5_vet %>% mutate(case_when(annotation != "not_reviewed",))
# I have a datasheet r5_vet that has these columns: annotation (a string), score (a number), auto_negative (a string) and flag (a string). The values in annotation are not_reviewed, 0, and 1. I want to change only the rows of annotation whose values is not not_reviewed. Out of these rows, I want to change annotation to "0", auto_negative to "Y", and flag to "N" if the value in the score column is between -3 and 0. How do I do this in R?
r5_vet_new <- r5_vet %>%
  mutate(
    annotation = ifelse(annotation != "not_reviewed" & score >= -3 & score <= 0, "0", annotation),
    incorrect_call = ifelse(annotation != "not_reviewed" & score >= -3 & score <= 0, "notapp", incorrect_call),
    flag = ifelse(annotation != "not_reviewed" & score >= -3 & score <= 0, "N", flag),
    auto_negative = ifelse(annotation != "not_reviewed" & score >= -3 & score <= 0, "Y", auto_negative)
  )
# Checked the data, there was none that were u or 1 that had a score between -3 and 0, the lowest was .1 or .2

# Write the new data
write.csv(r5_vet_new,"F:/Cuckoo_Acoustic_Data/2023/2023_FWPR5_Data/2023_FWPR5_Clips/2023_FWPR5_topclip_perperiod/2023_FWPR5_topclips_perSiteperPeriod_annotations.csv",row.names = FALSE)
