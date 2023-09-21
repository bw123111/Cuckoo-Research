####### Modify Playback Data After Editing ########


# This is a script to read in a selection table and change all columns by the amount the playback data was edited to create a new selection table
# Created 9/19/2023

# Last edited 9/19/2023

#### Setup ####
library(tidyverse)
library(janitor)


#### Code #####

# read in the selection table you are trying to edit
s_table <- read.csv("./Data/Training_Data/Raw_Data/CUL-1PB_20230713_071338-NoPB.Table.1.selections.csv") %>% clean_names()

amount_clipped <- 32.35 # specify the amount of data that was removed

# WBB: 150.6 seconds
# ROB-3: 40.69 seconds
# CUL-3: 35.97
# CUL-1PB_20230712: 1157.12
# CUL-1PB_20230713: 32.35

# go through and subtract this amount from begin time and end time
s_table_new <- s_table %>% mutate(begin_time_s = begin_time_s - amount_clipped)

s_table_new <- s_table_new %>% mutate(end_time_s = end_time_s - amount_clipped)


# write the updated selection table to csv
write.table(s_table_new,"./Data/Training_Data/Outputs/CUL-1PB_20230713_071338-NoPBNoTromping.Table.1.selections.txt", sep = "\t", quote = FALSE, row.names = FALSE)
# write.csv(s_table,"./Data/Training_Data/Outputs/WBB-1PB_20230620_102700_selections.csv", row.names = FALSE)
# #   