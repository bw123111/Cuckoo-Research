############## Power Analysis #################

# This is a script to determine how many sites we need to find a significant effect of habitat on occupancy
# Code drawn from Research Design Project
# Last updated: 2/27/23
# Maybe redo this after you have a better idea of how you'll be stratifying habitat variables

# Specific questions:
## Given the total number of ARUs available minus the number needed to monitor the sites that will remain consistent from year to year (UMBEL long term sites with a number as an ID, sites that Brandi mentioned): how many additional sites could we monitor? Do we have enough ARUs to pair them at a site in case of mechanical failure?

# Thoughts/Questions for Paul
## Need to go through and revisit the parameters I'm using in the power analyses 
## nreps = 6? I remember Paul said that this won't help your CV estimation, it will just tighten the points around the current trend 

## Should I be using a simple logistic regression, or would it be better to simulate occupancy data and plug that into an occupancy analysis package?

## It looks like with the single ARUs in stratified habitat, even getting 15 more ARUs would help to get the coeficient of variation more consistently around 0.5


###### Libraries #######

library(tidyverse)
library(data.table)
library(janitor)

##### External Packages #######

# Load in the function to simulate data
source(".\\R_Scripts\\SimulateOcc_By_HabQuality.R")
# Load in the function to simulate data with stratified habitat quality
source(".\\R_Scripts\\SimulateOcc_By_StratifiedHabQual.R")
# Load in the function to plot the simulated data
source(".\\R_Scripts\\Plot_SimulateOcc_By_Hab.R")

# Which function to use: the regular simulated data or the data weighted towards high quality and low quality habitat?
## ideally, I'll be shooting for the high quality and low quality habitat only, but I'll also be using the regular simulation
## this will work to see the effects of the habitat variables that I expect to vary linearly with probability of occupancy. Are there any that I expect to vary in a non-linear way?
## Subcanopy vegetation structure:
### I expect probability of occupancy to increase linearly as the subcanopy density increases
## canopy cover
### I expect the probability of occupancy to decrease as canopy cover increases but they also won't be present in areas with zero/very low canopy cover - quadratic relationship?
## habitat patch size 
### no relationship 
## Species presence - forest composition
### Not sure about the relationship


###### Data ##########

# Load in the list of points that we will be doing repeat monitoring on 
repeat_locs <- fread(".\\Data\\Spatial_Data\\Repeat_Monitoring_Points_2023.csv")
# Get a number for this data - these are the ARUs that we aren't able to use for randomized habitat survey points
num_repeat_locs <- nrow(repeat_locs)

# ARUs available for 2023

# UMBEL_aru_dt <- fread(".\\Data\\ARU_info-Copy\\2022MMR_ARU_Status_All-COPY.csv", header=TRUE)
# # Rename the column
# colnames(UMBEL_aru_dt)[7] <- "status_2022"
# # remove "broken", Lost, and Assess for damage
# UMBEL_test <- UMBEL_aru[, "status_2022" %in% c( "retrieved","not deployed","needs configured")]

# UMBEL ARUs
UMBEL_aru_df <- read_csv(".\\Data\\ARU_info-Copy\\2022MMR_ARU_Status_All-COPY.csv")
UMBEL_aru_df <- UMBEL_aru_df %>% clean_names()
# remove the ARUs that are broken, lost, or need to be assessed for damage
UMBEL_aru_df <- UMBEL_aru_df %>% filter(x2022_field_status %in% c("retrieved","not deployed","needs configured"))
num_UMBEL <- nrow(UMBEL_aru_df)

# FWPR7 ARUs
FWPR7_aru <- read_csv(".\\Data\\ARU_info-Copy\\InventoryARUsRegion7-COPY.csv")
FWPR7_aru <- FWPR7_aru %>% clean_names()
# remove units with any corrosion or questionable status
FWPR7_aru <- FWPR7_aru %>% filter(unit_condition =="Good")
num_FWPR7 <- nrow(FWPR7_aru)

# This is a minimum estimate of the ARUs available for FWP Region 6 - Nikie is interested in buying more
num_FWPR6 <- nrow(repeat_locs %>% filter(organization=="FWPR6"))

# Again a minimum estimate of the ARUs available to FWP Region 5 based on email correspondance
num_FWPR5 <- 24

# Sum up the total number of ARUs available
total_arus <- num_FWPR5 + num_FWPR6 + num_FWPR7 + num_UMBEL

# Remove the number of ARUs that are needed for the repeat monitoring points 
hab_arus <- total_arus - nrow(repeat_locs)


####### Establish Parameters ###########

# Simulate data: unstratified - unideal but realistic data from sampling 
qHabitat <- c(1:10)
occProb_lEffect <- round(seq(.096,.32, length.out=10),3)
possibleVals_lE <- cbind(qHabitat,occProb_lEffect)

occProb_FullEffect <- round(seq(0,.32, length.out=10),3)
possibleVals_FullE <- cbind(qHabitat,occProb_FullEffect)

# Add on a potential purchase of up to 50 ARUs
hab_arus_wpurchase <- hab_arus+50




########## Power analysis using unstratified habitat  ######################

# Power Analysis 1: ARUs doubled up

# Specify the range of sample sizes that were looking at 
## Range from the current available ARUs paired up to additional ARUs paired up 
samps <- c(round(hab_arus/2, digits = 0):round(hab_arus_wpurchase/2, digits=0))
max(samps)

# is nreps the right thing to put there? what about the sub periods within each survey?  ?????????????????????????
# With a 70% change in occupancy
#doubled_up <- simulate_data(sample_sizes=samps,nreps=6,possible_vals=possibleVals_lE)
# With a 100% change in occupancy
doubled_up <- simulate_data(sample_sizes=samps,nreps=6,possible_vals=possibleVals_FullE)

doubled_up_plot <- plot_occ_pwr_analysis(data=doubled_up,plot_title="Power Analysis of Paired ARUs")
doubled_up_plot
## no clearly evident trend - changed nreps to 6

# Power Analysis 2: ARUs not doubled up

# Specify the range of sample sizes
# Range from only the ARUs we currently have to the number of ARUs with additional purchases

samps2 <- c(hab_arus:hab_arus_wpurchase)
# if we test this with data going up to 1000, we see that the coefficient of variation isn't where we want it at .2 until about 500 points
#samps3 <- c(hab_arus:1000)

# With a 70% change in occupancy
#singles <- simulate_data(sample_sizes=samps2,nreps=6,possible_vals=possibleVals_lE)
# With a 100% change in occupancy
singles <- simulate_data(sample_sizes=samps2,nreps=6,possible_vals=possibleVals_FullE)

singles_plot <- plot_occ_pwr_analysis(data=singles,plot_title="Power Analysis of Single ARUs")
singles_plot
# with nreps = 2 no clearly evident trend - changed nreps to 6
# with 100% change in occupancy, looks like around 120-130 the CV starts getting to .3 ish 




########### Power analysis using stratified habitat values ################

# Power Analysis 1: ARUs doubled up

# 70% change in occupancy
#doubled_up_strat <- simulate_data_stratified(sample_sizes=samps,nreps=6,possible_vals=possibleVals_lE)
# OR 
# 100% change in occupancy
doubled_up_strat <- simulate_data_stratified(sample_sizes=samps,nreps=6,possible_vals=possibleVals_FullE)

doubled_up_strat_plot <- plot_occ_pwr_analysis(data=doubled_up_strat,plot_title="Power Analysis of Paired ARUs Stratified Habitat")
doubled_up_strat_plot



# Power Analysis 2: ARUs not doubled up

# 70% change in occupancy
#singles_strat <- simulate_data_stratified(sample_sizes=samps2,nreps=6,possible_vals=possibleVals_lE)
# OR
# 100% change in occupancy
singles_strat <- simulate_data_stratified(sample_sizes=samps2,nreps=6,possible_vals=possibleVals_FullE)

singles_strat_plot <- plot_occ_pwr_analysis(data=singles_strat,plot_title="Power Analysis of Single ARUs Stratified Habitat")
singles_strat_plot
# with 100% occupancy, anything from 110-120 would work 


# Look at the asymptote
samps3 <- c(hab_arus:1000)
singles_strat3 <- simulate_data_stratified(sample_sizes=samps3,nreps=6,possible_vals=possibleVals_lE)
singles_strat3_plot <- plot_occ_pwr_analysis(data=singles_strat3,plot_title="Power Analysis of Single ARUs Stratified Habitat")
singles_strat3_plot
# for this one, the CV flattens out around 375 ARUs
