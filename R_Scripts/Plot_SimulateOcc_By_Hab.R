################# Visualizing Output of Simulating Data for Power Analysis ###########

# This is a script to take the output of the Simulate Occupancy Scripts and Visualize it

# Input values:
## data : this is the returned value from the SimulateOcc_By_HabQuality or the SimulateOcc_By_StratifiedHabQual scriptss
## title : this is a string of what you want the graph to be named


##### Libraries ######
library(ggplot2)




##### Code: last updated 2/26 #######


plot_occ_pwr_analysis <- function(data, plot_title) {
  total_sim_dat <- as.data.frame(data)
  
  plot <- ggplot(total_sim_dat) +
    aes(x = Sample_Size, y = CV) + geom_point(shape = "circle", size = 1.5, colour = "gray69") + geom_smooth(se = FALSE, size=1.5, color="cornflowerblue") +
    labs(x = "Sample Size", y = "Coefficient of Variation of Logistic Regression", title=plot_title) +
    theme_minimal() + scale_y_continuous(limits=c(0,5), breaks=seq(0,5,by=.5)) + geom_hline(yintercept = .2, color = "brown1")
  
  return(plot)
  
}