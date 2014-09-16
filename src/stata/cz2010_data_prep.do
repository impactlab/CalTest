*****Get CZ2010 climate normals data****

***Annual Heating Degree Days Data

local rawHDDann = "/Users/matthewgee/Projects/CalTest/data/weather/ann-htdd-base60.txt"
local rawCDDann = "/Users/matthewgee/Projects/CalTest/data/weather/ann-cldd-base70.txt"

*800-3310500


read

program define cz2010read

syntax filename(str) save(str)

*define cz2010 dict

dictionary using test2.raw {
   _column(1)     str10     stationid   %10s
   _column(19)     int      
   %4f
   _column(24)     str1     city   %1s
  }

infile using `filename' 
