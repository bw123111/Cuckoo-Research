##### UBMS Bayesian Occupancy Examples ####

# Source: https://cran.r-project.org/web/packages/ubms/vignettes/ubms.html
# GitHub for ubms: https://github.com/kenkellner/ubms

# Only kind of related: ubms models with Stan: https://github.com/kenkellner/ubms
# Overview of ubms https://cran.r-project.org/web/packages/ubms/vignettes/ubms.html

#### Setting Up ####

#install.packages("ubms")
library(ubms)
library(unmarked)


#### Getting Started ####

# Info on ubms
# Identical interface to unmarked
# Other Bayesian software includes BUGS and JAGS, which involve writing custom code 
# Unmarked has more models available than ubms and will run faster

# Recommendation is to test the models in unmarked first 
# Used when a Bayesian framework is needed and "off the shelf" models are adequate for the question 


#### Example ####


#### Set up Data ####

# Load in data
data("crossbill")
dim(crossbill)
names(crossbill)
str(crossbill)

# Establish site covariates
site_covs <- crossbill[,c("id", "ele", "forest")]

# Establish detection data
## For this we are doing a single season model, so we are only using the first three columns, which represent three surveys in year one

y <- crossbill[,c("det991", "det992", "det993")]
head(y)
# missing values are ok

# now pull out the dates for each survey
date <- crossbill[,c("date991", "date992", "date993")]


# Build an unmarked frame with detection/nondetection data, site covariates, and observation covariates 
## Use unmarkedFrameOccu for a single-season occupancy analysis
umf <- unmarkedFrameOccu(y = y,
                         siteCovs = site_covs,
                         obsCovs = list(date = date))
head(umf)


#### Fit the model in unmarked ####

# Null model: no covariates 
(fit_unm <- occu(~1 ~1, data = umf))
# how do you interpret the output of this model? 

#### Fit the model in ubms ####

# Equivalent to occu is stan_occu
## most functions in ubms will use the stan_ prefix

# Provide the same arguments to stan as the unmarked model
# Specify the number of MCMC chains and how many iterations per chain, how many of them are the burning period
## How to decide how many MCMC chains to use:https://mc-stan.org/docs/2_24/stan-users-guide/index.html
## General recommendations are 4 chains of 2000 iterations, 1000 of which are burn in 
## Stan needs a smaller number of iterations to converge

# Fit the model
(fit_stan <- stan_occu(~1~1, data=umf, chains=3, iter=500, cores=3, seed=123))
# Fit a naive model on the umf data with three chains iterating 500 times each (half will be warmup/burnin), seed to establish the same random starting point so we can replicate the results 

# Interpreting these results
## Call: the command used to get the model output 
## Occupancy is the occupancy sub model
## For each sub model, there is one row per parameter in the model 
### This model had no covariates, so there is only an intercept term 
### Model parameters are always shown in the appropriate transformed scale, logit in thise case
### To get probabilities, you use the predict function 
## Also provides the 95% credible/uncertainty interval 
### n_eff and Rhat are MCMC diagnostics 


#### Comparing Outputs ####

# Put the output from unmarked and from ubms into one table
cbind(unmarked=coef(fit_unm), stan=coef(fit_stan))
# the structure of the output is similar as are the estimates of occupancy and detection 

# Extract individual parameters into a table using the summary method, specifying which submodel you want
sum_tab <- summary(fit_stan, "state")
sum_tab$mean[1] # this will give us the occupancy estimate

#### Left off section 2.2.5 in tutorial ####


#### Notes from meeting ####

# Grid cells corresponds to the "pixel" that you're sampling at
# have to average values accross it 

# Don't interpret the model unlesd
# Brooks gillman ruben statistic (R hat) less than 1.1
# MCMC chains have to converge (look at trace plots)
# want to look at if the chains start at different places, come to the same place, and then make a "grassy" plot
# important to say initial values that should be in distribution 
# trace plots also give you insight into burnin period 
# if these two factors are met, your output of your model might be easier to interpret (will have a normal looking distribution)


# some models can have NAs, others can't