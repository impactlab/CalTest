

**********************************
****Code for Preparing SCE Data***
**********************************

*get_scg_11dec2013_1034.log 11dec2013 1034 
set more off

*define path
local dataPath = "/Users/matthewgee/Projects/CalTest/data/scg/"
local rawPath = "/Users/matthewgee/Projects/CalTest/data/scg/raw files/"
local savePath = "/Users/matthewgee/Projects/CalTest/data/scg/final/"
local finalSavePath = "/Users/matthewgee/Projects/CalTest/data/final/"

*define files

local rawGasData = "/Users/matthewgee/Projects/CalTest/data/scg/scg_gas_usage_long.csv"
local rawElecData = "/Users/matthewgee/Projects/CalTest/data/scg/scg_elec_usage_long.csv"
local SCErawProjectFile = "/Users/matthewgee/Projects/CalTest/data/scg/SCE-SoCalGas EUC Software Project Data_2013_12_11_1unencrypt.xlsx"
local SCGrawProjectFile = "/Users/matthewgee/Projects/CalTest/data/scg/SCE-SoCalGas EUC Software Project Data_2013_12_11_1unencrypt.xlsx"
local SCGcontractorFile = "/Users/matthewgee/Projects/CalTest/data/scg/SCG_contractors_for_projects.csv"
local SCEcontractorFile = "/Users/matthewgee/Projects/CalTest/data/scg/SCE_contractors_for_projects.csv"
local preferredContractors = "/Users/matthewgee/Projects/CalTest/data/scg/SCGPreferredContractorLists.csv"

local weatherData = "/Users/matthewgee/Projects/CalTest/data/weather/weather_data_prepped.csv"

*define temp files
tempfile projectData
tempfile measureData
tempfile gasData
tempfile elecData
#tempfile weatherData

*define signed names
local finalGasData = "/Users/matthewgee/Projects/CalTest/data/final/sce_gas_prepped.csv"
local finalElecData = "/Users/matthewgee/Projects/CalTest/data/final/sce_elec_prepped.csv"
local finalProjectData = "/Users/matthewgee/Projects/CalTest/data/final/sce_project_data_prepped.csv"
local finalData = "/Users/matthewgee/Projects/CalTest/data/final/sce_CalTest_data_prepped.csv"

/*

*change directory

cd `dataPath'

 clear
 import excel using "`dataPath'Adv Path Energy Usage and Meter Read Dates 121013 mb.xlsx", firstrow
 unab vars: D - EM
 local cnt: word count `vars'

 forvalues i=1 (1) 70 {
   local useword=`i'*2-1
   local use : word `useword' of `vars'
   local dateword=`useword'+1
   local date: word `dateword' of `vars'
   rename `use' use`i'
   rename `date' date`i'
   }

 rename SumofBILLING_USAGE_QTY use0
 rename SumofMeterReadDate date0

 reshape long use date, i( VisionProjectNumber) j(period)
 drop if use==. & date==.
 gen yr=year(date)
 count if yr>2013 & yr<.

 *uniq Vision if yr>2013 & yr<.



 rename VisionProjectNumber visionnumber
 
 save Usage121013mb_long_new, replace

 
 
******************************************

 drop _all
 import excel using "`rawPath'scg billing data gas72_2013.xlsx",  firstrow
 rename *ThmQty *use
 rename *use use*

 local i=1
 foreach stub in F H J L N P R T V X Z AB {
   rename `stub' dt`i'
   local i=`i'+1
   }

 local i=1
 foreach stub in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
   rename use`stub' use`i'
   local i=`i'+1
   }

 format dt* %td
 reshape long use dt, i( ProjectID BilledCycle Year BAStatus) j(month)
 rename ProjectID visionnumber
 drop Year
 rename dt date
 
 save gas72_2013_new, replace
 
**************************************************

 drop _all
 import excel using "`rawPath'scg billing data gas72_20102012.xlsx",  firstrow
 rename *ThmQty *use
 rename *use use*
 local i=1
 foreach stub in G I K M O Q S U W Y AA {
   local i=`i'+1
   rename `stub' dt`i'
   }
 rename JanReadDate dt1
 local i=1
 foreach stub in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
   rename use`stub' use`i'
   local i=`i'+1
   }

 rename dt10 dts10
 gen int dt10=date(dts10,"MDY")
 format dt10 %td
 move dt10 dts10
 replace dt10=mdy(10,2,2010) if dt10==. & dts10=="10//2010"
 drop dts10
 reshape long use dt, i( ProjectID BilledCycle Year BAStatus) j(month)
 rename ProjectID visionnumber
 rename dt date
 drop Year
 
 save gas72_20102012_new, replace


 gen byte file=1
 append using  gas72_2013
 replace file=2 if file==.
 sort vision date
 save gas72_alluse_new, replace

*/

**********************************************************************
***Prepare Project Data for SCE
**********************************************************************

 drop _all
 import excel using "`SCErawProjectFile'", firstrow
 foreach var of varlist Floors PreFloorRValue PreWallRValue PreDuctRValue PreWindowUValue PreWindowSHGC PreGasFurnaceAFUE PostCeilingRValue2 PreCeilingRValue1 PreCeilingRValue2 {
   replace `var'="EP only" if strpos(`var',"EP file Only")
   }
 compress

 gen SiteID = SiteID_vision
 
 order SiteID AuditStartDate RetrofitCompletionDate_appsubmi 
 save SCE_project_2013_12_11_1_new, replace

 replace RetrofitCompletionDate_appsubmi ="" if RetrofitCompletionDate_appsubmi=="Not Available"
 rename RetrofitCompletionDate_appsubmi  compdate_appsubmit
 gen RetrofitCompletionDateDatefr = compdate_appsubmit
 gen int compdate_apponline=date( RetrofitCompletionDateDatefr ,"MDY")
 format compdate_apponline %td
 move  compdate_apponline compdate_appsubmit
 replace compdate_apponline=date( RetrofitCompletionDateDatefr,"MDY",2010) if compdate_apponline==.
 replace compdate_apponline=date( RetrofitCompletionDateDatefr,"MDY",2020) if year(compdate_apponline)<1920
 drop RetrofitCompletionDateDatefr
 rename _all, lower
 save, replace

 rename weatherstation zip
 destring yearbuilt area, replace
 drop floors
 replace foundation="NA" if foundation=="Not Available in Database"
 rename waterheatingfuel dhw_fuel
 rename heatingfuel ht_fuel
 *rename centralacyesno centralac
 *yesno centralac
 *destring projectedgassavingsthermsyr projectedelectricsavingskwhy, replace
 *rename projectedgassavingsthermsyr projsavegas
 *rename projectedelectricsavingskwhy projsaveelec
 *killdbl
 destring preshellcfm50leakage, replace force
 rename preshellcfm50leakage cfm50_pre
 replace preductcfm25 ="EP only" if strpos( preductcfm25,"EP file Only")
 replace preductcfm25 ="Hazard" if strpos( preductcfm25,"Hazard")
 compress
 gen cfm25_pre=real( preductcfm25)
 move cfm25_pre  preductcfm25
 replace cfm25_pre=. if cfm25_pre==0
 compress


 *yesno retrofitacreplace- retrofitother
 label def yesno01 0"No" 1"Yes", modify
 rename retrofit* retro*
 rename  *insulation* *ins*
 rename  *ceiling* *ceil*
 rename retro* r_*
 rename r_windowreplace r_windrepl
 rename r_gashtrreplace r_gashtrrepl
 rename r_airsealing r_airseal
 rename *rvalue* *_r_*
 rename *r_ *r
 rename *window* *win*
 rename prewinuvalue prewin_u
 rename prewinshgc prewin_shgc
 rename pregasfurnaceafue pre_afue

 *drop prefloor_r prewall_r prewin_u
 *drop gasutility r_other prewin_shgc
 replace pre_afue="" if real(pre_afue)==0
 replace preacseer="EP only" if strpos( preacseer,"EP file Only")
 replace postductcfm25 ="EP only" if strpos( postductcfm25,"EP file Only")
 replace postceil_r_1="" if strpos(postceil_r_1,"Please refer")
 foreach var of varlist postfloor_r postgasfurnaceafue postwinshgc {
   replace `var'="EP only" if strpos(`var',"EP file Only")
   }

 foreach var of varlist _all {
   cap replace `var'="" if `var'=="N/A"
   }

 foreach var of varlist _all {
   cap replace `var'="" if `var'=="EP only"
   }

 gen post_hspf=postgasfurnaceafue if strpos(postgasfurnaceafue,"HSPF")
 replace postgasfurnaceafue="" if strpos( postgasfurnaceafue,"HSPF")
 compress
 rename postgasfurnaceafue post_afue
 rename postwinshgc postwin_shgc
 rename postwinuvalue postwin_u
 destring postshellcfm50leakage , replace
 rename postshellcfm50leakage cfm50_post
 destring postductcfm25, replace
 rename postductcfm25 cfm25_post
 rename auditstartdate auditdate
 *format auditdate compdate_appsubmit %td
 
 
 
 save sce_projectinfo_new, replace
 
 
 ****merge contractor list
 clear 
 
 insheet using `SCEcontractorFile', names
 rename siteid_vision siteid
 
 merge 1:1 siteid using sce_projectinfo_new
 drop _merge
 
***************************************************
**********Rename to prep for selection*************
***************************************************
 
rename	auditdate	audit_date	
rename	compdate_appsubmit	retrofit_complete_date	
rename	yearbuilt	year_built	
rename	zip	zipcode	
rename	climatezone	ca_climate_zone
gen climate = ca_climate_zone
rename	area	pre_conditioned_area	
gen		pre_volume	=.
gen		stories	=.
gen		ceiling_height	=.
gen		bedrooms	=.
gen		front_orientation	=.
rename	foundationtype	foundation_type	
gen		duct_location	=.
			
rename	pre_afue	gas_furnace_efficiency_existing	
gen		central_AC_existing	=.
rename	preacseer	cooling_efficiency_existing	
rename	preduct_r	duct_insulation_r_existing	
rename	preductcfm25	duct_leakage_existing	
rename	dhw_fuel	water_heater_type_existing	
gen		gas_furnace_efficiency_new	=.
rename	r_acreplace	central_AC_new	
rename	postacseer	cooling_efficiency_new	
gen 	postduct_r	=.	
gen		duct_leakage_new	=.
rename	r_gashtrrepl	water_heater_type_new	
			
rename	cfm50_pre	shell_leakage_cfm50_existing	
rename	prefloor_r	foundation_floor_insul_exist	
gen		foundation_wall_insul_exist	=.
gen		attic_type_existing	=.
gen		attic_ceiling_area_existing	=.
rename	preceil_r_1	attic_insul_exist	
gen		wall_construction_existing	=.
gen		wall_insulation_existing	=.
gen		window_type_existing	=.
rename	cfm50_post	shell_leakage_cfm50_new	
rename	postfloor_r	foundation_floor_insul_new	
gen		foundation_wall_insulation_new	=.
gen		attic_type_new	=.
gen		attic_ceiling_area_new	=.
rename	postceil_r_1	attic_insulation_new	
gen		wall_construction_new	=.
rename	postwall_r	wall_insulation_new	
rename	postwin_u	window_type_new	
			
gen		wall_area_total	=.
gen		window_area_total	=.
gen		door_area_total	=.
gen		wall_area_east	=.
gen		window_area_east	=.
gen		door_area_east	=.
gen		wall_area_west	=.
gen		window_area_west	=.
gen		door_area_west	=.
gen		wall_area_north	=.
gen		window_area_north	=.
gen		door_area_north	=.
gen		wall_area_south	=.
gen		window_area_south	=.
gen		door_area_south	=.
			
gen		retrofit_measures_other_exist	=.
gen		retrofit_measures_other_new	=.
*rename	auditdate	audit_date	
rename	compdate_apponline	retrofit_date	
*rename	siteid	gas_id	
*rename	siteid	electric_id	
gen		weather_station	=.
			
rename		contractorcompany	= contractor
gen		xml_file_name	=.
			
gen		gas_heat =.	
gen 	dhw_fuel= .	
gen		energy_intensity	=.
gen		total_savings	=.
gen		electricity_savings	=.
gen		gas_savings	=.
*rename	projsaveelec	projected_elec_savings	
*rename	projsavegas	projected_gas_savings	
gen		projsaveelec	=.
gen		projsavegas	=.
gen		gas_realization	= -1 + (2+1)*runiform()
gen		elec_realization	= -1 + (2+1)*runiform()
			

******************************
*Replace energy pro values**

des, varlist
foreach var in `r(varlist)'{
	cap replace `var'="" if `var'=="Not Available in Database; Value Exists in EP file Only"
	cap replace `var'="" if `var'=="Project completed prior to Database implementation; Value exists in EP file only"
	}

tempfile projectData
save `projectData', replace




***Merge in preffered contractor***
clear
insheet using `SCEcontractorFile', comma names
rename siteid_vision siteid

merge 1:1 siteid using `projectData'
cap drop preffered_contractor
cap drop _merge
save `projectData', replace

**Merge preffered contractors list
clear
insheet using `preferredContractors', comma names
rename contractor contractorcompany
cap drop _merge

merge 1:m contractorcompany using `projectData'

/* work on these
contractorcompany
AZ Air Conditioning and Heating
Green Guys Construction, Inc.
IRC Services
Mediterranean Heating and Air Conditioning
*/


save `projectData', replace

	
***********Save Project Data*************** 

outsheet using "`finalSavePath'SCE_project_info_cleaned.csv", comma replace
outsheet using "`finalProjectData'", comma replace
 
 
****Create extract to merge with use data****
drop if siteid_vision=="" |retrofit_date==.

keep siteid_vision retrofit_date climate zipcode pre_conditioned_area
rename siteid_vision visionnumber
sort visionnumber
tempfile projMerge
save `projMerge', replace


***************************** 
******Prepare Usage data*****
*****************************


****Prepare Gas*****

clear
insheet using "`rawGasData'",  names

*rename vars
rename date olddate
gen date = date(olddate, "MD20Y")


rename date bill_start_date

gen  bill_end_date = .
gen bill_period_length = .

sort visionnumber bill_start_date

egen group = group(visionnumber)
su group, meanonly
local groups = `r(max)'
*levelsof account, local(levels)
foreach i of num 1/`groups' {
	replace bill_end_date = bill_start_date[_n+1] if group ==`i'
	replace bill_period_length = bill_end_date - bill_start_date
	}

replace bill_period_length = 30 if bill_period_length ==.	

rename use tot_therms
gen avg_daily_therms = tot_therms / bill_period_length

save `gasData', replace

***********Merge in project data and create temp vars******
merge m:1 visionnumber using `projMerge'
keep if _merge ==3
drop _merge

gen phase = cond(retrofit_date <= bill_start_date,1,0,.)

save `gasData', replace

**save prepared data**

outsheet using `finalGasData', comma replace

**************************
****Prepare Elec*****

clear
insheet using "`rawElecData'", t names

*rename vars
rename date olddate
gen date = date(olddate, "MD20Y")


rename date bill_start_date

gen  bill_end_date = .
gen bill_period_length = .

sort visionnumber bill_start_date

egen group = group(visionnumber)
su group, meanonly
local groups = `r(max)'
*levelsof account, local(levels)
foreach i of num 1/`groups' {
	replace bill_end_date = bill_start_date[_n+1] if group ==`i'
	replace bill_period_length = bill_end_date - bill_start_date
	}

replace bill_period_length = 30 if bill_period_length ==.	

rename use tot_kwh
gen avg_daily_kwh = tot_kwh / bill_period_length

save `elecData', replace

************Merge in retrofit date and size for normalization and intensity calc***

merge m:1 visionnumber using `projMerge'
keep if _merge ==3
drop _merge

gen phase = cond(retrofit_date <= bill_start_date,1,0,.)

save `elecData', replace
**rename variable to link on**

outsheet using `finalElecData', comma replace 
 

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

rename hdd hdd_start
rename cdd cdd_start 
gen climate = cliz 
levelsof climate, local(climate)


foreach c in `climate'{
	levelsof usaf if climate ==`c', local(station)
		local i=1
		foreach s in `station'{
			if `i'==1{
				cap drop if (climate==`c' & usaf~=`s')
				local i=`i'+1
				}
			else{
				local i=`i'+1
			}
		}
}


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

rename hdd hdd_end
rename cdd cdd_end
gen climate = cliz 

foreach c in `climate'{
	levelsof usaf if climate ==`c', local(station)
		local i=1
		foreach s in `station'{
			if `i'==1{
				cap drop if (climate==`c' & usaf~=`s')
				local i=`i'+1
				}
			else{
				local i=`i'+1
			}
		}
}


tempfile dd_end
save `dd_end', replace

*******************************
*merge in hdd by station + date
*****************************
clear
use `gasData'

merge m:1 climate bill_start_date using `dd_start'
keep if _merge==3
drop _merge

merge m:1 climate bill_end_date using `dd_end'
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

*************************
clear
use  `elecData'

merge m:1 climate bill_start_date using `dd_start'
keep if _merge==3
drop _merge

merge m:1 climate bill_end_date using `dd_end'
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

adopath ++ "/Users/matthewgee/Projects/CalTest/src/stata"
discard
tempfile temp1
normsimp, saving("gas") by(visionnumber) th(70) tc(74)
save `gasData', replace

use `elecData', clear
tempfile temp1
discard
normsimp, saving("elec") by(visionnumber) th(70) tc(74)
save `elecData', replace

******************************************************
*****Construct balanced before and after phase panel

*****************************************************
use `gasData', clear

compare_periods, idvar("visionnumber") datevar("bill_start_date") usevar("avg_daily_therms") util("gas") minlength(12)

#delimit;
collapse (count) test_period_length=zipcode (first)pre_conditioned_area wthrstationnum zipcode r2 
		(mean) upd avg_daily_therms use_norm use_phase0 use_phase1
		, by(visionnumber);
#delimit cr

keep if test_period_length>=24
gen energy_intensity_gas = use_norm / pre_conditioned_area
gen gas_realized_savings = (use_phase0 - use_phase1)/use_phase0

outsheet using `finalGasData', comma replace

*keep account_number test_period_length test_period_length dnvgl_acct_id customer_number projectid serviceaccountid wthrfile stationnum r2 avg_daily_therms energy_intensity_gas gas_realized_savings elevation

save `gasData', replace



*****************************************************
use `elecData', clear

compare_periods, idvar("visionnumber") datevar("bill_start_date") usevar("avg_daily_therms") util("gas") minlength(12)

#delimit;
collapse (count) test_period_length=zipcode (first)pre_conditioned_area wthrstationnum zipcode r2 
		(mean) upd avg_daily_kwh use_norm use_phase0 use_phase1
		, by(visionnumber);
#delimit cr

keep if test_period_length>=24
gen energy_intensity_elec = use_norm / pre_conditioned_area
gen elec_realized_savings = (use_phase0 - use_phase1)/use_phase0

outsheet using `finalElecData', comma replace

*keep account_number test_period_length test_period_length dnvgl_acct_id customer_number projectid serviceaccountid wthrfile stationnum r2 avg_daily_therms energy_intensity_gas gas_realized_savings elevation

save `elecData', replace


*********************************************
*****merge in with project data

use `projectData', clear
gen visionnumber = siteid

cap drop _merge
duplicates drop visionnumber, force
destring visionnumber, replace

merge 1:1 visionnumber using `gasData'
tab _merge
keep if _merge==3
cap drop _merge
merge 1:1 visionnumber using `elecData'
tab _merge
keep if _merge==3
drop _merge


****************************************
***********Final renaming***************

rename elec_realized_savings electricity_savings
rename gas_realized_savings gas_savings
cap rename contractorcompany contractor

**********************************************

outsheet using `finalProjectData', comma replace
outsheet using `finalData', comma replace


