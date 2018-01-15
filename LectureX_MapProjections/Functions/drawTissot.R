# How to use drawTissot function
library(maps) #load packages
library(mapproj) #load packages
# Plot world map of choice. Must specify projection and parameters
par(mar=c(0,0,0,0))
a = map('world',projection = 'mercator',parameters = NULL,
    wrap = T,orientation = c(90,0,0))
# Plot Tissot's indicatrix by specifing same projection and parameters
drawTissot('mercator',pars = NULL)

#### Function to draw Tissot circles based on projection ####
#### Hilary Dugan, 2017-02-04
drawTissot <- function(useProj,pars=NULL) {
  tissot <- function(long,lat,useProj,usePars=NULL) {
    ocentre <- c(long, lat)
    t=seq(0,2*pi,0.2)
    
    distance = cos((abs(lat))*pi/180) #distance between meridians with latitude 
    r=4 ## scale size of circles 
    xx=cos(t)*(r/distance)+ocentre[1]
    yy=sin(t)*(r)+ocentre[2]
    
    lines(mapproject(xx,yy,proj=useProj,orientation = c(90,0,0),parameters = usePars),
          col='red3')
  }
  
  out1 = seq(-180,180,by = 45)
  out2 = seq(-60,60,by=15)
  for (i in 1:9){
    for (j in 1:9){
      tissot(out1[i],out2[j],useProj = useProj,usePars=pars)
    }
  }
}


