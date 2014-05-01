*******************************
***Prep cleaned weather data***
*******************************

clear
set more off
set trace off


*******************
***weather files***
*******************

local weatherDataOld = "/Users/matthewgee/Projects/CalTest/data/weather/cz2010_gsod_2006_2013.csv"
local weatherData = "/Users/matthewgee/Projects/CalTest/data/weather/CalTrack_Complete_Temps.csv"
local zipsandcz = ""
local weatherDataSave = "/Users/matthewgee/Projects/CalTest/data/weather/weather_data_prepped.csv"
local dd_start = "/Users/matthewgee/Projects/CalTest/data/weather/dd_start_weather_data.csv"
local dd_end = "/Users/matthewgee/Projects/CalTest/data/weather/dd_end_weather_data.csv"

local hdd_base = 70
local cdd_base = 74
****************************
****Load Data and Reformat**
****************************
clear
insheet using `weatherDataOld', comma names
duplicates drop usaf, force
keep usaf wthrfile

tempfile usaf2wthrfile
save `usaf2wthrfile', replace


clear
insheet using `weatherData', comma names
merge m:1  usaf using `usaf2wthrfile'
drop _merge

******************************************
*****Create cummulative measure of hdd****
******************************************
gen hdd = `hdd_base' - temps 
replace hdd=0 if hdd<0

gen cdd = temps - `cdd_base'
replace cdd=0 if cdd<0

bysort usaf: gen cum_hdd=sum(hdd)
bysort usaf: gen cum_cdd=sum(cdd)

gen station = wthrfile
******************************************
********Save File   **********************
******************************************

outsheet using `weatherDataSave', comma replace

****************************

clear
insheet using `weatherDataSave', comma names
split date, parse(" ")
drop date2
replace date = date1
drop date1

*convert date
cap drop bill_start_date
gen bill_start_date = date(date, "MD20Y")

rename cum_hdd hdd_start
rename cum_cdd cdd_start 

rename wthrstationnum stationnum

keep bill_start_date hdd_start cdd_start stationnum elevation wthrfile

tempfile dd_start
outsheet using `dd_start', comma replace

clear
insheet using `weatherDataSave', comma names
split date, parse(" ")
drop date2
replace date = date1
drop date1

*convert date
cap drop bill_start_date
gen bill_end_date = date(date, "MD20Y")

rename cum_hdd hdd_end
rename cum_cdd cdd_end

rename wthrstationnum stationnum

keep bill_end_date hdd_end cdd_end stationnum elevation wthrfile

tempfile dd_end
outsheet using `dd_end', comma replace




