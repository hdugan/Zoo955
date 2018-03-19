https://phys.org/news/2018-01-north-american-waterways-saltier-alkaline.html

####### STATE MAP #######
library(maps)
library(mapStats)
library(rgeos)
library(rgdal)

usMap <- readOGR(system.file("shapes/usMap.shp", package="mapStats")[1],layer='usMap',stringsAsFactors = F)
state = c('WI','MN')
stMap = usMap[usMap@data$STATE_ABBR==state,]
stMap.ll = spTransform(stMap,CRS("+init=epsg:3070"))
stMap.ll = stMap.ll[,1]

## LOAD DATA ##
clWI = readOGR('Data/WIchloride.shp',layer = 'WIchloride')
clMN = readOGR('Data/MNchloride.shp',layer = 'MNchloride')
cl <- rbind(clWI,clMN)  
cl = spTransform(cl,CRS("+init=epsg:3070"))

plot(cl)
clBin <- cut(cl$Chlorid, breaks = c(0,1,10,100,1000,30000), labels = 1:5)
colBin = viridis(6,alpha = 0.8)[clBin]

par(mar=c(0,0,0.5,0.5))
plot(stMap.ll)
plot(cl,pch=16,col=colBin,add=T,cex=0.9)
legend('topright',fill =  viridis(5,alpha = 0.8),legend = c('0-1','1-10',
       '10-100','100-1,000','1,000-30,000'),
       title = 'Chloride (mg/L)',cex=0.6)
