############## Making Plots ##############


# This is a script to generate plots for use in my proposal and defense 
# Last update: 3/31/2023


########## Load Packages ################
packages <- c("data.table","sf","ggmap","terra","raster","mapview","tidyverse","rgdal","XML","methods","FedData","rasterVis","tidyterra","spsurvey", "spData", "usmap","ggspatial","cowplot")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


############## Setting up Data ######################
# Read in points
locs_dat <- fread(".\\Data\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) %>% st_set_crs(32100)

# read in the updated, reprojected raster
lcov <- terra::rast(".\\Data\\Spatial_Data\\NLCD_2019_MTLandcoverProjected.tiff")
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
hydro <- st_read(".\\Data\\Spatial_Data\\MT_Rivers\\hd43a.shp")
# Filter out only the rivers in our study area
names <- c("Missouri River","Yellowstone River","Musselshell River")
proj_hydro <- hydro %>% filter(NAME %in% names)
proj_hydro <- proj_hydro %>% dplyr::select(NAME, geometry)
# write the shapefile with only project rivers for later use
st_write(proj_hydro,".\\Data\\Spatial_Data\\MT_Rivers\\Project_Rivers_Unmerged.shp")

# Read in the point file to label the rivers
river_names <- fread(".\\Data\\Spatial_Data\\River_Label_Points.csv")
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

# make a bounding box in UTM
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


# convert your bounding box to an sfc polygon object
proj_box <- proj_bound %>% st_as_sfc()
proj_boxUTM <- proj_boundUTM %>% st_as_sfc()



############# Basemap ##################
# let's now grab a basemap from stamenmap just to check our bounding box is set up correctly
basemap_orig <- get_stamenmap(as.numeric(proj_bound),maptype = "terrain-background", zoom=8)
# https://github.com/dkahle/ggmap/issues/160#issuecomment-397055208
basemap_test <- ggmap::get_map(location = unname(st_bbox(locs_sf)),source="stamen")
plot(basemap_test)
# good

# The issue with this basemap is that it isn't plotting properly with geom_sf in a plot (see Fig 1 chunk below)
# potential solution is to coerce the projection from the bounding box: https://github.com/dkahle/ggmap/issues/160#issuecomment-397055208

# Define a function to fix the bbox to be in EPSG:3857
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
test_map_uk <- ggmap_bbox(basemap_orig)

ggmap(basemap_orig) + 
  coord_sf(crs = st_crs(32100)) + # force the ggplot2 map to be in 32100
  geom_sf(data = all_locs, inherit.aes = FALSE)

# I also tried transforming it into a raster object
basemap_rast <- terra::rast(basemap_orig)
crs(basemap_rast) <- "+proj=lcc +lat_0=44.25 +lon_0=-109.5 +lat_1=49 +lat_2=45 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs"
crs(basemap_rast) <- "EPSG:32100"
# base plot 
# figure out how to do this
plot(basemap_rast)
#plot(proj_hydro, add = TRUE)
plot(locs_sf$geometry, add = TRUE)

############### Figure 1: Base Layers ####################


# https://datacarpentry.org/r-raster-vector-geospatial/02-raster-plot/
# why is it putting the points in the wrong place?

# plot for Figure 1 of proposal with land cover
## This is kind of messy, I would prefer to do it with a basemap instead
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

# Stuff that doesn't work
#+ scale_y_continuous(limits = c(45.0,48.0),breaks = seq(45.0, 48.0, by = .5))
# not doing anything
#theme(legend.position = "none") +
# if you take out coord_sf() add in theme_bw()
# north arrow: https://rdrr.io/cran/ggspatial/man/annotation_north_arrow.html
# need to add on the rivers



# Plot for Figure 1 with basemap
# Jordan's suggestion: try fortify with buff so that it'll talk with the basemap
buff_ff <- fortify(buff)

Fig1_base2 <- ggmap(basemap_orig)+
  #add in basemap
  #geom_spatraster(data = basemap_rast) + 
  # add on your buff object
  geom_sf(data=buff_ff, mapping=aes(geometry=geometry), inherit.aes = FALSE) +
  coord_sf(expand=FALSE)+
  # give it a title and axis labels
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "bl", width=unit(.8,"cm"),height=unit(.8,"cm"),which_north = "true",pad_y = unit(0.2, "in"),style = north_arrow_fancy_orienteering) + theme(legend.position='none')



########## Figure 1: Rivers ###########
# With whatever map you go with, add on the rivers 

Fig1_base+ geom_text(data= river_names,aes(x=lon, y=lat, label=River), fontface = "bold", check_overlap = FALSE) 
# ISSUE: these points are plotting way off the map
# stuff that doesn't work
# adding inherit.aes also doesn't work
#Fig1_base+ geom_text(data= river_names,aes(x=lon, y=lat, label=River),inherit.aes=FALSE, fontface = "bold", check_overlap = FALSE) 
# need to figure out why these are so far out?

# Try just plotting one point as a test
Fig1_base + geom_point(x= -109.356532
, y= 47.784005
, size = 50, color="red")
# ISSUE: this isn't adding to the map?

# Could also try:
# make a coordinate point for each river and plot it
# lon <- c(xmin_proj,xmax_proj)
# lat <- c(ymin_proj,ymax_proj)
# box_df <- data.frame(lon,lat)


################ Figure 1: State Map and Project Area Insert #####


# working making this map better with an insert:
# pull in map of entire US
data("us_states", package = "spData")
#montana = read_sf(system.file("shape/mt.shp", package = "sf"))
# old crs 2163
us_states_9311 <-  st_transform(us_states, crs = 9311)
montana <- us_states_9311 %>% filter(NAME=="Montana")

# Plot Montana on US Data
# us_mt_plot <- ggplot() + 
#   geom_sf(data = us_states_9311, fill = "white") +
#   geom_sf(data = montana, fill = "light green")

# Make a map for just Montana 
MT_insert <- ggplot()+geom_sf(data=montana) + coord_sf(expand=FALSE)+ theme(rect=element_blank(),axis.text.x = element_blank(),axis.text.y = element_blank())
# need to add on the bounding box
MT_insert +geom_rect(
  xmin=xmin_UTM,
  ymin = ymin_UTM,
  xmax = xmax_UTM,
  ymax = ymax_UTM, fill = NA,
  color = "red",
  linewidth=5
)



# Add it on to the figure 1 plot
ggdraw(Fig1_base) + draw_plot(MT_insert,x=.58,y=.2,width=.3,height=.2) 
# need to play around with X and Y


#http://www.sthda.com/english/wiki/ggplot2-legend-easy-steps-to-change-the-position-and-the-appearance-of-a-graph-legend-in-r-software#remove-the-plot-legend


######## plot for Figure 2 of proposal ##############


ggplot()+
  geom_spatraster(data = lcov_crop) + 
  scale_fill_manual(values=colors)+
  geom_sf(data=buff) + 
  geom_sf(data = locs_sf, 
          mapping=aes(geometry=geometry, color = organization))+
  theme(legend.position = "none") + 
  labs(title = "Study Area Rivers")

# use the old basemap data for this and use the updated 2022 points


##### code graveyard ####################
# reproject it to the same coordinate system as the us map
# box_sf_test <- box_sf %>%
#   st_transform("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs +type=crs") 
# plot(box_sf)
# crs(box_sf_test)

# geom_sf(data=river_names) +
#   mapview(river_names)
# 
# # use scale_y_continuous and sclae_x continuous
# ggplot(data = world) +
#   geom_sf()
# 
# # can also try theme_minimal() or something similar to get the gray lines away 

# 
# # We want to create an object that we can visualize on the map
# ## New solution: geom_rect
# # try converting bounding box to an sf object
# 
# # make a matrix of the coordinates of the bounding box
# lon <- c(-112.35849,-112.35849,-103.97674,-103.97674,-112.35849)
# lat <- c(49.03619,44.94910,44.94910,49.03619,49.03619)
# ID <- c("A","B","C","D","E")
# coords <- cbind(lon,lat)
# coords_df <- as.data.frame(coords)
# str(coords_df)
# # convert to sf
# box_sf <- coords_df %>% 
#   st_as_sf(coords=c("lon", "lat")) %>%
#   st_set_crs(9311)
# plot(box_sf)
# 
# # the box isn't visualizing right on the map, I think because it has zero fields. The issue may be that the geometry isn't converting, maybe instead of st_as_sf (which converts already existing spatial data to an as object), I should try st_sf() (which creates a spatial object from scratch): https://r-spatial.github.io/sf/reference/sf.html
# # convert to sf using st_sf()
# box_sf <- st_sf(coords_df)
# # error: no simple features geometry present
# # create 
# st_sfc(coords_df$lon,coords_df$lat)
# # box_sf <- st_sf(coords_df,geometry=st_sfc(st_point(cbind(coords_df$lon,coords_df$lat))))
# 
# # try converting it into a multiline string: https://r-spatial.github.io/sf/reference/st.html
# st_multilinestring(coords)
# # resource on casting: https://rdrr.io/cran/sf/man/st_cast.html
# 
# 
# # connect the dots of the sf object
# # https://stackoverflow.com/questions/58150279/plotting-lines-between-two-sf-point-features-in-r
# # https://stackoverflow.com/questions/64594460/create-line-segments-from-gps-points-in-r-sf
# test <- box_sf %>% summarize(do_union = FALSE) %>% st_cast("MULTILINESTRING")
# #test <- st_cast(box_sf,to="LINESTRING")
# plot(test)
# crs(test)
# # error: this isn't visualizing on the map and I think it's because the feature has zero fields 
# 
# ## Trying something else:https://stackoverflow.com/questions/69638192/draw-polygons-around-coordinates-in-r
# hulls <- coords_df %>% st_as_sf(coords=c("lon","lat")) %>% summarize(geometry = st_union(geometry))
# hulls
# # also has zero fields

# These points won't plot on a map? why?
# Testing plotting points
# plot(lcov)
# points(river_names)
# plot(st_geometry(river_names_sf),pch=10)


# # add the bounding box to the map
# us_mt_plot +geom_sf(data=test)
# # adding one point in South Dakota??
# box_sf
# # not working: 
# # ggplot()+
# #   geom_spatraster(data = lcov_crop) + 
# #   scale_fill_manual(values=colors)+
# #   geom_sf(data=proj_hydro) + 
# #   geom_sf_label(data = proj_hydro, aes(label = NAME))+
# #   theme(legend.position = "none") + 
# #   labs(title = "Study Area Rivers")