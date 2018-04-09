setwd('~/Downloads/')

library(raster)
# get Landsat data


l.blue <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B2.TIF')
l.green <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B3.TIF')
l.red <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B4.TIF')
l.nir <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B5.TIF')
l.swir1 <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B6.TIF')
l.swir2 <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B7.TIF')
l.pc <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B8.TIF')
l.cirrus <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B9.TIF')
l.t1 <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B10.TIF')
l.t2 <- raster('LC08_L1TP_024030_20170602_20170615_01_T1/LC08_L1TP_024030_20170602_20170615_01_T1_B11.TIF')

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
writeRaster(ls.c,filename = 'Madison_Landsat_20170602.tif', format="GTiff", overwrite=TRUE)

r = brick('Madison_Landsat_20180317.tif')
names(r) <- c('red','green','blue','NIR','SWIR1','SWIR2','cirrus','thermal1','thermal2')

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

# Extract raster values
library(sf)


mendota <- st_read('../Lecture2_CRS/Data/LakeMendota.shp') %>%
  st_transform('+proj=utm +zone=16 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
# random sample of 100 points
l.pts <- st_sample(mendota, size = 100) %>% st_sf
library(sp)
lake <- extract(r, as(l.pts,'Spatial'))

watershed <- st_read('../Lecture3_Shapefiles/Data/YaharaBasins/Mendota_Basin.shp') %>%
  st_transform('+proj=utm +zone=16 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
# random sample of 100 points
ws.pts <- st_sample(watershed, size = 100) %>% st_sf
ws <- extract(r, as(ws.pts,'Spatial'))


# To see some of the reflectance values
head(df)
lake.M <- colMeans(lake)
ws.M <- colMeans(ws,na.rm = T)

plot(ws.M,xlab='Bands',ylab='Reflectance',type='b')
lines(lake.M,type='b',col='blue')
legend('topleft',legend = c('Watershed','Lake'),col = c('black','blue'),pch=21,bty='n')

## NDVI
# NDVI= (NIR−Red) / (NIR+Red)

ndvi <- (r[[4]] - r[[1]]) / (r[[4]] + r[[1]])
# Areas of barren rock, sand, or snow usually show very low NDVI values (for example, 0.1 or less). Sparse vegetation such as shrubs and grasslands or senescing crops may result in moderate NDVI values (approximately 0.2 to 0.5). High NDVI values (approximately 0.6 to 0.9) correspond to dense vegetation such as that found in temperate and tropical forests or crops at their peak growth stage. 
plot(ndvi)
# As expected the NDVI ranges from about 0.2, which corresponds to nearly bare soils, to 0.9 which means that there is some dense vegetation in the area.

#NDWI Normalized Difference Water Index (NDWI), as described by McFeeters (1996), can be utilized to differentiate water from non-water.
ndwi <- (r[[3]] - r[[4]]) / (r[[3]] + r[[4]])
plot(ndwi)
ndwi[ndwi < 0.1] = NA
plot(ndwi)

# NDSI 
#NDSI is calculated using the following general equation: NDSI = (Green – SWIR)/(Green + SWIR).
ndsi <- (r[[2]] - r[[5]]) / (r[[2]] + r[[5]])
plot(ndsi)
# NDSI snow/ice thresholds: low confidence (NDSI ≥ 0.4), medium confidence (NDSI ≥ 0.5), and high confidence (NDSI ≥ 0.6).


# Thresholding
# We can apply basic rules to get an estimate of spatial extent of different Earth surface features. Note that NDVI values are standardized and ranges between -1 to +1. Higher values indicate more green cover.

# Pixels having NDVI values greater than 0.4 are definitely vegetation. Following operation masks all non-vegetation pixels.
ndvi[ndvi < 0.4] = NA
plot(ndvi)

# Unsupervised classification
km <- kmeans(values(r), centers=5, iter.max=500,
             nstart=3, algorithm="Lloyd")
kmr <- setValues(ndvi, km$cluster)
plot(kmr, main = 'Unsupervised classification of Landsat data')

km2 <- kmeans(values(r), centers=2, iter.max=500,
              nstart=3, algorithm="Lloyd")
kmr <- setValues(ndwi, km2$cluster)
plot(kmr, main = 'Unsupervised classification of Landsat data')
