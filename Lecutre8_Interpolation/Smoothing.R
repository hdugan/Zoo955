https://pudding.cool/process/regional_smoothing/
Smoothing: A word of warning
Smoothing is generally used to identify hot spots, or areas that have a high likelihood of differing 
from neighboring locations on attributes like births, crime, or disease. Through statistical means, 
this technique removes some of the variance you'd normally see in a choropleth, and helps give a bird's 
eye overview to a set of results. Unless your aim is to help provide a summary snapshot of granular data, 
smoothing may not be necessary, or even desired.


#### Counties data ####
library(rgdal)
library(viridisLite)
library(proj4)
library(spdep)
library(maptools)
library(rgdal)


# Going to use % water from Wisconsin counties again
a = read.csv('../Zoo955_WeeklyAssignments/Week6_WIwater_NLCD.csv',stringsAsFactors = F)
counties = readOGR('../Lecture6_Overlays/Data/County_Boundaries_24K/County_Boundaries_24K.shp',layer='County_Boundaries_24K')
counties$water = a$perWater
countyPts = SpatialPointsDataFrame(counties,data = counties@data,proj4string = crs(counties))


#Create color bins
pw = (1:4)[cut(a$perWater,breaks = c(0,2.5,5,10,25))]
# Plot counties
par(mfrow=c(1,2))
plot(counties,col = viridis(4)[pw])
legend('topright',legend = c('0-2.5','2.5-5','5-10','10-25'),fill = viridis(4))
# Can also change polygons to points  
countyPts = SpatialPointsDataFrame(counties,data = counties@data,proj4string = crs(counties))
plot(countyPts,col = viridis(4)[pw],pch=16)


# Now we can start setting out the neighbors list. Neighbors of a location can usually be defined in one of three ways:

# As polygons that share a border with the location in question
# As being within a certain distance from the location in question
# As a specific number of neighbors that are closest to the location; the precise number of neighbors us up to us. This is calculated using the k-nearest neighbors (KNN) algorithm.

# Get county coordinates
knn50 <- knn2nb(knearneigh(coordinates(counties), k = 10), row.names = counties$OBJECTID)
knn50 <- include.self(knn50)

# Creating the localG statistic for each of counties. This is the same as the Getis-Ord score
http://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-hot-spot-analysis-getis-ord-gi-spatial-stati.htm
# with a k-nearest neighbor and round this to 3 decimal places
localGvalues <- localG(x = counties$water, listw = nb2listw(knn50, style = "B"), zero.policy = TRUE)
localGvalues <- round(localGvalues,3)

# Add gscores G scores
counties$gvalues <- localGvalues

par(mar=c(1,1,1,1),mfrow=c(1,2))
pw = (1:4)[cut(a$perWater,breaks = c(0,2.5,5,10,25))]
plot(counties,col = viridis(4)[pw])
legend('topright',legend = c('0-2.5','2.5-5','5-10','10-25'),fill = viridis(4),bty='n')

pw = (1:7)[cut(localGvalues,breaks = c(-2,-1,0,1,2,3,4,5))]
plot(counties, col = viridis(7)[pw])
legend('topright',legend = c('less water','more water'), fill = viridis(7)[c(1,7)], bty='n')

