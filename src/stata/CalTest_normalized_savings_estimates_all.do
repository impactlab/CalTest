*********************************************
*****Realized savings estimation for the*****
*****           CalTest homes           *****
*****             Matt Gee              *****
*****            version 1.3            *****
*****            22, June 2014          *****
*********************************************


clear
set trace off
set more off

cd "/Users/matthewgee/Projects/CalTest/src/stata"

local dd_end = "/Users/matthewgee/Projects/CalTest/data/weather/dd_end_weather_data.csv"
local dd_start = "/Users/matthewgee/Projects/CalTest/data/weather/dd_start_weather_data.csv"
local lra_data = "/Users/matthewgee/Projects/CalTest/data/weather/cz2010_alldds_longlt.dta"
local stations = "caltest_weather_stations"
*need retrofit date for everyone
local project_data = "/Users/matthewgee/Projects/CalTest/data/selected/CalTest_screened_homes_account_info.csv"

local gas_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_gas_data.csv"
local elec_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_elec_data.csv"


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

clear
insheet using `project_data', comma
duplicates drop
*gen old_station = station_name
*drop station_name station_number
*drop old_station

merge m:m zipcode  using `stations', keep(match master)
drop _merge
gen station = station_name
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



merge m:m station_name bill_start_date using dd_start, force
keep if _merge==3
drop _merge

merge m:m station_name bill_end_date using dd_end
keep if _merge==3
drop _merge

gen hdd = hdd_end - hdd_start
gen cdd = cdd_end - cdd_start
gen hdd60pd = hdd/bill_length
gen cdd65pd = cdd/bill_length

**Create flag for pre-post**
gen retrofit_end_date_new = date(retrofit_end_date, "MDY")
gen pre = cond(date_num<retrofit_end_date_new,1,0)

**create input variables for PRISM**

drop date
gen date = bill_end_date
gen upd = kwh/bill_length
gen days = bill_length

save caltest_prism_run_elec, replace
outsheet using caltest_prism_run_elec.csv, comma replace

***do optional sanity checks on unnormalized magintudes**
*collapse (mean) upd, by(account_id pre)
*gen annual= upd*365.25

***Run Prism***
set trace off
keep if pre==1
prismxtf2, saving(elec_pre) by(account_id) th(0) tc(65)

foreach var of varlist nac base cvnac r2 nreads begdate enddate ltcdd sebs secpdd trefc cpdd senac senacc{
	rename `var' `var'_pre
	}
save elec_pre, replace


clear 
use caltest_prism_run_elec
keep if pre==0
prismxtf2, saving(elec_post) by(account_id) th(0) tc(65)

foreach var of varlist nac base  cvnac r2 nreads begdate enddate ltcdd sebs secpdd trefc cpdd senac senacc{
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

order account_id station_name nac_pre nac_post savings site_number

outsheet using caltest_elec_savings_all.csv, comma replace

save caltest_elec_savings_all, replace

********************************************************
****Calculate Weather Normalized Savings for Gas********
********************************************************

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

merge m:m station_name bill_start_date using dd_start, force
keep if _merge==3
drop _merge

merge m:m station_name bill_end_date using dd_end, force
keep if _merge==3
drop _merge

gen hdd = hdd_end - hdd_start
gen cdd = cdd_end - cdd_start
gen hdd60pd = hdd/bill_length
gen cdd65pd = cdd/bill_length

***Create flag for pre-post***
gen retrofit_end_date_new = date(retrofit_end_date, "MDY")
gen pre = cond(date_num<retrofit_end_date_new,1,0)

***create necessary inputs for PRISM***
drop date
gen date = bill_end_date
gen upd = therms/bill_length
gen days = bill_length

save caltest_prism_run_gas, replace
outsheet using caltest_prism_run_gas_all.csv, comma replace

*collapse (mean) upd, by(account_id pre)
*gen annual= upd*365.25

***Run PRISM***

set trace off
keep if pre==1
prismxtf2 , saving(gas_pre) by(account_id) th(60) tc(0)

foreach var of varlist nac base nahc cvnac r2 nreads begdate enddate lthdd sebs sehpdd hpdd tref senac senahc{
	rename `var' `var'_pre
	}
save gas_pre, replace


clear 
use caltest_prism_run_gas
keep if pre==0
prismxtf2, saving(gas_post) by(account_id) th(60) tc(0)

foreach var of varlist nac base nahc cvnac r2 nreads begdate enddate lthdd sebs sehpdd hpdd tref senac senahc{
	rename `var' `var'_post
	}
save gas_post, replace

merge 1:1 account_id using gas_pre
gen savings = nac_pre - nac_post

cap drop _merge
*keep account_id nac_pre nac_post savings

merge 1:1 account_id using project_data


sort site_number

order account_id station nac_pre nac_post savings site_number

outsheet using caltest_gas_savings_all.csv, comma replace

save caltest_gas_savings_all, replace


****End*****




