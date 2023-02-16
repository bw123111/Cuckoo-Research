############### Land Cover Sampling Data ###############

library(data.table)
library(sf)
library(ggmap)


########### 1: Load in the data and visualize it #############
# load in locations data
locs_dat <- fread(".\\Data\\Spatial_Data\\2022_ALLPoints.csv")
locs_dat <- na.omit(locs_dat)
## Don't open a shapefile with fread
# Do I need to remove NAs or can I do that later? Missing values in coordinates not allowed
#convert this into a spatial object
locs_sf <- locs_dat %>% 
  st_as_sf(coords=c("long", "lat")) 


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

# let's now grab a basemap from stamenmap just to check our bounding box is set up correctly
basemap_proj <- get_stamenmap(as.numeric(proj_bound),maptype = "terrain-background", zoom=6)

# take a look:
ggmap(basemap_proj)
# Looks good!


###### 2: Set the boundaries of the survey area in the river valleys ##########
## Would it be easier to make this layer within ArcGIS?

# Or get some feature layer and then draw a buffer around it 
## rivers/streams in MT: https://msl.mt.gov/geoinfo/msdi/hydrography/
# Read in this data from the D: MT_Spatial_Data drive - convert the shp files to a .tif or something
## downloading NHDH_MT_Shape
## Drawing a buffer: "Geometrical operations" in this source: https://cran.r-project.org/web/packages/sf/vignettes/sf1.html


##### 3: Within this area, subset each of the land cover types and establish your unit size #######
# Unit size has to be all within one land cover type - how large are the pixels on the map? This would be the resolution 
# could do it so that your unit size is larger than the pixels but you choose what the majority of pixels are to count witihn that strata and only sample within those locations of the pixel 



#### 4: Implement stratified random sampling within each of the strata #########

