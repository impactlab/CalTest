****Verify match of weather files with stations


/*

Weather normalization requires we calculate  degree days for every weather station in california
Merge those degree days with the rest of the

*/

clear
set more off


**Define Files***

local cz2010_normals    = "/Users/matthewgee/Projects/CalTest/src/stata/cz2010_alldds_longlt.dta"
local weather_stations = "/Users/matthewgee/Projects/CalTest/data/weather/WeatherFileData.csv"
local dailytemps = "/Users/matthewgee/Projects/CalTest/data/weather/CalTrack_Complete_Temps.csv"


***Prepare raw temp files***
clear
insheet using `dailytemps'
rename wthrstationnum station_num
rename clizn climate_zone
split date, parse(" ") gen(date)
drop date date2
gen date = date(date1,"MD20Y")
rename date1 date_string
save caltest_dailytemps, replace
outsheet using caltest_daily_temps.csv, comma replace

**Prepare weather stations**
clear
insheet using `weather_stations', comma

rename clizn ca_climate_zone
split wthrfile, parse("_") gen(temp)
rename wthrfile station_id
rename wthrstationnum station_number
rename temp1 station_name
drop temp*
destring zipcode, replace force
destring ca_climate_zone, replace force

save caltest_weather_stations, replace
outsheet using caltest_station_id_lookup.csv, comma replace

***Prepare tempurature normals fron cz2010***
clear
use `cz2010_normals'

rename station_id station_number
rename station station_id

outsheet using caltest_normals_cz2010.csv, comma replace

***Prep full use files with zip + cz
*clear
*use cz2010_normals

