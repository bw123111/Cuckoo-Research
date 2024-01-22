####### Comparing 2022 Playback and ARU Detection Data ########


# A script to read in playback data from 2022 and run descriptive statistics/ make a bar graph to compare them

# Created 10/18/2023

# Last updated 10/18/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor","esquisse", "ggplot2")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)

#### Code ################

# read in playback data
pb <- read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SiteLevelBBCU10-11.csv") %>% rename(bbcu_pb = bbcu)

aru <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_ARUSurveys_SiteLevelBBCU10-11.csv")

# keep the sites that are common in both datasets

# Identify sites that appear in both data frames
common_site_ids <- pb %>%
  semi_join(aru, by = "site")

# Identify sites unique to playback
unique_to_pb <- pb %>%
  anti_join(aru, by = "site")

# Identify sites unique to aru
unique_to_aru <- aru %>%
  anti_join(pb, by = "site")

aru_new <- aru %>% filter(!(site %in% unique_to_aru$site)) %>% rename(bbcu_aru = bbcu)
# test if we've done this right
test <- pb %>%
  semi_join(aru_new, by = "site") # looks good

# get stats for how many 
aru_pos <- aru_new %>% filter(bbcu == 1) # 7 sites
aru_neg <- aru_new %>% filter(bbcu == 0) # 33 sites
# naive occ: 21%
pb_pos <- pb %>% filter(bbcu == 1) #4 sites
pb_neg <- pb %>% filter(bbcu == 0) #36 sites
# naive occ: 11%

shared_pos <- inner_join(aru_pos,pb_pos, by = "site") # 2 sites, CUL and JUD

# make a table to compare the two 

# making a graph - trying chat gpt's way
combined_data <- full_join(aru_new, pb, by = "site")
count_data <- combined_data %>%
  mutate(bbcu = ifelse(is.na(bbcu_aru), bbcu_pb, bbcu_aru)) %>%
  group_by(bbcu) %>%
  summarise(count = n())

# make a confusion matrix esque table

table <- data.frame(
  ARU_Detections = c(2, 5),
  ARU_Nondetections = c(2, 31)
)
rownames(table) <- c("Playback_Detections","Playback_Nondetection")

# Create a bar graph
# Reshape the data to long format
table_df_long <- table %>%
  rownames_to_column(var = "Playback_Data") %>%
  pivot_longer(cols = -Playback_Data, names_to = "ARU_Data", values_to = "Value")


### Old poster plots #####
posterplot <- ggplot(table_df_long) +
  aes(x = Playback_Data, y = Value, fill = ARU_Data) +
  geom_bar(position="stack",stat="identity") + 
  scale_fill_manual(name = "ARU Data",
                    values = c(ARU_Detections = "#B75F4A", 
                               ARU_Nondetections = "#6A5424")) +
  labs(x = "Playback Data", y = "Detections") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        panel.grid.major = element_line(color = "darkgray"),  # Major grid lines color
        panel.grid.minor = element_line(color = "darkgray")) # Minor grid lines color)


ggsave("./Deliverables/posterplot.jpg", width=6, height=4)


y
# just playing around
ggplot(table_df_long) +
  aes(x = Playback_Data, y = Value, fill = ARU_Data) +
  geom_bar(position="dodge",stat="identity") + 
  scale_fill_manual(name = "ARU Data",
                    values = c(ARU_Detections = "#B75F4A", 
                               ARU_Nondetections = "#6A5424")) +
  labs(x = "Playback Data", y = "Detections") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        panel.grid.major = element_line(color = "darkgray"),  # Major grid lines color
        panel.grid.minor = element_line(color = "darkgray"))

#########



#### Dotplot figure ############
# Read in both the ARU and Playback Data
aru <- read.csv("./Data/Cuckoo_Presence_Absence_ARU/Model_1.0//2022_ARUSurveys_SiteLevelBBCU10-11.csv") %>% select(site, bbcu) %>% rename(PAM = bbcu)
pb <- read.csv("./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_SiteLevelBBCU10-11.csv")%>% select(site, bbcu) %>% rename(Playback = bbcu)
comb_dat <- left_join(pb,aru,by = "site")
# make this longer
ndat <- comb_dat %>% pivot_longer(cols = c("PAM","Playback"), names_to = "Method", values_to = "Detection")
ndat$site <- as.factor(ndat$site)


#figure
ggplot(ndat, aes(x = site, y = Detection, fill = Method)) +
  geom_dotplot( dotsize = 1, binaxis = "y", stackdir = "up", position = position_dodge(width = .5)) +
  labs(x = "Site", y = "Detection")	+
  scale_y_continuous(limits = c(0, 2), breaks = c(0, 1)) +
  scale_fill_manual(values = c("#B75F4A", "#6A5424")) +
  theme_minimal() +  
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        axis.text.x = element_text(angle = 90,hjust = 1))

ggsave("./Deliverables/posterdotplot4.jpg", width=15, height=4)


# change ARU to 1.1 and Playback to .9?
aru2 <- aru
#aru2$PAM <- str_replace(aru$PAM,"0", NA)
pb2 <- pb
pb2 <- pb2 %>% mutate(Playback = case_when(Playback == 0 ~0,
                                    Playback == 1 ~ 2))
#pb2$Playback <- str_replace(pb2$Playback, "1", "2")
comb_dat2 <- left_join(pb2,aru2,by = "site")
comb_dat2$Playback <- as.factor(comb_dat2$Playback)
comb_dat2$PAM <- as.factor(comb_dat2$PAM)
ndat2 <- comb_dat2 %>% pivot_longer(cols = c("PAM","Playback"), names_to = "Method", values_to = "Detection")
ndat2$site <- as.factor(ndat$site)
#ndat2$Detection <- as.factor(ndat$Detection)

#plot this
ggplot(ndat2, aes(x = site, y = Detection, fill = Method)) +
  geom_dotplot( dotsize = 1, binaxis = "y", stackdir = "up", position = position_dodge(width = .5)) +
  labs(x = "Site", y = "Detection")	+
  scale_y_continuous(limits = c(0, 2), breaks = c(0, 1)) +
  scale_fill_manual(values = c("#B75F4A", "#6A5424")) +
  theme_minimal() +  
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        axis.text.x = element_text(angle = 90,hjust = 1))

ggplot(comb_dat2, aes(x = site)) +
   geom_dotplot(aes(y = factor(PAM), fill = "PAM"), binaxis = "y", stackdir = "center", position = "dodge") +
     geom_dotplot(aes(y = factor(Playback), fill = "Playback"), binaxis = "y", stackdir = "center", position = "dodge") +
     labs(x = "Site", y = "Method") +
      scale_y_discrete(labels = c("No Detection", "PAM","Playback")) +
       scale_fill_manual(values = c("#B75F4A", "#6A5424")) +
       theme_minimal() +  
       theme(plot.background = element_rect(fill = "#F8F2E4"),
             axis.text.x = element_text(angle = 90,hjust = 1))

# Now combine the two 
ggplot(ndat2, aes(x = site, y = Detection, fill = Method)) +
  geom_dotplot(dotsize = 2, binaxis = "y", stackdir = "up", position = position_dodge(width = .5)) +
  labs(x = "Site")	+
  scale_y_discrete(labels = c("0", "PAM","Playback")) +
  scale_fill_manual(values = c("#B75F4A", "#6A5424")) +
  theme_minimal() +  
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        axis.text.x = element_text(angle = 90,hjust = 1))

ggsave("./Deliverables/posterdotplot6.jpg", width=15, height=3)





# Other plot method
plot2 <- ggplot(ndat, aes(x = site, y = Detection, fill = Method)) +
  geom_dotplot( dotsize = 1, binaxis = "y", stackdir = "up", stackgroups = TRUE, binpositions = "all") +
  labs(x = "Site", y = "Detection")	+
  scale_y_continuous(limits = c(0, 2), breaks = c(0, 1)) +
  scale_fill_manual(values = c("#B75F4A", "#6A5424")) +
  theme_minimal() +  
  theme(plot.background = element_rect(fill = "#F8F2E4"),
        axis.text.x = element_text(angle = 90,hjust = 1))


ggsave(plot1,"./Deliverables/posterdotplot3.jpg", width=15, height=4, device = "jpeg")



# From Nancy
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






# Code graveyard #####

# # replicate this with my data
# aru1 <- aru %>% mutate(Method = "ARU")
# pb1 <- aru %>% mutate(Method = "Playback")
# ndat <- rbind(aru1,pb1)

# install.packages("extrafont")
# library(extrafont)
# font_import(pattern = "Amasis MT Pro")
# 
# ggplot(count_data, aes(x = bbcu, y = count, fill = factor(bbcu))) +
#   geom_bar(stat = "identity") +
#   labs(x = "BBCU Value", y = "Site Count") +
#   scale_fill_manual(values = c("0" = "red", "1" = "green")) +
#   theme_minimal()
# 
# # Create a stacked bar graph
# ggplot(table_df_long, aes(x = Category, y = Value, fill = Variable)) +
#   geom_bar(stat = "identity") +
#   labs(title = "Detection by Methodology", x = "Category", y = "Value") +
#   scale_fill_manual(values = c("aru_pos" = "blue", "aru_neg" = "red")) +
#   theme_minimal() +
#   scale_y_continuous(breaks = seq(0, max(table_df_long$Value), by = 5))

# esquisser()
# 
# ggplot(table_df_long) +
#   aes(x = Category, y = Value, fill = Variable) +
#   geom_col() +
#   scale_fill_manual(values = c(ARU_Detections = "#B75F4A", 
#                                ARU_Nondetections = "#6A5424")) +
#   labs(x = "Playback Data", y = "Detections") +
#   theme_minimal()


# make a thirdcolumn
# make a separate factor column for a 1 if it is in bbcu aru, a 2 if it is in bbcu pb 
# do this in an else if function
# if(bbcu_aru = 1){
#   data$new_col <-  1
# } else if(bbcu_pb = 1){
#   data$new_col <- 2
# } else{
#   data$new_col <- 0
# }
# 
# comb_dat <- comb_dat %>% mutate(factor_det = if(bbcu_aru = 1,1))
# 
# ggplot(comb_dat, aes(x=site, y = c("bbcu_aru","bbcu_pb"))) +
#   geom_dotplot(aes)



# ggplot(aes(x = site))
# library(esquisse)
# esquisser()
# 
# 
# ggplot(comb_dat, aes(x = site)) +
#   geom_dotplot(aes(y = factor(bbcu_aru), fill = "bbcu_aru"), binaxis = "y", stackdir = "center", position = "dodge") +
#   geom_dotplot(aes(y = factor(bbcu_pb), fill = "bbcu_pb"), binaxis = "y", stackdir = "center", position = "dodge") +
#   labs(x = "Site") +
#   scale_x_discrete(name = "Site") +
#   scale_y_discrete(name = "Presence (1) or Absence (0)") +
#   scale_fill_manual(values = c("bbcu_aru" = "blue", "bbcu_pb" = "red")) +
#   guides(fill = guide_legend(title = "Variable")) +
#   theme_minimal()
# 
# panel.grid.major = element_line(color = "darkgray"),  # Major grid lines color
# panel.grid.minor = element_line(color = "darkgray"))
# 
# #figure
# ggplot(ndat, aes(x = site, y = Detection, fill = Method)) +
#   geom_dotplot(method = "histodot", dotsize = 1, binaxis = "y", stackdir = "up", position = position_dodge(width = .5)) +
#   labs(x = "Site", y = "Detection")	+
#   scale_y_continuous(limits = c(0, 1), breaks = c(0, 1)) +
#   theme_bw()
# 
