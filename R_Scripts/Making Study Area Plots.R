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

#have to give st_bbox an object
proj_bound <- st_bbox(locs_sf)

# lets reset the boundaries to what we want, the order is"
#xmin, ymin, xmax, ymax
proj_bound[1] <- xmin_proj
proj_bound[2] <- ymin_proj
proj_bound[3] <- xmax_proj
proj_bound[4] <- ymax_proj


# convert your bounding box to an sfc polygon object
proj_box <- proj_bound %>% st_as_sfc()


# try converting it to an sf object

# make a matrix of the coordinates of the bounding box
lon <- c(-112.35849,-112.35849,-103.97674,-103.97674,-112.35849)
lat <- c(49.03619,44.94910,44.94910,49.03619,49.03619)
ID <- c("A","B","C","D","E")
coords <- cbind(lon,lat)
coords_df <- as.data.frame(coords)
str(coords_df)
# convert to sf
box_sf <- coords_df %>% 
  st_as_sf(coords=c("lon", "lat")) %>%
  st_set_crs(9311)


# the box isn't visualizing right on the map, I think because it has zero fields. The issue may be that the geometry isn't converting, maybe instead of st_as_sf (which converts already existing spatial data to an as object), I should try st_sf() (which creates a spatial object from scratch): https://r-spatial.github.io/sf/reference/sf.html
# convert to sf using st_sf()
box_sf <- st_sf(coords_df)
# error: no simple features geometry present
# create 
st_sfc(coords_df$lon,coords_df$lat)
# box_sf <- st_sf(coords_df,geometry=st_sfc(st_point(cbind(coords_df$lon,coords_df$lat))))

# try converting it into a multiline string: https://r-spatial.github.io/sf/reference/st.html
st_multilinestring(coords)
# resource on casting: https://rdrr.io/cran/sf/man/st_cast.html


# connect the dots of the sf object
# https://stackoverflow.com/questions/58150279/plotting-lines-between-two-sf-point-features-in-r
# https://stackoverflow.com/questions/64594460/create-line-segments-from-gps-points-in-r-sf
test <- box_sf %>% summarize(do_union = FALSE) %>% st_cast("MULTILINESTRING")
#test <- st_cast(box_sf,to="LINESTRING")
plot(test)
crs(test)
# error: this isn't visualizing on the map and I think it's because the feature has zero fields 

## Trying something else:https://stackoverflow.com/questions/69638192/draw-polygons-around-coordinates-in-r
hulls <- coords_df %>% st_as_sf(coords=c("lon","lat")) %>% summarize(geometry = st_union(geometry))
hulls
# also has zero fields



############### Making plots ####################

## Trying with land cover
ggplot()+
  geom_spatraster(data = lcov) + scale_fill_manual(values=colors)+
  geom_sf(data=proj_hydro, aes(color=NAME)) + theme(legend.position = "none")

# https://datacarpentry.org/r-raster-vector-geospatial/02-raster-plot/

# plot for Figure 1 of proposal 
ggplot()+
  geom_spatraster(data = lcov_crop) + 
  scale_fill_manual(values=colors)+
  geom_sf(data=buff) + 
  theme(legend.position = "none") + 
  labs(title = "Study Area River Valleys", ylab = "Latitude", xlab = "Longitude") +
  theme_bw() + scale_y_continuous(limits = c(45.0,48.0),breaks = seq(45.0, 48.0, by = .5))

# use scale_y_continuous and sclae_x continuous

# can also try theme_minimal() or something similar to get the gray lines away 

# make a coordinate point for each river and plot it
lon <- c(xmin_proj,xmax_proj)
lat <- c(ymin_proj,ymax_proj)
box_df <- data.frame(lon,lat)


#####################


# working making this map better with an insert:
## also try adding a scale bar and north arrow
# plot map of entire US
data("us_states", package = "spData")
#montana = read_sf(system.file("shape/mt.shp", package = "sf"))
# old crs 2163
us_states_9311 <-  st_transform(us_states, crs = 9311)
montana <- us_states_9311 %>% filter(NAME=="Montana")
# plot(montana)
# plot(us_states_2163)
# make a plot of this
us_mt_plot <- ggplot() + 
  geom_sf(data = us_states_9311, fill = "white") +
  geom_sf(data = montana, fill = "light green")

# add the bounding box to the map
us_mt_plot +geom_sf(data=test)
# adding one point in South Dakota??
box_sf
# not working: 
# ggplot()+
#   geom_spatraster(data = lcov_crop) + 
#   scale_fill_manual(values=colors)+
#   geom_sf(data=proj_hydro) + 
#   geom_sf_label(data = proj_hydro, aes(label = NAME))+
#   theme(legend.position = "none") + 
#   labs(title = "Study Area Rivers")


######## plot for Figure 2 of proposal ##############
ggplot()+
  geom_spatraster(data = lcov_crop) + 
  scale_fill_manual(values=colors)+
  geom_sf(data=buff) + 
  geom_sf(data = locs_sf, 
          mapping=aes(geometry=geometry, color = organization))+
  theme(legend.position = "none") + 
  labs(title = "Study Area Rivers")


##### code graveyard ####
# reproject it to the same coordinate system as the us map
# box_sf_test <- box_sf %>%
#   st_transform("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs +type=crs") 
# plot(box_sf)
# crs(box_sf_test)