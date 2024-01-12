#### Clean 2023 Vegetation Survey Data ###################

## Purpose: to read in the Survey123 data files from the veg data, clean them, and output the cleaned data into a new folder

# Created 10/24/2023

# Last modified: 10/25/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# load in data
veg <- read.csv("./Data/Vegetation_Data/Raw_Data/2023_Vegetation_Survey_Data.csv") %>% clean_names()
# remove unnecessary columns
veg <- veg %>% select(-c(object_id, point_information,can_you_complete_this_survey, trees_vs_shrubs, if_the_point_has_an_aru_the_vegetation_plot_will_be_centered_on_a_point_9_m_in_front_of_the_aru_in_the_direction_that_the_microphone_is_facing,plot_veg_data,subplot_dir, select_a_reason_or_choose_other_to_describe_the_situation_please_state_in_the_notes_whether_someone_should_return_later_to_complete_the_veg,specify_other,subplot_no_why_collated,if_you_can_do_the_subplots_enter_data_below_if_not_leave_no_selected_above_and_submit_your_form_then_return_to_collector,x11_3m_radius_subplot,description_of_the_canopy,nice_work_please_submit_your_survey,creator,edit_date,editor))
# Test with unique which values only have NA or a single value
unique(veg$can_you_complete_this_survey)

# rename the long names
veg <- veg %>% rename(aru_present = does_this_site_have_an_aru, 
               snags_present = are_there_any_snags_present_in_your_11_3m_subplot, 
               total_percent_shrub_cover = total_shrub_cover_all_species_combined,
               notes = notes_from_this_subplot,
               bearing_to_center = which_bearing_was_used_to_find_the_center_of_the_vegetation_plot)


veg$point_id <- toupper(veg$point_id)
# Edit points that need correction
veg[19,2] <- "YELL-060"
#veg[114,2] <- "MISO-032"

# change _ to -
veg <- veg %>% mutate(point_id = str_replace(point_id, "_", "-"))
# Correct a misspelling
veg <- veg %>% mutate(point_id = str_replace(point_id, "MIS0", "MISO"))
veg <- veg %>% mutate(point_id = str_replace(point_id, "YMA", "YWM"))

# Remove the old SIP sites and replace with new ones
veg <- veg %>% filter(!point_id %in% c("SIP-1", "SIP-2"))
veg <- veg %>% mutate(point_id = str_replace(point_id, " NEW", ""))
# Fix MAN-3 duplication
veg[75,2] <- "MAN-2"
# Fix the JDD-1 duplication
veg[37,2] <- "JDD-2"

# write the cleaned data
write.csv(veg,"./Data/Vegetation_Data/Outputs/2023_VegSurveyData_Cleaned12-3.csv", row.names = FALSE)

