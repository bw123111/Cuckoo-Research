######### Random Number Generation for Veg Plot #################

# This is a script for generating random numbers for the vegetation survey plots

# Created: 6/8/2023
# Last updated: 6/8/2023


######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############

# Generate random numbers 

# nums <- runif(500,min = 0, max = 359)
# draws decimels - not what we want

nums <- sample(0:359,500, replace = T)


# make these into a column of a dataframe with the name bearing


# export this to CSV
rands <- as.data.frame(nums)
rands <- rands %>% rename(bearing = nums)

write.csv(rands, "C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Resources\\Field Work\\3_Veg Survey\\Veg_Survey_Bearings.csv")
