https://pudding.cool/process/regional_smoothing/
Smoothing: A word of warning
Smoothing is generally used to identify hot spots, or areas that have a high likelihood of differing 
from neighboring locations on attributes like births, crime, or disease. Through statistical means, 
this technique removes some of the variance you'd normally see in a choropleth, and helps give a bird's 
eye overview to a set of results. Unless your aim is to help provide a summary snapshot of granular data, 
smoothing may not be necessary, or even desired.



a = read.csv('~/Dropbox/WIwater_NLCD.csv',stringsAsFactors = F)

#### Counties data ####
library(rgdal)
library(viridisLite)
counties = readOGR('../Dropbox/RandomR/GIS_Wisconsin/County_Boundaries_24K/County_Boundaries_24K.shp',layer='County_Boundaries_24K')

counties$water = a$perWater

pw = (1:4)[cut(a$perWater,breaks = c(0,2.5,5,10,25))]
plot(counties,col = viridis(4)[pw])
legend('topright',legend = c('0-2.5','2.5-5','5-10','10-25'),fill = viridis(4))

library(proj4)
library(spdep)
library(maptools)
library(rgdal)

shapefile_df <- as(counties, "data.frame")

# Now we can start setting out the neighbors list. Neighbors of a location can usually be defined in one of three ways:
#   
# As polygons that share a border with the location in question
# As being within a certain distance from the location in question
# As a specific number of neighbors that are closest to the location; the precise number of neighbors us up to us. This is calculated using the k-nearest neighbors (KNN) algorithm.

coords <- coordinates(counties)
IDs<-row.names(as(counties, "data.frame"))

knn50 <- knn2nb(knearneigh(coords, k = 10), row.names = IDs)
knn50 <- include.self(knn50)


# Creating the localG statistic for each of counties, with a k-nearest neighbor value of 5, and round this to 3 decimal places
localGvalues <- localG(x = as.numeric(shapefile_df$water), listw = nb2listw(knn50, style = "B"), zero.policy = TRUE)
localGvalues <- round(localGvalues,3)


# Create a new data frame that only includes the county fips codes and the G scores
new_df <- data.frame(shapefile_df$COUNTY_NAM)
new_df$values <- localGvalues



par(mar=c(1,1,1,1),mfrow=c(1,2))

pw = (1:4)[cut(a$perWater,breaks = c(0,2.5,5,10,25))]
plot(counties,col = viridis(4)[pw])
legend('topright',legend = c('0-2.5','2.5-5','5-10','10-25'),fill = viridis(4),bty='n')

pw = (1:7)[cut(localGvalues,breaks = c(-2,-1,0,1,2,3,4,5))]
plot(counties,col = viridis(7)[pw])
legend('topright',legend = c('less water','more water'),fill = viridis(7)[c(1,7)],bty='n')

