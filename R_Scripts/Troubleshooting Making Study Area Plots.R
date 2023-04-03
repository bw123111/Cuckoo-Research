############## Making Plots ##############


# This is a script to generate plots for use in my proposal and defense 
# Current issues: 
## when creating spatial objects in R, they don't interact well with imported spatial data
## when trying to add a stamenmap, the coordinates are getting thrown off

# My thought is that since I'm plotting the data in this a NAD83 coordinate system: https://epsg.io/32100 the layers aren't talking to each other properly
# Could use a UTM projection, but the study area is bisected by zones 12 and 13

# Last update: 4/3/2023


########## Load Packages ################
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap","ggspatial","cowplot")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


############## Setting up Data ######################
# Read in points
locs_dat <- fread(".\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) %>% st_set_crs(32100)

# read in the updated, reprojected raster
lcov <- terra::rast(".\\Spatial_Data\\NLCD_2019_MTLandcoverProjected.tiff")
# convert to a factor so it visualizes correctly
lcov <- as.factor(lcov)
# # load in the legend 
legend <- pal_nlcd()
vals <- unique(lcov[[1]])
df <- legend[legend$ID %in% vals$label,]
levels(lcov) <- df[,c("ID","Class")]
# need to relate the colors that it plots the raster to specific variables 
colors=c("#5475A8","#FFFFFF","#E8D1D1","#E29E8C","#ff0000","#B50000","#D2CDC0","#85C77E","#38814E","#D4E7B0","#DCCA8F","#FDE9AA","#FBF65D","#CA9146","#C8E6F8","#64B3D5")


# read in the hydrology shapefile
hydro <- st_read(".\\Spatial_Data\\MT_Rivers\\hd43a.shp")
# Filter out only the rivers in our study area
names <- c("Missouri River","Yellowstone River","Musselshell River")
hydro_mush <- hydro %>% filter(NAME =="Musselshell River")
#st_write(hydro_mush,".\\Data\\Spatial_Data\\MT_Rivers\\Musselshell_River.shp")
hydro_miso <- hydro %>% filter(NAME == "Missouri River")
#st_write(hydro_miso,".\\Data\\Spatial_Data\\MT_Rivers\\Missouri_River.shp")
hydro_yell <- hydro %>% filter(NAME == "Yellowstone River")
#st_write(hydro_yell,".\\Data\\Spatial_Data\\MT_Rivers\\Yellowstone_River.shp")
proj_hydro <- hydro %>% filter(NAME %in% names)
proj_hydro <- proj_hydro %>% dplyr::select(NAME, geometry)
# write the shapefile with only project rivers for later use
#st_write(proj_hydro,".\\Data\\Spatial_Data\\MT_Rivers\\Project_Rivers_Unmerged.shp")

# Read in the point file to label the rivers
river_names <- fread(".\\Spatial_Data\\River_Label_Points.csv")
# transform to an sf object
river_names_sf <- river_names %>% 
  st_as_sf(coords=c("lon", "lat")) %>% st_set_crs(32100)
#river_names_pt <- river_names %>% st_sf(st_point(c(river_names$lon,river_names$lat)),crs=32100)
# Error in getClassDim(x, length(x), dim, "POINT") : 
#6 is an illegal number of columns for a POINT

# create a buffer around the hydro for better visualization
## NOTE the distance used to buffer for LiDAR data is only 400 m, but this looks better for visualizing
## Could also try just adding on the proj_hydro and making it larger
buff <- st_buffer(proj_hydro, dist = 1500)


# Crop the landcover layer to the buffer layer
lcov_crop <- crop(lcov, buff, snap = "near")



############# Bounding box #####################

# Bounding box coordinates from MRLC download 2/15:
ymin_proj <- 44.94910
ymax_proj <- 49.03619
xmin_proj <- -112.35849
xmax_proj <- -103.97674

#have to give st_bbox an object
proj_bound <- st_bbox(locs_sf)

# lets reset the boundaries to what we want, the order is"
#xmin, ymin, xmax, ymax
proj_bound[1] <- xmin_proj
proj_bound[2] <- ymin_proj
proj_bound[3] <- xmax_proj
proj_bound[4] <- ymax_proj

# make a bounding box in UTM as well
easting_min <- 92835
ymin_UTM <- easting_min
easting_max <- 74789
ymax_UTM <- easting_max
northing_min <- 78194
xmin_UTM <- northing_min
northing_max <- 31983
xmax_UTM <- northing_max
proj_boundUTM <- st_bbox(locs_sf)
proj_boundUTM[1] <- northing_min
proj_boundUTM[2] <- easting_min
proj_boundUTM[3] <- northing_max
proj_boundUTM[4] <- easting_max


# convert bounding boxes to an sfc polygon object
proj_box <- proj_bound %>% st_as_sfc()
proj_boxUTM <- proj_boundUTM %>% st_as_sfc()




############### Figure 1: Base Layer ####################
# plot for Figure 1 of proposal with land cover

Fig1_base <- ggplot()+
  #add in land cover data
  geom_spatraster(data = lcov_crop) + 
  # specify to fill it with certain colors
  scale_fill_manual(values=colors)+
  # add on your buff object
  geom_sf(data=buff, fill = "light blue") +
  coord_sf(expand=FALSE)+
  # give it a title and axis labels
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "bl", width=unit(.8,"cm"),height=unit(.8,"cm"),which_north = "true",pad_y = unit(0.2, "in"),style = north_arrow_fancy_orienteering) + theme(legend.position='none')

# Take a look at it
Fig1_base

# Using the landcover as a base map looks pretty messy, let's try pulling a different basemap


############# Basemap ##################
# let's now grab a terrain basemap from stamenmap 
basemap_orig <- get_stamenmap(as.numeric(proj_bound),maptype = "terrain-background", zoom=8)
# https://github.com/dkahle/ggmap/issues/160#issuecomment-397055208
# Trying out a different way of pulling it
#basemap_test <- ggmap::get_map(location = unname(st_bbox(locs_sf)),source="stamen")

plot(basemap_orig)
# Looks good

# the basemap is a ggmap object, so lets try plotting it and adding our points on top
ggmap(basemap_orig) + 
  coord_sf(crs = st_crs(32100)) + # force the ggplot2 map to be in 32100
  geom_sf(data = locs_sf, inherit.aes = FALSE) # add on survey points

# This is plotting both sets of data, but the x and y axis have changed 

# We see the same issue when we add it to our code from Figure 1
Fig1_base2 <- ggmap(basemap_orig)+
  # add on your buff object
  geom_sf(data=buff, mapping=aes(geometry=geometry), inherit.aes = FALSE) +
  coord_sf(expand=FALSE)+
  # give it a title and axis labels
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "bl", width=unit(.8,"cm"),height=unit(.8,"cm"),which_north = "true",pad_y = unit(0.2, "in"),style = north_arrow_fancy_orienteering) + theme(legend.position='none')

Fig1_base2
# X and Y axis are still incorrect


# Try transforming it into a raster object and redefining the projection
basemap_rast <- terra::rast(basemap_orig)
crs(basemap_rast) <- "+proj=lcc +lat_0=44.25 +lon_0=-109.5 +lat_1=49 +lat_2=45 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs"
crs(basemap_rast) <- "EPSG:32100"

# test out the basemap raster
plot(basemap_rast)
plot(locs_sf$geometry, add = TRUE)
# This looks ok, let's try adding it into our map for the figure

Fig1_base3 <- ggplot()+
  #add in basemap
  geom_spatraster(data = basemap_rast) + 
  # add on your buff object
  geom_sf(data=buff, mapping=aes(geometry=geometry), inherit.aes = FALSE) +
  coord_sf(expand=FALSE)+
  # give it a title and axis labels
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "bl", width=unit(.8,"cm"),height=unit(.8,"cm"),which_north = "true",pad_y = unit(0.2, "in"),style = north_arrow_fancy_orienteering) + theme(legend.position='none')

Fig1_base3
# The basemap doesn't show up at all but the coordinates look correct


# Potential solution is to coerce the projection from the bounding box: https://github.com/dkahle/ggmap/issues/160#issuecomment-397055208
## Define a function to fix the bbox to be in EPSG:3857 #############
## NOTE: I haven't finished editing this function from the online forum
ggmap_bbox <- function(map) {
  if (!inherits(map, "ggmap")) stop("map must be a ggmap object")
  # Extract the bounding box (in lat/lon) from the ggmap to a numeric vector, 
  # and set the names to what sf::st_bbox expects:
  map_bbox <- setNames(unlist(attr(map, "bb")), 
                       c("ymin", "xmin", "ymax", "xmax"))
  
  # Coonvert the bbox to an sf polygon, transform it to 3857, 
  # and convert back to a bbox (convoluted, but it works)
  bbox_32100 <- st_bbox(st_transform(st_as_sfc(st_bbox(map_bbox, crs = 4326)), 32100))
  
  # Overwrite the bbox of the ggmap object with the transformed coordinates 
  attr(map, "bb")$ll.lat <- bbox_32100["ymin"]
  attr(map, "bb")$ll.lon <- bbox_32100["xmin"]
  attr(map, "bb")$ur.lat <- bbox_32100["ymax"]
  attr(map, "bb")$ur.lon <- bbox_32100["xmax"]
  map
}

# Use the function:
test_map <- ggmap_bbox(basemap_orig)

###################


########## Figure 1: Rivers ###########
# With whatever map you go with, add on the names for the rivers 

Fig1_base+ geom_text(data= river_names,aes(x=lon, y=lat, label=River), fontface = "bold", check_overlap = FALSE) 
# The points are plotting way off the map


# Try just plotting one point as a test
Fig1_base + geom_point(x= -109.356532
                       , y= 47.784005
                       , size = 50, color="red")
# ISSUE: this isn't adding to the map?


################ Figure 1: State Map and Project Area Insert #####
# working making this map better with an insert:
# pull in map of entire US
data("us_states", package = "spData")
# old crs 2163
us_states_9311 <-  st_transform(us_states, crs = 9311)
montana <- us_states_9311 %>% filter(NAME=="Montana")

# Make a map for just Montana 
MT_insert <- ggplot()+geom_sf(data=montana) + coord_sf(expand=FALSE)+ theme(rect=element_blank(),axis.text.x = element_blank(),axis.text.y = element_blank())

MT_insert
# looks good 

# Try adding it on to the figure 1 plot
ggdraw(Fig1_base) + draw_plot(MT_insert,x=.58,y=.2,width=.3,height=.2) 
# Looks good, need to play around with X and Y spacing a bit more

# need to add on the bounding box to display the project area bounds within the state
MT_insert +geom_rect(
  xmin=xmin_UTM,
  ymin = ymin_UTM,
  xmax = xmax_UTM,
  ymax = ymax_UTM, fill = NA,
  color = "red",
  linewidth=5
)
# The geom_rect() isn't showing up


######## plot for Figure 2 of proposal ##############
# Fill this in after you figure out the issues with Figure 1
# 
# ggplot()+
#   geom_spatraster(data = lcov_crop) + 
#   scale_fill_manual(values=colors)+
#   geom_sf(data=buff) + 
#   geom_sf(data = locs_sf, 
#           mapping=aes(geometry=geometry, color = organization))+
#   theme(legend.position = "none") + 
#   labs(title = "Study Area Rivers")

# use the old basemap data for this and use the updated 2022 points