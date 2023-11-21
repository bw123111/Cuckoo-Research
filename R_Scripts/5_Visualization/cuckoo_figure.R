
#fake data
Site <- c(seq(1, 40, 1), seq(1, 40, 1))
Det <- round(runif(80, 0, 1))
Method <-  c(rep("ARU", 40), rep("Point Count", 40))

dat <- data.frame(Site, Det, Method)
dat$Site <- as.factor(dat$Site)
str(dat)

#figure
  ggplot(dat, aes(x = Site, y = Det, fill = Method)) +
  geom_dotplot(dotsize = 0.25, binaxis = "y", stackdir = "center", position = position_dodge(width = 1)) +
  labs(x = "Site", y = "Detection")	+
    scale_y_continuous(limits = c(0, 1), breaks = c(0, 1)) +
    theme_bw()
