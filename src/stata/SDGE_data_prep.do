********************************
**** SDGE Data Prep ************
********************************
clear
set more off

*******Directories and Files****

local saveDIR = "/Users/matthewgee/Projects/CalTest/data/sdge/final/"
local dataDIR = "/Users/matthewgee/Projects/CalTest/data/sdge/"
local xmlDIR = "/Users/matthewgee/Projects/CalTest/data/sdge/SDGE EPro files/XML/"

***Define Input Datasets***

local xmlSavingsData = "xmlpreuse.dta"
local xmlProjectData = "sdge_combined_XML_values.csv"
local rawProjectData = "sdge_track1.dta"
local rawProjectData2 = "sdge_track2.dta"
local measureData = "All_job_data_9-23-13.xlsx"
local contractorData = "SDGEPreferredContractorList.csv"
local linkData = "SDG&E CalTEST home data April2014.csv"
local rawGasData = "sdge wo46 gas bills.csv"
local rawElecData = "sdge wo46 elec bills.csv"
local sdgeData = "sdge_combined_data"

local weatherData = "/Users/matthewgee/Projects/CalTest/data/weather/weather_data_prepped.csv"

***Define Intermediate Datasets
tempfile projectData
tempfile measureData
tempfile gasData
tempfile elecData
*tempfile weatherData

**Name output datasets***
local finalProjectData = "`saveDIR'sdge_project_data_prepped.csv"
local finalGasData = "`saveDIR'sdge_gas_prepped.csv"
local finalElecData = "`saveDIR'sdge_elec_prepped.csv"

***Authoritative dataset***
local finalData = "/Users/matthewgee/Projects/CalTest/data/final/sdge_CalTest_data_prepped.csv"


cd `dataDIR'


***Begin by prepping bill data to standard format
/*

I. Prep Project Data

A. Collapse by measure and create unique obs per home
B. merge with XML
C. Merge with IDVas

II. Prep Usage Data

A. Prep Gas Data
gas data:
(bill_start_date)
(bill_end_date)
bill_date = bill_end_date
bill_period_len
tot_therms
avg_daily_therms
(net_metering)

B. Prep Elec Data
gas data:
(bill_start_date)
(bill_end_date)
bill_date = bill_end_date
bill_period_len
tot_therms
avg_daily_therms
(net_metering)

C. Prep Weather Data

D. Normalize

E. Create Mesure of Relized Savings

F. Merge Realized savings with project data

III. 


*/



******************************************************************
******  Get Predicted Savings Data from XML and Merge ************
******************************************************************
use `xmlSavingsData', clear
cap drop predicted_savings_gas predicted_savings_elec
gen predicted_savings_gas = gastot0 - gastot1
gen predicted_savings_elec = electot0 - electot1
keep file predicted_savings_gas predicted_savings_elec

tempfile predictedSavings
save `predictedSavings', replace

************************************************
****** Get Measure Data   **********************
************************************************
*Uniique identifier: iouprojectid
use `rawProjectData', clear

sort iouprojectid 



#delimit;
collapse 
	(first) 
		iouinstallationdate 
		ioucontractorname 
		ioue3climatezone 
		iouprojectdescription 
		iousiteid 
		bldgtype 
		bldgloc
		bldghvac
		edfilledclimatezone
		edfilledpaiddate
		edfilledzipcode
		edprgid
		iousiteaddress
		iousitecity
		iousitecontactname
		iousitestate
		iousitezipcode
	(sum)
		edfilledexantesavkw	
		edfilledexantesavtherms	
		grosssavkwh	
		grosssavkw	
		grosssavtherms
		
	(mean)
		iourealizationrate_kw
		iourealizationrate_kwh
		iourealizationrate_therm

		
		,
		by(iouprojectid)
		;
#delimit cr

*prep for merge
gen projectid = iouprojectid
		
save `projectData', replace

******************************************************
****consider collapsing by measure to get hvac, etc***


*get climate data from prepped file

use `rawProjectData2', clear

#delimit;
collapse 
	(first) 
		serviceaccountid
		installationdate
		cz
		zipcode
		wthrfile
		stationnum
		,
		by(projectid)
		;
#delimit cr
tempfile climateData
save `climateData', replace

merge 1:1 projectid using `projectData'

drop _merge

**prepare for merge
gen buildingid = upper(iouprojectdescription)
gen buildingaddress = upper(iousiteaddress)

**save as tempfile**
save `projectData', replace

**************************
**Now merge in XML files**
**************************
clear
insheet using `xmlProjectData', comma names
drop v1
drop if buildingaddress=="" | buildingid==""

replace buildingid = upper(buildingid)
replace buildingaddress = upper(buildingaddress)

merge m:1 buildingaddress using `projectData'
tab _merge
keep if _merge==3







**save as tempfile**
save `projectData', replace


****Outsheet as CSV******

outsheet using `finalProjectData', comma replace

****************************
******Do mass renaming******
****************************









****************************************************
****Create file for the value of the merge date ****
****************************************************

use `projectData', clear
keep iouinstallationdate projectid serviceaccountid cazone conditionedfloorarea winteridb summeridb wthrfile stationnum

*gen bill_start_date = iouinstallationdate
gen account_number = serviceaccountid 
destring account_number, replace force
format account_number %14.0g
*merge on one of these
*customer_number premise_number account_number
drop if account_number==.
duplicates drop account_number, force

tempfile installdate
save `installdate', replace



**************************************************
****Prepare weather data for savings calculation**
**************************************************

****Prepare Gas*****

clear
insheet using "`rawGasData'", comma names

*rename vars
rename meter_read_start_date bill_start_date
rename meter_read_end_date bill_end_date


foreach var in bill_start_date bill_end_date {
	gen tempvar = date(`var',"20YMD")
	drop `var'
	gen `var'= tempvar
	drop tempvar
	}


gen bill_date = bill_end_date
rename number_of_days_used bill_period_length
rename usage tot_therms
gen avg_daily_therms = tot_therms / bill_period_length



save `gasData', replace

**merge in id vars**
clear
insheet using "`linkData'", names comma

merge 1:m dnvgl_acct_id using `gasData'
format account_number %14.0g
cap drop _merge
merge m:1 account_number using `installdate'

tab _merge

keep if _merge==3

drop _merge
***********Generate phase dummy***

gen phase = cond(iouinstallationdate <= bill_start_date,1,0,.)
gen station = wthrfile

save `gasData', replace


****Prepare Elec*****

clear
insheet using "`rawElecData'", comma names

*rename vars
rename meter_read_start_date bill_start_date
rename meter_read_end_date bill_end_date


foreach var in bill_start_date bill_end_date {
	gen tempvar = date(`var',"20YMD")
	drop `var'
	gen `var'= tempvar
	drop tempvar
	}

gen bill_date = bill_end_date
rename number_of_days_used bill_period_length
rename usage tot_kwh
gen avg_daily_kwh = tot_kwh / bill_period_length

save `elecData', replace

**merge in id vars**
clear
insheet using "`linkData'", names comma
cap drop _merge
merge 1:m dnvgl_acct_id using `elecData'

format account_number %14.0g
**
cap drop _merge
merge m:1 account_number using `installdate'
tab _merge

keep if _merge==3

drop _merge


***create pre-post var
gen phase = cond(iouinstallationdate <= bill_start_date,1,0,.)
gen station = wthrfile

**Create avg energy intentsity vars**
*save for after normalization

save `elecData', replace

******************************************
****** Calculate Savings  ****************
******************************************
clear
insheet using `weatherData', comma names
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
save `dd_start', replace

clear
insheet using `weatherData', comma names
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
save `dd_end', replace

*******************************
*merge in hdd by station + date
*****************************
clear
use `gasData'

merge m:1 stationnum bill_start_date using `dd_start'
keep if _merge==3
drop _merge

merge m:1 stationnum bill_end_date using `dd_end'
keep if _merge==3
drop _merge

****create cdd and hdd per day vars
gen days = bill_period_length
gen upd = avg_daily_therms

gen hdd70 = hdd_end - hdd_start
gen hdd70pd = hdd70/days

gen cdd74 = cdd_end - cdd_start
gen cdd74pd = cdd74/days 
************************************

save `gasData', replace

clear
use  `elecData'

merge m:1 stationnum bill_start_date using `dd_start'
keep if _merge==3
drop _merge

merge m:1 stationnum bill_end_date using `dd_end'
keep if _merge==3
drop _merge


****create cdd and hdd per day vars
gen days = bill_period_length
gen upd = avg_daily_kwh

gen hdd70 = hdd_end - hdd_start
gen hdd70pd = hdd70/days

gen cdd74 = cdd_end - cdd_start
gen cdd74pd = cdd74/days 
************************************


save `elecData', replace


***********************************************
*********weather normalization*****************
***********************************************

use `gasData', clear
tempfile temp1
adopath ++ "/Users/matthewgee/Projects/CalTest/src/stata"
discard
normsimp, saving(`temp1') by(account_number) th(70) tc(74)
save `gasData', replace

******************************************************
*****Construct balanced before and after phase panel

*****************************************************
use `elecData', clear
tempfile temp1
adopath ++ "/Users/matthewgee/Projects/CalTest/src/stata"
discard
normsimp, saving(`temp1') by(account_number) th(70) tc(74)
save `elecData', replace

******************************************************
*****Construct balanced before and after phase panel
use `gasData', clear

compare_periods, idvar("account_number") datevar("bill_start_date") usevar("avg_daily_therms") util("gas") minlength(12)


#delimit;
collapse (count) test_period_length=zip (first) conditionedfloorarea summeridb winteridb zip 
			iousiteaddress iousitecity dnvgl_acct_id customer_number projectid 
			serviceaccountid wthrfile stationnum iouinstallationdate station elevation r2 
		(mean) upd avg_daily_therms use_norm use_phase0 use_phase1
		, by(account_number);
#delimit cr

keep if test_period_length>=24
gen energy_intensity_gas = use_norm / conditionedfloorarea
gen gas_realized_savings = (use_phase0 - use_phase1)/use_phase0



outsheet using `finalGasData', comma replace

keep account_number test_period_length test_period_length dnvgl_acct_id customer_number projectid serviceaccountid wthrfile stationnum r2 avg_daily_therms energy_intensity_gas gas_realized_savings elevation

save `gasData', replace

******************************************************
*****Construct balanced before and after phase panel
use `elecData', clear

compare_periods, idvar("account_number") datevar("bill_start_date") usevar("avg_daily_kwh") util("gas") minlength(12)


#delimit;
collapse (count) test_period_length=zip (first) conditionedfloorarea summeridb winteridb zip 
			iousiteaddress iousitecity dnvgl_acct_id customer_number projectid 
			serviceaccountid wthrfile stationnum iouinstallationdate station elevation r2 
		(mean) upd avg_daily_kwh use_norm use_phase0 use_phase1
		, by(account_number);
#delimit cr

keep if test_period_length>=24
gen energy_intensity_elec = use_norm / conditionedfloorarea
gen elec_realized_savings = (use_phase0 - use_phase1)/use_phase0


outsheet using `finalElecData', comma replace

keep account_number test_period_length test_period_length dnvgl_acct_id customer_number projectid serviceaccountid wthrfile stationnum r2 avg_daily_kwh energy_intensity_elec elec_realized_savings elevation

save `elecData', replace

*********************************************
*****merge in with project data

use `projectData', clear
gen account_number = serviceaccountid

cap drop _merge
duplicates drop account_number, force
destring account_number, replace

merge 1:1 account_number using `gasData'
tab _merge
keep if _merge==3
cap drop _merge
merge 1:1 account_number using `elecData'
tab _merge
keep if _merge==3
drop _merge

**********************************************
********Mass renaming*************************
gen	year_built	= .	
rename	zipcode	zipcode		
rename	ioue3climatezone	climate		
rename	conditionedfloorarea	pre_conditioned_area		
gen		pre_volume	=.	
rename	stories	stories		
gen		ceiling_height	=	.
rename	nbedrooms	bedrooms		
rename	frontorientation	front_orientation		
rename	foundationtype	foundation_type		
rename	ductlocation	duct_location		
				
rename	heatingefficiency	gas_furnace_efficiency_existing		
rename	coolinghvactype	central_AC_existing		
rename	coolingefficiency	cooling_efficiency_existing		
rename	ductrvalue	duct_insulation_r_existing		
gen		duct_leakage_existing	=	.
rename	dhwtype	water_heater_type_existing		
rename	heatingefficiency	gas_furnace_efficiency_new		
gen		central_ac_new	=	.
gen		cooling_capacity_new	=	.
gen		duct_insulation_r_new	=	.
gen		duct_leakage_new	=	.
gen		water_heater_type_new	=	.
				
rename	existcfm50	shell_leakage_cfm50_existing		
gen		foundation_floor_insul_exist	=	.
gen		foundation_wall_insul_exist	=	.
gen		attic_type_existing	=	.
gen		attic_ceiling_area_existing	=	.
gen		attic_insulation_existing	=	.
gen		wall_construction_existing	=	.
gen		wall_insulation_existing	=	.
gen		window_type_existing	=	.
gen		shell_leakage_cfm50_new	=	.
gen		foundation_floor_insul_new	=	.
gen		foundation_wall_insul_new	=	.
gen		attic_type_new	=	.
gen		attic_ceiling_area_new	=	.
gen		attic_insulation_new	=	.
gen		wall_construction_new	=	.
gen		wall_insulation_new	=	.
gen		window_type_new	=	.
				
gen		wall_area_total	=	.
gen		window_area_total	=	.
gen		door_area_total	=	.
gen		wall_area_east	=	.
gen		window_area_east	=	.
gen		door_area_east	=	.
gen		wall_area_west	=	.
gen		window_area_west	=	.
gen		door_area_west	=	.
gen		wall_area_north	=	.
gen		window_area_north	=	.
gen		door_area_north	=	.
gen		wall_area_south	=	.
gen		window_area_south	=	.
gen		door_area_south	=	.
				
				
gen		retrofit_measures_other_exist	=	.
gen		retrofit_measures_other_new	=	.
	
rename	iouinstallationdate	retrofit_date		
gen		gas_id	=	.
gen		electric_id	=	.
rename	stationnum	weather_station		
				
rename	company	contractor		
rename	name	xml_file_name		
				
gen		gas_heat	=	.
gen		gas_hotwater	=	.
rename	energy_intensity_gas	energy_intensity_gas		
rename	energy_intensity_elec	energy_intensity_elec		
gen		total_savings	=	.
rename	elec_realized_savings	electricity_savings		
rename	gas_realized_savings	gas_savings		
rename	edfilledexantesavkw	projected_elec_savings		
rename	edfilledexantesavtherms	projected_gas_savings	
*gen	gas_realization		
*gen	elec_realization		
				
gen		preffered_contractor	=	.


**********************************************

outsheet using `finalProjectData', comma replace
outsheet using `finalData', comma replace

**************END******************

