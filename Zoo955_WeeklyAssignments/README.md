# Zoo955 Homework Assignments 
## Email all assignments as pdf documents by Monday at 8am. 

WEEK 1: Make a r markdown pdf. Contents can be whatever you want! 
 
WEEK 2: 
1) Download the LTER lake shapefiles from the LTER database. Map Lake Mendota. Add a point for the location of the CFL. (Keep these files, we'll use them in future classes)

2) Download the National Land Cover (NLCD) dataset for 2011. Load it into R. What is the CRS? (Keep this data, we'll use it in future classes)

3) What's the best way to check that CRS of two objects are identical? 

WEEK 3:
1) Define 7 of these using simple language (1 sentence if possible): `st_intersects`, `st_disjoint`, `st_touches`,`st_crosses`, `st_within`, `st_contains`, `st_overlaps`,
`st_equals`, `st_covers`, `st_covered_by`, `st_equals_exact` and
`st_is_within_distance`,`st_buffer`, `st_boundary`, `st_convexhull`,
`st_union_cascaded`, `st_simplify`, `st_triangulate`,
`st_polygonize`, `st_centroid`, `st_segmentize`, and `st_union`

Preferably choose ones that you don't already know. 

2) Make a 500 m buffer of the 4 southern LTER lakes. Which buffers overlap? 

3) [This question is considerably more difficult. Try your best, but don't spend more than 30 minutes on this.] Increase the size of the lakes by 2x. What is the percent of Mendota that overlaps with Monona? 

WEEK 4:

Using the NLCD data from the Mendota watershed:
1) What is the percent of forest in the Mendota catchment? 
2) What is the area of forest in the Mendota catchment (report in km2)? 

WEEK 5:

Use the 'Data/WI_CAVG_LatLong1.nc' file. In this lecture we dealt with the "temperature" variable. This file is the "climatology" variable. 

Find the metadata for these dataset. http://berkeleyearth.org/data/. We are using *Gridded Data*. *Monthly Land. Average Temperature (TAVG; 1753 – Recent)*. 

1) The climatology variable is a monthly average for each cell. What years does this average represent? 

2) Plot the August averages for Wisconsin. 

3) Extract the averages for the cell over Lake Mendota. Plot the monthly temperature averages. 

4) What is the August average for Lake Mendota? 