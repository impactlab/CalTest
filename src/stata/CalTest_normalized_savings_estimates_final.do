*********************************************
*****Realized savings estimation for the*****
*****           CalTest homes           *****
*****             Matt Gee              *****
*****            version 1.4            *****
*****            29, July 2014          *****
*********************************************


clear
set trace of
set more off

cd "/Users/matthewgee/Projects/CalTest/src/stata"

***specify new datasets
local dd_end = "/Users/matthewgee/Projects/CalTest/data/weather/dd_end_weather_data.csv"
local dd_start = "/Users/matthewgee/Projects/CalTest/data/weather/dd_start_weather_data.csv"

*local hdd_start 
*local hdd_end
*local cdd_start

local lra_data = "/Users/matthewgee/Projects/CalTest/data/weather/cz2010_alldds_longlt.dta"
local stations = "caltest_weather_stations"
*need retrofit date for everyone
*local project_data = "/Users/matthewgee/Projects/CalTest/data/selected/CalTest_screened_homes_account_info.csv"

local project_data = "/Users/matthewgee/Projects/CalTest/data/caltest/caltest_project_info_updated_final.csv"


local gas_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_gas_data.csv"
local elec_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_elec_data-updated.csv"

local results_init = "/Users/matthewgee/Projects/CalTest/data/caltest/caltest_results_init.csv"

*local gas_results_init = ""

***set ranges***

local hdd_base = 60
local cdd_base = 65

local hdd_base_low = 45
local hdd_base_high = 65

local cdd_base_low = 55
local cdd_base_high = 75


*****************************
******Raw data preparation***
*****************************


use `lra_data' 
replace station = upper(station)
rename station station_id
split station_id, parse("_") gen(d)
rename d1  station
rename d2  station_number
save cz2010_alldds_longlt, replace

clear
insheet using `dd_start', comma
rename wthrfile station_name
gen date_merge = date(date, "MD20Y")
save dd_start, replace

clear
insheet using `dd_end', comma
rename wthrfile station_name
gen date_merge = date(date, "MD20Y")
save dd_end, replace

cd "/Users/matthewgee/Projects/CalTest/data/weather/"

forvalues basetemp = `cdd_base_low'/`cdd_base_high' {
	clear 
	insheet using cdd_`basetemp'.csv, comma
	rename wthrfile station_name
	gen date_merge = date(date, "MD20Y")
	save cdd_`basetemp', replace
}


forvalues basetemp = `hdd_base_low'/`hdd_base_high' {
	clear 
	insheet using hdd_`basetemp'.csv, comma
	rename wthrfile station_name
	gen date_merge = date(date, "MD20Y")
	save hdd_`basetemp', replace
}

cd "/Users/matthewgee/Projects/CalTest/src/stata"

clear
insheet using `project_data', comma
duplicates drop
*gen old_station = station_name
*drop station_name station_number
*drop old_station

merge m:m zipcode  using `stations', keep(match master)
drop _merge
*gen station = station_name
duplicates drop account_id, force
drop if isvalid~=1

save project_data, replace

clear
insheet using `gas_data', comma
*have to fix date var to be standard

save gas_data, replace

clear
insheet using `elec_data', comma
*have to fix datevar to be standard
replace date = subinstr(date,"/9","/09",.)
replace date = subinstr(date,"/8","/08",.)

save elec_data, replace



******************************************************
******Weather Normalized Savings for Electricity******
******************************************************
*clear
*insheet using `results_init', comma names
*save caltest_elec_savings_all_degreedays, replace

forvalues basetemp = `cdd_base_low'/`cdd_base_high' {

	**for now we are leaving out the combined model

	use elec_data, clear
	rename account_number account_id 

	gen date_num = date(date, "MD20Y")
	*gen date_num = date
	sort account_id date_num
	bysort account_id: gen bill_start_date = date_num[_n-1]+1
	gen bill_end_date = date_num
	gen bill_length = bill_end_date - bill_start_date

	merge m:1 account_id using project_data
	keep if _merge==3
	drop _merge


	****get start and end cdd****

	merge m:m station_name bill_start_date using /Users/matthewgee/Projects/CalTest/data/weather/cdd_`basetemp'.dta, keepusing(cdd_start) force
	keep if _merge==3
	drop _merge

	merge m:m station_name bill_end_date using /Users/matthewgee/Projects/CalTest/data/weather/cdd_`basetemp'.dta, keepusing(cdd_end) force
	keep if _merge==3
	drop _merge

	*gen hdd = hdd_end - hdd_start
	gen cdd = cdd_end - cdd_start
	*gen hdd60pd = hdd/bill_length
	gen cdd`basetemp'pd = cdd/bill_length

	**Create flag for pre-post**
	gen retrofit_start_date_new = date(retrofit_start_date, "MD20Y")
	gen pre = cond(date_num<retrofit_start_date_new,1,0)
	
	gen retrofit_end_date_new = date(retrofit_end_date, "MD20Y")
	gen post = cond(date_num>retrofit_end_date_new,1,0)
	
	tab pre
	tab post
	
	**create input variables for PRISM**

	drop date
	gen date = bill_end_date
	gen upd = kwh/bill_length
	gen days = bill_length

	save caltest_prism_run_elec, replace
*	outsheet using caltest_prism_run_elec.csv, comma replace

	***do optional sanity checks on unnormalized magintudes**
	*collapse (mean) upd, by(account_id pre)
	*gen annual= upd*365.25

	***Run Prism***
	*set trace off
	keep if pre==1
	
	prismxtf2, saving(elec_pre) by(account_id) th(0) tc(`basetemp')

	foreach var of varlist nac base cvnac r2 nreads begdate enddate ltcdd sebs secpdd trefc cpdd senac senacc{
		rename `var' `var'_pre
		}
	save elec_pre, replace


	clear 
	use caltest_prism_run_elec
	keep if post==1
	prismxtf2, saving(elec_post) by(account_id) th(0) tc(`basetemp')

	foreach var of varlist nac base cvnac r2 nreads begdate enddate ltcdd sebs secpdd trefc cpdd senac senacc{
		rename `var' `var'_post
		}
		
	save elec_post, replace
	cap drop _merge

	merge 1:1 account_id using elec_pre
	gen savings = nac_pre - nac_post
	cap drop _merge
	*keep account_id nac_pre nac_post savings

	merge 1:1 account_id using project_data
	cap drop _merge
	sort site_number
	
	gen basetemp = `basetemp'

	order account_id station_name basetemp nac_pre nac_post savings site_number

	save "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_elec_savings_cdd_`basetemp'.dta", replace
	****append to previous dataset

	*append using caltest_elec_savings_all_degreedays

}
*end electricity loop 
clear
use "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_elec_savings_cdd_`cdd_base_low'.dta"
*append results
local start = `cdd_base_low'+1
forvalues basetemp = `start'/`cdd_base_high' {

append using "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_elec_savings_cdd_`basetemp'.dta"

}

**run cleaning script**

save caltest_elec_savings_all, replace

outsheet using caltest_elec_savings_all.csv, comma replace

********************************************************
****Calculate Weather Normalized Savings for Gas********
********************************************************

*initialized empty dataset
*clear
*insheet using `results_init', comma
*save caltest_gas_savings_all_degreedays, replace


forvalues basetemp = `hdd_base_low'/`hdd_base_high' {

	use gas_data, clear
	rename account_number account_id 

	*gen date_num = date(date, "MD20Y")
	gen date_num = date
	sort account_id date_num
	bysort account_id: gen bill_start_date = date_num[_n-1]+1
	gen bill_end_date = date_num
	gen bill_length = bill_end_date - bill_start_date

	merge m:1 account_id using project_data
	keep if _merge==3
	drop _merge

	merge m:m station_name bill_start_date using /Users/matthewgee/Projects/CalTest/data/weather/hdd_`basetemp'.dta, keepusing(hdd_start) force
	keep if _merge==3
	drop _merge

	merge m:m station_name bill_end_date using /Users/matthewgee/Projects/CalTest/data/weather/hdd_`basetemp'.dta, keepusing(hdd_end) force
	keep if _merge==3
	drop _merge

	gen hdd = hdd_end - hdd_start
	*gen cdd = cdd_end - cdd_start
	
	gen hdd`basetemp'pd = hdd/bill_length
	*gen cdd65pd = cdd/bill_length

	**Create flag for pre-post**
	gen retrofit_start_date_new = date(retrofit_start_date, "MD20Y")
	gen pre = cond(date_num<retrofit_start_date_new,1,0)

	gen retrofit_end_date_new = date(retrofit_end_date, "MD20Y")
	gen post = cond(date_num>retrofit_end_date_new,1,0)

	***create necessary inputs for PRISM***
	drop date
	gen date = bill_end_date
	gen upd = therms/bill_length
	gen days = bill_length

	save caltest_prism_run_gas, replace
	outsheet using caltest_prism_run_gas_`basetemp'.csv, comma replace

	*collapse (mean) upd, by(account_id pre)
	*gen annual= upd*365.25

	***Run PRISM***

	set trace off
	keep if pre==1
	prismxtf2 , saving(gas_pre) by(account_id) th(`basetemp') tc(0)

	foreach var of varlist nac base nahc cvnac r2 nreads begdate enddate lthdd sebs sehpdd hpdd tref senac senahc{
		rename `var' `var'_pre
		}
	save gas_pre, replace


	clear 
	use caltest_prism_run_gas
	keep if pre==0
	
	prismxtf2, saving(gas_post) by(account_id) th(`basetemp') tc(0)

	foreach var of varlist nac base nahc cvnac r2 nreads begdate enddate lthdd sebs sehpdd hpdd tref senac senahc{
		rename `var' `var'_post
		}
	save gas_post, replace

	merge 1:1 account_id using gas_pre
	gen savings = nac_pre - nac_post

	cap drop _merge
	*keep account_id nac_pre nac_post savings

	merge 1:1 account_id using project_data
	cap drop _merge
	sort site_number

	gen basetemp = `basetemp'
	
	order account_id  station basetemp nac_pre nac_post savings site_number

	save "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_gas_savings_hdd_`basetemp'.dta", replace
	
	*append using caltest_gas_savings_all_degreedays
}
*end gas loop over degree days

*
clear
use "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_gas_savings_hdd_`hdd_base_low'.dta"
local start = `hdd_base_low' + 1
forvalues basetemp = `start'/`hdd_base_high' {

append using "/Users/matthewgee/Projects/CalTest/src/stata/results/caltest_gas_savings_hdd_`basetemp'.dta"

}

******************************
*****run selection script*****
******************************

save caltest_gas_savings_all, replace

outsheet using caltest_gas_savings_all.csv, comma replace
****End*****




