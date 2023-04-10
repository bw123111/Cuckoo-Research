########### simulating predictions #############

set.seed(123)

# canopy cover: quadratic equation
# GPT try 2
x <- seq(0, 1, length.out = 100)

# simulate y values with inverse quadratic relationship
y <- 1 / (1 + (x - 0.5)^2 * 10)   # adjust 10 to change the curvature of the relationship

# add some random noise to y
y <- y + rnorm(length(y), mean = 0, sd = 0.05)

# scale y to range from 0 to 1
y <- (y - min(y)) / (max(y) - min(y))

df <- data.frame(x, y)

# create a scatterplot with ggplot2
ggplot(df, aes(x = x, y = y)) +
  geom_point(size = 2, color = "dark green") +
  labs(title = "Simulated Data",
       x = "% Canopy Cover", y = "Probability of Occupancy") +theme_bw()



# plot the simulated data
# plot(x, y, pch = 16, col = "dark green", main = "Simulated Data",
#      xlab = "% Canopy Cover", ylab = "Probability of Occupancy")


# subcanopy vegetation density: linear positive

# GPT try 2

library(ggplot2)
# x <- runif(100, min = 0, max = 1)
# 
# # simulate y values with a positive linear relationship with x between 0 and 1
# y <- 0.5 + 0.5 * x + rnorm(length(x), mean = 0, sd = 0.05)
# 
# # combine x and y into a data frame
# df <- data.frame(x, y)
# 
# # create a scatterplot with ggplot2
# ggplot(df, aes(x = x, y = y)) +
#   geom_point(size = 2, color = "dark green") +
#   labs(title = "Simulated Data",
#        x = "X", y = "Y") +
#   coord_cartesian(ylim = c(0, 1))+theme_bw()


x2 <- runif(100, min = 0, max = 1)

# simulate y values with a positive linear relationship with x between 0 and 1, with less noise
y2 <- 0.5 + 0.5 * x2 + rnorm(length(x2), mean = 0, sd = 0.05)

# combine x and y into a data frame
df <- data.frame(x2, y2)

# create a scatterplot with ggplot2
ggplot(df, aes(x = x2, y = y2)) +
  geom_point(size = 2, color = "dark green") +
  labs(title = "Simulated Data",
       x = "% Vertical Vegetation Cover", y = "Probability of Occupancy") +
  scale_y_continuous(limits = c(0, 1))+theme_bw()




# probability of presence and habitat patch size : uncorrelated

x3 <- runif(100, min = 10, max = 50000)
y3 <- rnorm(100, mean = 0.5, sd = 0.2)

# plot the data using ggplot2
ggplot(data.frame(x3, y3), aes(x = x3, y = y3)) +
  geom_point(size = 3, color = "dark green") +
  labs(title = "Simulated Data",
       x = "Patch Size (squre meters)", y = "Probability of Occupancy") +
  theme_bw()

# Try 2
# x3 <- runif(1000, 10, 10000)
# y3 <- runif(1000, 0, 1)
# 
# df3 <- data.frame(x3, y3)
# 
# 
# ggplot(df3, aes(x3, y3)) +
#   geom_point() +
#   scale_x_log10(limits = c(10, 10000)) +
#   scale_y_continuous(limits = c(0, 1)) +
#   labs(x = "X", y = "Y") +
#   theme_bw()







##### Code Graveyard ############

# sort by ascending for both
# prob_occ_cc <- round(rnorm(40, mean = .5, sd = .2),digits=2)
# prob_occ_cc <- sort(prob_occ_cc)
# hist(prob_occ_cc)
# canopy_cover <- round(runif(40,0,100),digits=2)
# canopy_cover <- sort(canopy_cover)
# hist(canopy_cover)
# cc_sim <- cbind(canopy_cover,prob_occ_cc)
# plot(canopy_cover,prob_occ_cc)
# 
# 
# # try again
# X <- rnorm(40, mean = .5, sd = .2)
# Y <- X^2 + runif(40, 0,1)
# plot(X,Y)
# 
# 
# X <- rnorm(100, 50, 10)            # simulate from the normal distribution
# Y <- -X^2 + runif(100, -0.1, 0.1) 
# plot(X,Y)
# 
# # make this fit my data
# X <- rnorm(100, 0, 1)            # simulate from the normal distribution
# Y <- -X^2 + runif(100, -0.1, 0.1) 
# plot(X,Y)


