*******************************
*** P G & E Data Preparation***
***                         ***
***        Matt Gee         ***
***        March 29th       ***
*******************************

clear
set more off

local dataPath = "/Users/matthewgee/Projects/CalTest/data/pgedata/"

local savePath = "/Users/matthewgee/Projects/CalTest/data/final/"

local pgeData = "/Users/matthewgee/Projects/CalTest/data/pgedata/essa_data1_withcz2010.dta"

local contractorList = " pge_preffered_contractor_list"

*******************************
cd `dataPath'
use `pgeData', clear


*******************************
** Ensure data has right vars**
*******************************

rename	yearbuilt	year_built		
rename	zipcode	zipcode		
rename	cz	ca_climate_zone		
rename	pre_area	pre_conditioned_area		
rename	pre_volume	volume		
rename	stories	stories_above_grade		
gen		ceiling_height	=	.
gen		bedrooms	=	.
gen		front_orientation	=	.
rename	XML_FoundationType	foundation_type		
rename	XML_Ductloc1	duct_location		
				
rename	XML_HeatingEfficiency	gas_furnace_efficiency_existing		
rename	pre_ac	central_AC_existing		
rename	XML_DesignCoolingCapacity	cooling_capacity_existing		
rename	pre_r_duct	duct_insulation_r_existing		
rename	pre_cfm25duct	duct_leakage_existing		
rename	hwtype1	water_heater_type_existing		
rename	XML_postafue	gas_furnace_efficiency_new		
rename	XML_HVACSystemType	central_AC_new		
rename	XML_postseer	cooling_capacity_new		
rename	XML_ductrpost	duct_insulation_r_new		
rename	XML_ductcfm25post	duct_leakage_new		
gen		water_heater_type_new	=	.
				
rename	pre_cfm50	shell_leakage_cfm50_existing		
rename	pre_floor_u	foundation_floor_ins_existing		
gen		foundation_wall_ins_existing	=	.
rename	tstattype1	attic_type_existing		
gen		attic_ceiling_area_existing	=	.
rename	pre_ceil_u	attic_insulation_existing		
gen		wall_construction_existing	=	.
rename	pre_wall_u	wall_insulation_existing		
gen		window_type_existing	=	.
rename	XML_cfm50post	shell_leakage_cfm50_new		
gen		foundation_floor_ins_new	=	.
gen		foundation_wall_ins_new	=	.
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
				
gen		retrofit_measures_other_existing	=	.
gen		retrofit_measures_other_new	=	.
rename	auditdate	retrofit_start_date		
rename	testoutdate	retrofit_end_date		
rename	record	gas_raw_id		
gen		electric_raw_id	=	.
rename	station	weather_station		
				
rename	contractor	contractor		
rename	XMLfile	xml_file_name		
				
rename	gasheat	gas_heat		
rename	gasdhw	gas_hotwater		
rename	Gnac1psqft	energy_intensity		
rename	totalkbtusavings	total_savings		
rename	electricitysavings	electricity_savings		
rename	naturalgassavings	gas_savings		
rename	projelecsave	projected_elec_savings		
rename	projsvgas	projected_gas_savings		
rename	Grealize	gas_realization		
rename	Erealize	elec_realization		

***********************************
** Ensure data has use normalized**
***********************************

*************************************
** Ensure realization is calculated**
*************************************
*it is*

*************************************
** Get rid of problematic variables**
*************************************
drop xmldata gas1 gas2 gas3 gas4 gas5 elec1 elec2 elec3 elec4 elec5
drop XML*
drop res1

******************************************
***merge in list of approved contractors**
******************************************
replace contractor = upper(contractor)
merge m:1 contractor using `contractorList'
drop if _merge==2
*************************************
** Save              ****************
*************************************

outsheet using "`savePath'pge_CalTest_data_prepped.csv", comma replace

