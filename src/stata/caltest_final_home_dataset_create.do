******Create final combined datasets with the correct***

/*
1. Run weatherDataPrep to create hdd and cdd files for multiple base temps
2. 
*/



clear

local cz2010_normals    = "/Users/matthewgee/Projects/CalTest/src/stata/cz2010_alldds_longlt.dta"
local weather_stations = "/Users/matthewgee/Projects/CalTest/data/weather/WeatherFileData.csv"
local dailytemps = "/Users/matthewgee/Projects/CalTest/data/weather/CalTrack_Complete_Temps.csv"

local elec_data ""
local gas_data ""

local elec_data_caltest = ""
local gas_data_caltest = ""

***create subset weather file with only the stations we need
*merge the station ids with the 

***generate hdd and cdd files for each base temp

***create subsets of energy use data***
