sample.Polygon = function(x, n, type = "random", bb = bbox(x),
                          offset = runif(2), proj4string=CRS(as.character(NA)), iter=4, ...) {
  if (missing(n)) n <- as.integer(NA)
  #cat("n in sample.Polygon", n, "\n")
  area = area(x)
  if (area == 0.0)
    spsample(Line(slot(x, "coords")), 
             n, type, offset = offset[1], proj4string=proj4string)
  #CRS(proj4string(x))), n, type, offset = offset[1])
  else {
    res <- NULL
    its <- 0
    n_now <- 0
    bb.area = prod(apply(bb, 1, function(x) diff(range(x))))
    bb.area <- bb.area + bb.area*its*0.1
    xSP <- new("Spatial", bbox=bbox(x), proj4string=proj4string)
    if (type == "random") {
      brks <- c(1,3,6,10,20,100)
      reps <- c(5,4,3,2,1.5)
      n_is <- round(n * reps[findInterval(n,
                                          brks, all.inside=TRUE)] * bb.area/area)
    } else n_is <- round(n * bb.area/area)
    while (is.null(res) && its < iter && n_is > 0 && 
           ifelse(type == "random", (n_now < n), TRUE)) {
      pts = sample.Spatial(xSP, n_is, type=type, 
                           offset = offset, ...)
      id = over(pts, SpatialPolygons(list(Polygons(list(x),
                                                   "xx")), proj4string=proj4string))
      Not_NAs <- !is.na(id)
      if (!any(Not_NAs)) res <- NULL
      else res <- pts[which(Not_NAs)]
      if (!is.null(res)) n_now <- nrow(res@coords)
      its <- its+1
    }
    if (type == "random")
      if (!is.null(res) && n < nrow(res@coords)) 
        res <- res[sample(nrow(res@coords), n)]
    res
  }
}