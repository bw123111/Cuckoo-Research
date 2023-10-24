########################## Creating ARU Retrieval Data ###################


###############Header########################

# Created 8/12/2022
## Purpose: to take in files that have deployment metadata and pull out Missouri River sites


# Libraries used
library(tidyverse)
library(dplyr)
library(janitor)
library(naniar)


##################### Code #############################

# read in the 2023 ARU Deployment Data
deploy <- read_csv(".\\Data\\Metadata\\2023_ARUDeployment_Metadata_6-8.csv")

# Filter out only the entries that are between the coordinates of the missouri river
# 108.0743650°W 47.6626152°N - easternmost extent of the UMBEL deployments
# 108.7668825°W 47.4279918°N - southernmost edge of the UMBEL deployments

# only values that are less than -108.0743650
# only values that are greater than 47.4279918

test <- deploy %>% filter(x < -108.0743650 & y > 47.4279918)

test <- deploy %>% filter(x < -108.0743650)
up_miso <- test %>% filter(y > 47.4279918)


write.csv(up_miso,".\\Data\\Monitoring_Points\\2023_UpperMisoRetrievalPoints_FieldOnly.csv",row.names=FALSE)

