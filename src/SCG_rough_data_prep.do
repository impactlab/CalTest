
*get_scg_11dec2013_1034.log 11dec2013 1034 
set more off

*define path
local dataPath = "/Users/matthewgee/Projects/CalTest/data/scgdata/"
local rawPath = "/Users/matthewgee/Projects/CalTest/data/scgdata/raw files/"
local savePath = "/Users/matthewgee/Projects/CalTest/data/final/"

*define file
*local energyUse = 

*change directory

cd `dataPath'

 clear

******************************************************************************
 ***********Do Rough Cut                              ************************
 
 use projectinfo_gas72_new, clear
 
 
 **********Value Conversions*****
 gen new_gas_heat= cond(ht_fuel=="Natural Gas",1,0)
 
 
 *merge 1:1 
 
rename	auditdate	audit_date	
rename	compdate_appsubmit	retrofit_complete_date	
rename	yearbuilt	year_built	
rename	zip	zipcode	
rename	climatezone	climate	
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
rename	preacseer	cooling_capacity_existing	
rename	preduct_r	duct_insulation_r_existing	
rename	preductcfm25	duct_leakage_existing	
rename	dhw_fuel	water_heater_type_existing	
gen		gas_furnace_efficiency_new	=.
rename	r_acreplace	central_AC_new	
rename	postacseer	cooling_capacity_new	
rename	postduct_r	duct_insulation_r_new	
gen		duct_leakage_new	=.
rename	r_gashtrrepl	water_heater_type_new	
			
rename	cfm50_pre	shell_leakage_cfm50_existing	
rename	prefloor_r	foundation_floor_ins_existing	
gen		foundation_floor_ins_new	=.
gen		attic_type_existing	=.
gen		attic_ceiling_area_existing	=.
rename	preceil_r_1	attic_insulation_existing	
gen		wall_construction_existing	=.
gen		wall_insulation_existing	=.
gen		window_type_existing	=.
rename	cfm50_post	shell_leakage_cfm50_new	
rename	postfloor_r	foundation_floor_insulation_new	
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
			
gen		retrofit_measures_other_existing	=.
gen		retrofit_measures_other_new	=.		
gen		weather_station	=.
			
gen		contractor	=.
gen		xml_file_name	=.
			
rename	new_gas_heat	gas_heat	
*rename	dhw_fuel	gas_hotwater	
gen		energy_intensity	=1
gen		total_savings	=.
gen		electricity_savings	=projsaveelec
gen		gas_savings	= projsaveelec
rename	projsaveelec	projected_elec_savings
rename	projsavegas	projected_gas_savings	
gen		gas_realization	= -1 + (2+1)*runiform()
gen		elec_realization	= -1 + (2+1)*runiform()
			
gen		preffered_contractor	=.


*****************************************
*******Convert values  ******************


********************************************
***    Outsheet  ***************************


outsheet using "`savePath'scg_CalTest_data_prepped.csv", comma replace





