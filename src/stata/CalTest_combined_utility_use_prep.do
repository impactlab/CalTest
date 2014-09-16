*Prepare scg data for inclusion in excel output

clear
set more off

local sdgeGas = "/Users/matthewgee/Projects/CalTest/data/sdge/final/sdge_gas_clean.csv"
local sdgeElec = "/Users/matthewgee/Projects/CalTest/data/sdge/final/sdge_elec_clean.csv"
local sceGas = "/Users/matthewgee/Projects/CalTest/data/final/sce_gas_prepped.csv"
local sceElec = "/Users/matthewgee/Projects/CalTest/data/final/sce_elec_prepped.csv"

tempfile pgegas
tempfile pgeelec
tempfile sdgegas
tempfile sdgeelec
tempfile scggas
tempfile scegas
tempfile sceelec

local combinedGas = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_gas_data.csv"
local combinedElec = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_elec_data.csv"


*****prep scg

*gas data

use "/Users/matthewgee/Projects/CalTest/data/scg/gas72_alluse_new.dta", clear

gen account_number = visionnumber

gen therms = use
gen iou = "SCG"

keep iou account_number date therms

outsheet using "/Users/matthewgee/Projects/CalTest/data/scg/final/scg_gas_clean.csv", comma replace


des, varlist
tostring `r(varlist)', replace force

save `scggas'


***********************
*****prep pge *********

*electric

use "/Users/matthewgee/Projects/CalTest/data/pgedata/elecuseclean_withdates.dta", clear

format date %tdnn/dd/yy

gen kwh = use
gen account_number = record
gen iou = "PGE"

keep iou account_number date kwh

format date %tdnn/dd/yy

outsheet using "/Users/matthewgee/Projects/CalTest/data/pgedata/final/pge_elec_clean.csv", comma replace

des, varlist
tostring `r(varlist)', replace force



save `pgeelec'


*gas

use "/Users/matthewgee/Projects/CalTest/data/pgedata/gasuseclean_withdates.dta", clear

format date %tdnn/dd/yy

gen therms = use
gen account_number = record

gen iou = "PGE"

keep iou account_number date therms
format date %tdnn/dd/yy

outsheet using "/Users/matthewgee/Projects/CalTest/data/pgedata/final/pge_gas_clean.csv", comma replace

des, varlist
tostring `r(varlist)', replace force


save `pgegas'


*sce gas
clear 
insheet using "`sceGas'", comma
gen iou = "SCE"
gen date =  bill_end_date
format date %tdnn/dd/yy
gen therms = tot_therms
gen account_number = visionnumber

des, varlist
tostring `r(varlist)', replace force


save `scegas'
*sce elec
clear 
insheet using "`sceElec'", comma
gen iou = "SCE"
gen date =  bill_end_date
format date %tdnn/dd/yy
gen kwh = tot_kwh
gen account_number = visionnumber
des, varlist
tostring `r(varlist)', replace force


save `sceelec'

*sdge gas
clear 
insheet using "`sdgeGas'", comma
gen iou = "SDGE"
replace date = subinstr(date,"/9","/09",.)
gen datetemp = date(date,"MD20Y") 
drop date
gen date = datetemp
drop datetemp
format date %tdnn/dd/yy

des, varlist
tostring `r(varlist)', replace force


save `sdgegas'

*sdge elec
clear 
insheet using "`sdgeElec'", comma
gen iou = "SDGE"
replace date = subinstr(date,"/9","/09",.)
replace date = subinstr(date,"/8","/08",.)
gen datetemp = date(date,"MD20Y") 
drop date
gen date = datetemp
drop datetemp
format date %tdnn/dd/yy
des, varlist
tostring `r(varlist)', replace force


save `sdgeelec'

***merge in accounts from selected file

***Greate combined gas file
append using `sceelec' `pgeelec'
keep iou account_number date kwh

destring date, replace
format date %tdnn/dd/yy

outsheet using `combinedElec', comma replace



****Generate Combined Gas
use `sdgegas', clear
append using `scggas' `pgegas' 

keep account_number date therms iou

destring date, replace
format date %tdnn/dd/yy

outsheet using `combinedGas', comma replace


