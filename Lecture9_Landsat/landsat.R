setwd('~/Downloads/')

library(raster)
# get Landsat data
r <- brick('Madison_Satellite_Imagery.tif')


l.blue <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B2.TIF')
l.green <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B3.TIF')
l.red <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B4.TIF')
l.nir <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B5.TIF')
l.swir1 <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B6.TIF')
l.swir2 <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B7.TIF')
l.pc <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B8.TIF')
l.cirrus <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B9.TIF')
l.t1 <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B10.TIF')
l.t2 <- raster('LC08_L1TP_024030_20180317_20180403_01_T1/LC08_L1TP_024030_20180317_20180403_01_T1_B11.TIF')

# plot(l.pc)
ls = brick(l.red,l.green,l.blue,l.nir,l.swir1,l.swir2,l.cirrus,l.t1,l.t2)

# CROP
extent(ls)
e <- extent(280000, 330000, 4750000, 4800000)
ls.c = crop(ls,e)

plot(ls.c)
plot(l.blue)
plotRGB(ls.c, r = 1, g = 2, b = 3, axes = TRUE, stretch = "lin",
        main = "Landsat True Color Composite")
writeRaster(ls.c,filename = 'Madison_Landsat.tif', format="GTiff", overwrite=TRUE)

r = ls.c
nlayers(r)
## [1] 10

# coordinate reference system (CRS)
crs(r)
## CRS arguments:
##  +proj=utm +zone=37 +datum=WGS84 +units=m +no_defs +ellps=WGS84
## +towgs84=0,0,0

# Number of rows, columns, or cells
ncell(r)
## [1] 3454124
dim(r)
## [1] 1934 1786   10

# spatial resolution
res(r)
## [1] 30 30


# You can plot indivudal layers of a multi-spectral image, but they are often combined to create more interesting plots. 
# To combine three bands, we can use plotRGB. To make a “true color” image (that is, something that looks like a normal photograph), 
# we need to select the bands that we want to render in the red, green and blue regions. For this Landsat image, r = 3 (red), g = 2(green), b = 1(blue) 
# will plot the true color composite (vegetation in green, water blue etc). 
# You can also supply additional arguments to plotRGB to improve the visualization (e.g. a linear stretch of the values, using strecth = "lin").




## NDVI
NDVI= (NIR−Red) / (NIR+Red)

ndvi <- (r[[4]] - r[[1]]) / (r[[4]] + r[[1]])
# Areas of barren rock, sand, or snow usually show very low NDVI values (for example, 0.1 or less). Sparse vegetation such as shrubs and grasslands or senescing crops may result in moderate NDVI values (approximately 0.2 to 0.5). High NDVI values (approximately 0.6 to 0.9) correspond to dense vegetation such as that found in temperate and tropical forests or crops at their peak growth stage. 
plot(ndvi)
# As expected the NDVI ranges from about 0.2, which corresponds to nearly bare soils, to 0.9 which means that there is some dense vegetation in the area.

#NDWI Normalized Difference Water Index (NDWI), as described by McFeeters (1996), can be utilized to differentiate water from non-water.
ndwi <- (r[[3]] - r[[4]]) / (r[[3]] + r[[4]])
plot(ndwi)


# NDSI 
#NDSI is calculated using the following general equation: NDSI = (Green – SWIR)/(Green + SWIR).
ndsi <- (r[[2]] - r[[5]]) / (r[[2]] + r[[5]])
plot(ndsi)
# NDSI snow/ice thresholds: low confidence (NDSI ≥ 0.4), medium confidence (NDSI ≥ 0.5), and high confidence (NDSI ≥ 0.6).

# Plot clouds
plot(ls.c[[7]])

