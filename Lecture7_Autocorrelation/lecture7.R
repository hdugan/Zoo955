# Example: http://rspatial.org/analysis/rst/3-spauto.html

perWater = read.csv('../Zoo955_WeeklyAssignments/Week6_WIwater_NLCD.csv',stringsAsFactors = F)#### Counties data ####
library(rgdal)
counties = readOGR('../Lecture6_Overlays/Data/County_Boundaries_24K/County_Boundaries_24K.shp',layer='County_Boundaries_24K')
# Add water to dataframe
counties$water = perWater$perWater
summary(counties)

# Plot counties
plot(counties)
# Get centroid coordinates and plot
xy <- coordinates(counties)
points(xy, cex=2, pch=20)



### Find adjacent polygons
# Neighbors will typically be created from a spatial polygon file. 
# Neighbors can be based on contiguity, distance, or the k nearest neighbors may be defined.

Determine which polygons are “near”, and how to quantify that. 
Here we’ll use adjacency as criterion. 
To find adjacent polygons, we can use package `spdep`

library(spdep)
# Construct neighbours list from polygon list
w <- poly2nb(counties, row.names= counties$OBJECTID)
class(w)
summary(w)

# Plot the links between the polygons
plot(counties)
plot(w, xy, col='red4', add=TRUE)

# An alternative method is to choose the k nearest points as neighbors
k = knearneigh(xy, k = 3)
k = knn2nb(k, row.names = counties$OBJECTID)
plot(counties, main='k nearest neighbors = 3')
plot(kk, xy, col='red4', add=TRUE)

# Or distance neighbors 
d =  dnearneigh(xy, d1 = 0, d2 = 50000, row.names = counties$OBJECTID)

plot(counties, main='neighbors, distance = 50km')
plot(d, xy, col='red4', add=TRUE)

# Transform w into a spatial weights matrix. 
# A spatial weights matrix reflects the intensity of the geographic relationship between observations

wm <- nb2mat(w, style='B')
wm

nb2mat(d, style='B')


# Compute Moran's I
# To do this we need to create a ‘listw’ type spatial weights object (instead of the matrix we used above). 
# To get the same value as above we use “style=’B’” to use binary (TRUE/FALSE) distance weights.

ww <-  nb2listw(w, style='B')
ww

dd <-  nb2listw(d, style='B', zero.policy = T)
print(dd, zero.policy=TRUE) 

kk <-  nb2listw(k, style='B')
kk
# Now we can use the moran function.
# I = (n sum_i sum_j w_ij (x_i - xbar) (x_j - xbar)) / (S0 sum_i (x_i - xbar)^2)

# x	 = a numeric vector the same length as the neighbours list in listw
# listw	= a listw object created for example by nb2listw
# n	= number of zones
# S0	= global sum of weights
moran(x = counties$water,listw = ww, n=length(ww$neighbours), S0=Szero(ww))
moran(x = counties$water,listw = rr, n=length(rr$neighbours), S0=Szero(rr))
moran(x = counties$water,listw = dd, n=length(dd$neighbours), S0=Szero(dd),zero.policy = T)

# Now we can test for significance. First analytically, using linear regression based logic and assumptions.

moran.test(counties$water, ww, randomisation=FALSE)

# Instead of the approach above you should use Monte Carlo simulation. 
# That is the preferred method (in fact, the only good method). 
# The way it works that the values are randomly assigned to the polygons, and the Moran’s I is computed. 
# This is repeated several times to establish a distribution of expected values. 
# The observed value of Moran’s I is then compared with the simulated distribution to see how likely 
# it is that the observed values could be considered a random draw.
moran.mc(counties$water, ww, nsim=99)

# null hypothesis states that the attribute being analyzed is randomly distributed among the features in your study area


