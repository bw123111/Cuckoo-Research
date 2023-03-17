############## Making Plots ##############
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

########### Code #################


# Read in points
locs_dat <- fread(".\\Data\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
## Don't open a shapefile with fread
# Do I need to remove NAs or can I do that later? Missing values in coordinates not allowed
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) %>% st_set_crs(32100)

# read in the updated, reprojected raster
lcov <- terra::rast(".\\Data\\Spatial_Data\\NLCD_2019_MTLandcoverProjected.tiff")
lcov <- as.factor(lcov)

# # Working with NLCD data: https://smalltownbigdata.github.io/feb2021-landcover/feb2021-landcover.html
# # load in the legend 
legend <- pal_nlcd()
#lcov_test <- merge(lcov, df, by = "ID")
#lcov_test <- lcov
vals <- unique(lcov[[1]])
# # pull out the values of the legend that are in the values of my map
df <- legend[legend$ID %in% vals$label,]
levels(lcov) <- df[,c("ID","Class")]
# need to relate the colors that it plots the raster to specific variables 
colors=c("#5475A8","#FFFFFF","#E8D1D1","#E29E8C","#ff0000","#B50000","#D2CDC0","#85C77E","#38814E","#D4E7B0","#DCCA8F","#FDE9AA","#FBF65D","#CA9146","#C8E6F8","#64B3D5")


# read in the hydrology shapefile
hydro <- st_read("E:\\MT_Spatial_Data\\MT_Lakes_Streams\\hd43a\\hd43a.shp")
# Filter out only the rivers in our study area
names <- c("Missouri River","Yellowstone River","Musselshell River")
proj_hydro <- hydro %>% filter(NAME %in% names)
proj_hydro <- proj_hydro %>% dplyr::select(NAME, geometry)
# create a buffer around the hydro
buff <- st_buffer(proj_hydro, dist = 1500)


# Crop the landcover layer to the buffer layer
lcov_crop <- crop(lcov, buff, snap = "near")


# Bounding box coordinates from MRLC download 2/15:
ymin_proj <- 44.94910
ymax_proj <- 49.03619
xmin_proj <- -112.35849
xmax_proj <- -103.97674

# pull up the basemap to see if you have the right bounding box area
#have to give st_bbox an object
proj_bound <- st_bbox(locs_sf)

# or not?
# proj_bound <- st_bbox() no you do have to give it an object
# lets reset the boundaries to what we want, the order is"
#xmin, ymin, xmax, ymax
proj_bound[1] <- xmin_proj
proj_bound[2] <- ymin_proj
proj_bound[3] <- xmax_proj
proj_bound[4] <- ymax_proj



############### Making plots ####################

## Trying with land cover
ggplot()+
  geom_spatraster(data = lcov) + scale_fill_manual(values=colors)+
  geom_sf(data=proj_hydro, aes(color=NAME)) + theme(legend.position = "none")



# plot for Figure 1 of proposal 
ggplot()+
  geom_spatraster(data = lcov_crop) + 
  scale_fill_manual(values=colors)+
  geom_sf(data=buff) + 
  theme(legend.position = "none") + 
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  theme_bw() #+ scale_y_continuous(breaks = seq(45.0, 48.0, by = .5))

# use scale_y_continuous and sclae_x continuous

# can also try theme_minimal() or something similar to get the gray lines away 

# make a coordinate point for each river and plot it


# working making this map better with an insert:
## also try adding a scale bar and north arrow
# plot map of entire US
data("us_states", package = "spData")
#montana = read_sf(system.file("shape/mt.shp", package = "sf"))
us_states_2163 <-  st_transform(us_states, crs = 2163)
montana <- us_states_2163 %>% filter(NAME=="Montana")
plot(montana)
plot(us_states_2163)

# for bounding box, make a polygon with the four coordinates of bounding box as the four corners and connect them

ggplot() + 
  geom_sf(data = us_states_2163, fill = "white") +
  geom_sf(proj_bound)
geom_sf(data = montana, fill = "light green") # add bounding box around project area

# not working: 
# ggplot()+
#   geom_spatraster(data = lcov_crop) + 
#   scale_fill_manual(values=colors)+
#   geom_sf(data=proj_hydro) + 
#   geom_sf_label(data = proj_hydro, aes(label = NAME))+
#   theme(legend.position = "none") + 
#   labs(title = "Study Area Rivers")


# plot for Figure 2 of proposal
ggplot()+
  geom_spatraster(data = lcov_crop) + 
  scale_fill_manual(values=colors)+
  geom_sf(data=buff) + 
  geom_sf(data = locs_sf, 
          mapping=aes(geometry=geometry, color = organization))+
  theme(legend.position = "none") + 
  labs(title = "Study Area Rivers")
