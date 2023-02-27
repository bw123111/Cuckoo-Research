############### Script for Simulating Occupancy Data ##########

# This is a code to simulate occupancy data that varies with habitat quality
## This script creates a function to simulate the specified number of reps at each survey size 
## for each survey size, this function puts the data into a logistic regression of occupancy by habitat quality and pulls out the coefficient of variation 
## it then puts the coefficient of variation for each sample size into a dataframe that is returned 


# The inputs for this function are:

## sample_sizes : a list of each sample size that you want to test
## Example format: list_sample_sizes <- c(20:max_sampSize

## nreps : how many sub periods/repeat surveys you'll be doing
## Example format: nreps <- 6 (this would be six sub sampling periods)

## possible_vals : this is a matrix of the ranges of the habitat quality variables and the probability of occupancy at each of those habitat qualities
## Example format : 
## #1. Create a vector for habitat quality measure - a measure from good habitat quality (10) to low quality (1)
## qHabitat <- c(1:10)
## #2. Simulate occupancy probability for the different levels of habitat quality
## #large effect size .30 (70% decrease in occupancy probability from good habitat to bad habitat)
##.32*.30
## occProb_lEffect <- round(seq(.096,.32, length.out=10),3)
## #3. Bind together habitat quality and occupancy probability to relate them
## possibleVals_lE <- cbind(qHabitat,occProb_lEffect)



################## Code: Last updated 2/26 ##############

simulate_data <- function(sample_sizes,nreps,possible_vals){
  # Make a matrix to store the data from the loop
  total_sim_dat <- matrix(NA,length(sample_sizes),2)
  colnames(total_sim_dat) <- c("Sample_Size","CV")
  
  # Iterate through each sample size you are testing
  for (s in 1:length(sample_sizes)){
    
    # Create an empty matrix to store the data from this mock survey with the given sample size
    diff_samp_size_dat <- matrix(NA,sample_sizes[s],2)
    # change the column names to habitat quality 
    colnames(diff_samp_size_dat) <- c("Habitat_Quality","Pres_Abs")
    
    cv_vals <- c()
    
    for (q in 1:nreps){
      
      #Iterate through each "observation" in this mock survey
      for (i in 1:sample_sizes[s]){
        # randomly select a row number, this correlates to the habitat quality and occupancy prob of mock point you're surveying
        row_num <- sample(1:10,1)
        # with the row number, grab the habitat quality at the mock point
        hab_qual <- possible_vals[row_num,1]
        # with the row number, grab the occupancy value at the mock point
        occ_value <- possible_vals[row_num,2]
        # simulate collecting data at this point with this habitat quality and occ prob
        sim_obs <- rbinom(1, 1, occ_value)
        
        # combine the simulated observations into the dataframe for this mock survey
        diff_samp_size_dat[i,"Pres_Abs"] <- sim_obs
        diff_samp_size_dat[i,"Habitat_Quality"] <- hab_qual
        
      }
      
      # Do a logistic regression using diff_samp_size_dat between habitat quality and presence absence for the simulated data 
      diff_samp_size_dat <- as.data.frame(diff_samp_size_dat)
      log_reg <- glm(Pres_Abs ~ Habitat_Quality, data= diff_samp_size_dat, family="binomial"(link = 'logit'))
      
      # pull out the standard error for that regression
      sterr <- coef(summary(log_reg))[2,2]
      # use coefficient of variation - standard error divided by the slope
      slope <- coef(summary(log_reg))[2,1]
      cv <- abs(sterr/slope)
      cv_vals <- append(cv_vals, cv)
      
    }
    
    cv_avg <- mean(cv_vals)
    
    # append sample size to the total simulated data
    total_sim_dat[s,"Sample_Size"] <- sample_sizes[s]
    # append SE from regression to the total simulated data
    total_sim_dat[s,"CV"] <- cv_avg
    
  }
  return(total_sim_dat)
}


