#### Combine Negative Training Data CSVs ###################

## Purpose: to read in all the separate files of test data and combine them into one datasheet for exporting into google sheets

# Created 10:23/2023

# Last modified: 10/23/2023

####### Setup ########
packages <- c("data.table","tidyverse","janitor")
# Read in the packages function
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
source("./R_Scripts/6_Function_Scripts/Combine_CSV_Files_In_Directory.R")

####### CODE ###############

combined_data <- combine_csv_files("./Data/Testing_Data/Outputs/Test_Data_All_Round1/")

combined_data <- combined_data %>% select(point_id,file_name,month,period)



write.csv(combined_data,"./Data/Testing_Data/Outputs/BBCU_Test_Data_Round1_10-23.csv", row.names = FALSE)

