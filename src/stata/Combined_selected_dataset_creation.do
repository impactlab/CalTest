* Take prepared datasets, combine into single dataset, and select out test homes

clear all
set more off

local sdgeData = "/Users/matthewgee/Projects/CalTest/data/final/sdge_CalTest_data_prepped.csv"
local pgeData = "/Users/matthewgee/Projects/CalTest/data/final/pge_CalTest_data_prepped.csv"
local scgData = "/Users/matthewgee/Projects/CalTest/data/final/scg_CalTest_data_prepped.csv"
local sceData = "/Users/matthewgee/Projects/CalTest/data/final/sce_CalTest_data_prepped.csv"

tempfile sdge pge scg sce

***********PG&E****************
**pge is the cannonical dataset

insheet using `pgeData', comma 
tostring xml_file_name, replace force

des, varlist
tostring `r(varlist)', replace force

gen iou = "PGE"
order iou

save `pge'


***********SDG&E****************
*sdgeData
clear 
insheet using `sdgeData', comma 
tostring xml_file_name, replace force

des, varlist
tostring `r(varlist)', replace force

gen iou = "SDGE"
order iou

save  `sdge'

***********SCG****************
*scg
clear
insheet using `scgData', comma 
tostring xml_file_name, replace force
tostring contractor, replace force

des, varlist
tostring `r(varlist)', replace force

gen iou = "SCG"
order iou

save `scg'

***********SCE****************
*sce 
clear
insheet using `sceData', comma
codebook water_heater_type_new	
destring year_built, replace force
replace water_heater_type_new = "1" if water_heater_type_new == "Yes"
replace water_heater_type_new = "0" if water_heater_type_new == "No"
destring water_heater_type_new, replace force

des, varlist
tostring `r(varlist)', replace force

gen iou = "SCE"
order iou

save `sce'

*Append all four datasets

use `scg', clear

append using `sce'
*append using `scg'
append using `sdge'
append using `pge'

/*

Final variable list of the complete data and order

iou
iou_id
caltest_id
year_built
zipcode
ca_climate_zone
pre_conditioned_area
volume
stories_above_grade
ceiling_height
bedrooms
front_orientation
foundation_type
duct_location
gas_furnace_efficiency_existing
central_AC_existing
cooling_efficiency_existing
duct_insulation_r_existing
duct_leakage_existing
water_heater_type_existing
gas_furnace_efficiency_new
central_AC_new
cooling_efficiency_new
duct_insulation_r_new
duct_leakage_new
water_heater_type_new
shell_leakage_cfm50_existing
foundation_floor_ins_existing
foundation_wall_ins_existing
attic_type_existing
attic_ceiling_area_existing
attic_insulation_existing
wall_construction_existing
wall_insulation_existing
window_type_existing
shell_leakage_cfm50_new
foundation_floor_ins_new
foundation_wall_ins_new
attic_type_new
attic_ceiling_area_new
attic_insulation_new
wall_construction_new
wall_insulation_new
window_type_new
retrofit_measures_other_new
retrofit_start_date
retrofit_end_date
weather_station




