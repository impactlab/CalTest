*******************************
***Prep cleaned weather data***
*******************************

clear
set more off
set trace on

cd /Users/matthewgee/Projects/CalTest/data/weather/

*******************
****CalTest Files**
*******************
local caltest_homes = ""

*******************
***weather files***
*******************

local weatherDataOld = "/Users/matthewgee/Projects/CalTest/data/weather/cz2010_gsod_2006_2013.csv"
local weatherData = "/Users/matthewgee/Projects/CalTest/data/weather/CalTrack_Complete_Temps.csv"
local zipsandcz = ""
local weatherDataSave = "/Users/matthewgee/Projects/CalTest/data/weather/weather_data_prepped.csv"
local dd_start = "/Users/matthewgee/Projects/CalTest/data/weather/dd_combined_6065_start.csv"
local dd_end = "/Users/matthewgee/Projects/CalTest/data/weather/dd_combined_6065_end.csv"

tempfile dd_file

local hdd_base = 60
local cdd_base = 65

local hdd_base_low = 50
local hdd_base_high = 65

local cdd_base_low = 60
local cdd_base_high = 75

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

keep date clizn bill_start_date hdd_start cdd_start stationnum elevation wthrfile

*tempfile dd_start
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

keep date clizn bill_end_date hdd_end cdd_end stationnum elevation wthrfile

*tempfile dd_end
outsheet using `dd_end', comma replace


*************************************
*************************************
*****Create hdd range****************

forvalues basetemp = `hdd_base_low'/`hdd_base_high' {

	clear
	insheet using `weatherData', comma names
	merge m:1  usaf using `usaf2wthrfile'
	drop _merge

	******************************************
	*****Create cummulative measure of hdd****
	******************************************
	gen hdd = `basetemp' - temps 
	replace hdd=0 if hdd<0

	*gen cdd = temps - `cdd_base'
	*replace cdd=0 if cdd<0

	bysort usaf: gen cum_hdd=sum(hdd)
	*bysort usaf: gen cum_cdd=sum(cdd)

	gen station = wthrfile
	save `dd_file', replace
	
	*************************************
	*****Create hdd start/stop dataset*******
	
	use `dd_file'
	split date, parse(" ")
	drop date2
	replace date = date1
	drop date1

	*convert date
	cap drop bill_start_date
	cap drop bill_end_date
	gen bill_start_date = date(date, "MD20Y")
	gen bill_end_date = date(date, "MD20Y")
	
	gen hdd_start = cum_hdd 
	gen hdd_end = cum_hdd
	*gen cdd_start = cum_cdd 
	*gen cdd_end = cum_cdd

	rename wthrstationnum stationnum

	keep date clizn bill_start_date bill_end_date hdd_start hdd_end stationnum elevation wthrfile
	
outsheet using /Users/matthewgee/Projects/CalTest/data/weather/hdd_`basetemp'.csv, comma replace
	
}



*************************************
*****create cdd range****************


forvalues basetemp = `cdd_base_low'/`cdd_base_high' {

	clear
	insheet using `weatherData', comma names
	merge m:1  usaf using `usaf2wthrfile'
	drop _merge

	******************************************
	*****Create cummulative measure of hdd****
	******************************************
	*gen hdd = `basetemp' - temps 
	*replace hdd=0 if hdd<0

	gen cdd = temps - `basetemp'
	replace cdd=0 if cdd<0

	*bysort usaf: gen cum_hdd=sum(hdd)
	bysort usaf: gen cum_cdd=sum(cdd)

	gen station = wthrfile
	save `dd_file', replace
	
	*************************************
	*****Create hdd start/stop dataset*******
	
	use `dd_file'
	split date, parse(" ")
	drop date2
	replace date = date1
	drop date1

	*convert date
	cap drop bill_start_date
	cap drop bill_end_date
	gen bill_start_date = date(date, "MD20Y")
	gen bill_end_date = date(date, "MD20Y")
	
	*gen hdd_start = cum_hdd 
	*gen hdd_end = cum_hdd
	gen cdd_start = cum_cdd 
	gen cdd_end = cum_cdd

	rename wthrstationnum stationnum

	keep date clizn bill_start_date bill_end_date cdd_start cdd_end stationnum elevation wthrfile
	
outsheet using /Users/matthewgee/Projects/CalTest/data/weather/cdd_`basetemp'.csv, comma replace
	
}







