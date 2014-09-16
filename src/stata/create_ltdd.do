*get the station numbers from the homes in the selected pool

clear
set more off
cd "/Users/matthewgee/Projects/CalTest/src/stata"

local weatherData = "/Users/matthewgee/Projects/CalTest/data/weather/CalTrack_Complete_Temps.csv"
local weather_lookup = "/Users/matthewgee/Projects/CalTest/data/weather/weather_data_prepped.csv"
local saving "alldd_longlt2.dta"

***
insheet using `weatherData', comma
save complete_weather_data, replace

*create alldd_longlt2.dta dataset

	use complete_weather_data, replace
	local temp = 40
	gen station = usaf
	gen tref = `temp'
	gen hdd = `temp' - temps
	replace hdd=0 if hdd<0
	gen cdd = temps - `temp'
	replace cdd=0 if cdd<0
	collapse (first) tref (mean) lthdd=hdd ltcdd = cdd, by(station)
	*gen lthdd = hddavg/365.25
	*gen ltcdd = cddavg/365.25

	save alldds_longlt2, replace
	
forval temp = 41(1)80{
	use complete_weather_data, replace	
	gen station = usaf
	di `temp'
	gen tref = `temp'
	gen hdd = `temp' - temps
	replace hdd=0 if hdd<0
	gen cdd = temps - `temp'
	replace cdd=0 if cdd<0
	collapse (first) tref (mean) lthdd=hdd ltcdd = cdd, by(station)
	*gen lthdd = hddavg/365.25
	*gen ltcdd = cddavg/365.25
	
	append using alldds_longlt2
	save alldds_longlt2, replace

}

gen usaf = station
drop station

save alldds_longlt2, replace

*Add in station names
clear 

insheet using `weather_lookup', comma


collapse (first) wthrstationnum	clizn lat lon	elevation wthrfile station (mean) temps, by(usaf)
save weather_lookup, replace

clear
use alldds_longlt2

merge m:1 usaf using weather_lookup

keep if _merge==3

order station tref lthdd ltcdd

sort station tref

save alldds_longlt2, replace

