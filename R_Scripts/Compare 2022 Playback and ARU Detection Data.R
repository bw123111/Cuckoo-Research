####### Comparing 2022 Playback and ARU Detection Data ########


# A script to read in playback data from 2022 and run descriptive statistics/ make a bar graph to compare them

# Created 10/18/2023

# Last updated 10/18/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor")
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

ggplot(count_data, aes(x = bbcu, y = count, fill = factor(bbcu))) +
  geom_bar(stat = "identity") +
  labs(x = "BBCU Value", y = "Site Count") +
  scale_fill_manual(values = c("0" = "red", "1" = "green")) +
  theme_minimal()

table <- data.frame(
  aru_pos = c(2, 5),
  aru_neg = c(2, 31)
)
rownames(table) <- c("pb_pos","pb_neg")

# Print the table
print(table)

# Create a bar graph
# Reshape the data to long format
table_df_long <- table %>%
  rownames_to_column(var = "Category") %>%
  pivot_longer(cols = -Category, names_to = "Variable", values_to = "Value")

# Create a stacked bar graph
ggplot(table_df_long, aes(x = Category, y = Value, fill = Variable)) +
  geom_bar(stat = "identity") +
  labs(title = "Stacked Bar Graph", x = "Category", y = "Value") +
  scale_fill_manual(values = c("aru_pos" = "blue", "aru_neg" = "red", "pb_pos" = "green", "pb_neg" = "purple")) +
  theme_minimal() +
  scale_y_continuous(breaks = seq(0, max(table_df_long$Value), by = 5))
