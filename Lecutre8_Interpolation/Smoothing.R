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
library(rgeos)


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


##########################################
Nearest neighbour interpolation
Here we do nearest neighbour interpolation considering multiple (5) neighbours.

We can use the gstat package for this. First we fit a model. ~1 means “intercept only”. In the case of spatial data, that would be only ‘x’ and ‘y’ coordinates are used. We set the maximum number of points to 5, and the “inverse distance power” idp to zero, such that all five neighbors are equally weighted

library(gstat)
formula	=  defines the dependent variable as a linear model of independent variables; suppose the dependent variable has name z, 
for ordinary and simple kriging use the formula z~1; for simple kriging also define beta (see below); 
for universal kriging, suppose z is linearly dependent on x and y, use the formula z~x+y
nmax = for local kriging: the number of nearest observations that should be used for a kriging prediction or simulation
idp = “inverse distance power” idp to zero, such that all five neighbors are equally weighted

gs10 <- gstat(formula=water~1, locations=countyPoly, nmax=10, set=list(idp = 0))
gs0 <- gstat(formula=water~1, locations=countyPoly, nmax=5, set=list(idp = 0))
gs1 <- gstat(formula=water~1, locations=countyPoly, nmax=5, set=list(idp = 1))
gs2 <- gstat(formula=water~1, locations=countyPoly, nmax=5, set=list(idp = 2)) 

# The weight, in early IDW methods, was inversely proportional to the squared distance. This theory, where the distance power is 2.
#Create raster to interpolate across
r <- raster(countyPoly, res=10000)

interpWater <- function(gstatValue){
  nn <- interpolate(r, gstatValue) ## inverse distance weighted interpolation
  nnmsk <- mask(nn, countyPoly)
  plot(nnmsk)
}
par(mfrow=c(2,2))
interpWater(gs10)
interpWater(gs0)
interpWater(gs1)
interpWater(gs2)

# Cross validate the result. Note that we can use the predict method to get predictions for the locations of the test points.

In its basic version, the so called k-fold cross-validation, the samples are randomly partitioned into k sets (called folds) of roughly equal size. 
A model is fit using all the samples except the first subset. 
Then, the prediction error of the fitted model is calculated using the first held-out samples. 
The same operation is repeated for each fold and the model’s performance is calculated by averaging the errors across the different test sets. 
kis usually fixed at 5 or 10 . Cross-validation provides an estimate of the test error for each model. 
Cross-validation is one of the most widely-used method for model selection, and for choosing tuning parameter values.

At this point, it is important to distinguish between different prediction error concepts:
  
the training error, which is the average loss over the training sample,
the test error, the prediction error over an independent test sample.


kf <- kfold(nrow(countyPoly), k = 5)
# k-fold partitioning of a data set for model testing purposes. 
# Each record in a matrix (or similar data structure) is randomly assigned to a group. Group numbers are between 1 and k.
rmsenn <- rep(NA, 5)
for (k in 1:5) {
  test <- countyPoly[kf == k, ]
  train <- countyPoly[kf != k, ]
  gscv <- gstat(formula=water~1, locations=train, nmax=5, set=list(idp = 0))
  p <- predict(gscv, test)$var1.pred
  rmsenn[k] <- RMSE(test$water, p)
}
rmsenn
mean(rmsenn)
1 - (mean(rmsenn) / null)
# 0.055
Often a “one-standard error” rule is used with cross-validation, 
according to which one should choose the most parsimonious model 
whose error is no more than one standard error above the error of the best model



#### proximity polygons
v <- voronoi(countyPts) #dismo package
# Create Voronoi polygons for a set of points. 
# (These are also known Thiessen polygons, and Nearest Neighbor polygons; 
# and the technique used is referred to as Delauny triangulation.)
plot(v)
v.wi <- intersect(v, wi) # crop to just wisconsin
plot(v.wi)

Can also ‘rasterize’ the results 

r <- raster(wi, res=5000)
vr <- rasterize(v.wi, r, 'water')
plot(vr)

Now evaluate with 5-fold cross validation.

kf <- kfold(nrow(countyPts))
rmse.v <- rep(NA, 5)
for (k in 1:5) {
  test <- countyPts[kf == k, ]
  train <- countyPts[kf != k, ]
  v <- voronoi(train)
  p <- raster::extract(v, test)
  rmse.v[k] <- RMSE(test$water, p$water)
}
rmse.v
## [1] 199.0686 187.8069 166.9153 191.0938 238.9696
mean(rmse.v)
## [1] 196.7708
1 - (mean(rmse.v) / null)
## [1] 0.5479875]

# Inverse distance weighted
A more commonly used method is “inverse distance weighted” interpolation. 
The only difference with the nearest neighbour approach is that pointns that are 
further away get less weight in predicting a value a location.

#Create raster to interpolate across
r <- raster(countyPoly, res=5000)
gs <- gstat(formula=water~1, locations=countyPts)
idw <- interpolate(r, gs)
idwr <- mask(idw, wi)
plot(idwr)


rmse.idw <- rep(NA, 5)
for (k in 1:5) {
  test <- countyPts[kf == k, ]
  train <- countyPts[kf != k, ]
  gs <- gstat(formula=water~1, locations=train)
  p <- predict(gs, test)
  rmse.idw[k] <- RMSE(test$water, p$var1.pred)
}

rmse.idw
mean(rmse.idw)
1 - (mean(rmse.idw) / null)


### Kriging
DW differs from Kriging in that no statistical models are used. 
There is no determination of spatial autocorrelation taken into consideration 
(that is to say how correlated variables are at varying distances is not determined). 
In IDW only known z values and distance weights are used to determine unknown areas.

IDW has the advantage that it is easy to define and therefore easy to understand the results. 
It may be inadvisable to use Kriging if you are unsure of how the results were arrived at. 
Kriging also suffers when there are outliers (see here for an explanation.).

Kriging is most appropriate when you know there is a spatially correlated distance or directional bias in the data. 
It is often used in soil science and geology.

Kriging is a statistical method that makes use of a variograms to calculate the spatial autocorrelation 
between points at graduated distances

t uses this calculation of spatial autocorrelation to determine the weights that should be applied at various distances.



library(gstat)
gs <- gstat(formula=forest~1, locations=countyPts)
v <- variogram(gs, width=20)
head(v)
plot(v)

The range parameter is given one third of the maximum value of object$dist. 
The nugget value is given the mean value of the first three values of object$gamma. 
The partial sill is given the mean of the last five values of object$gamma.
fve <- fit.variogram(v, vgm(NA, "Exp", NA, NA))
plot(v, fve)


gs <- gstat(formula=forest~1, locations=countyPts, model=fve)
k <- interpolate(r, gs)
k <- mask(k, wi)
plot(k)

# predicted values
kp <- predict(k, countyPts)
## [using ordinary kriging]
plot(kp)
kr = rasterize(kp,)
plot(kr$var1.pred)

rmse.k <- rep(NA, 5)
for (k in 1:5) {
  test <- countyPts[kf == k, ]
  train <- countyPts[kf != k, ]
  gs <- gstat(formula=forest~1, locations=train, model=fve)
  p <- predict(gs, test)
  rmse.k[k] <- RMSE(test$forest, p$var1.pred)
}

rmse.k
mean(rmse.idw)
1 - (mean(rmse.idw) / null)

kr = brick(kp)





