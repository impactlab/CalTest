* Take prepared datasets, combine into single dataset, and select out test homes

clear all
set more off

local sdgeGasData = "/Users/matthewgee/Projects/CalTest/data/selected/sdge_combined_CalTest_selection_final_gas.csv"
local sdgeElecData = "/Users/matthewgee/Projects/CalTest/data/selected/sdge_combined_CalTest_selection_final_elec.csv"
local pgeData = "/Users/matthewgee/Projects/CalTest/data/selected/pge_selected_homes_combined.csv"
local scgData = "/Users/matthewgee/Projects/CalTest/data/selected/scg_CalTest_final.csv"
local sceData = "/Users/matthewgee/Projects/CalTest/data/selected/sce_CalTest_final.csv"
local sceXML = "/Users/matthewgee/Projects/CalTest/data/scg/sce_combined_XML_values.csv"
local scgXML = "/Users/matthewgee/Projects/CalTest/data/scg/scg_combined_XML_values.csv"
local scescgCombined = "/Users/matthewgee/Projects/CalTest/data/selected/scg_sce_CalTest_combined_gas_electric_v2.csv"
local combinedXML = "/Users/matthewgee/Projects/CalTest/data/CalTestCombined_XML_Data.csv"

local saveFile = "/Users/matthewgee/Projects/CalTest/data/selected/CalTest_selected_homes_combined_clean.csv"

tempfile sdgegas sdge pge scg sce scexmltemp scgxmltemp combinedxmltemp

**read in and save combined XML
insheet using `combinedXML', comma 
des, varlist
tostring `r(varlist)', replace force

replace xml_file_name = upper(xml_file_name)
replace name = upper(name)


#delimit
keep if 

xml_file_name =="SGHDPS1525812598.XML"|
xml_file_name =="SGHDPS1525988997.XML"|
xml_file_name =="SGHDPS1526060512.XML"|
xml_file_name =="SGHDPS1526215611.XML"|
xml_file_name =="SGHDPS1526258331.XML"|
xml_file_name =="SGHDPS1526331746.XML"|
xml_file_name =="SEHDPS1526388512.XML"|
xml_file_name =="SEHDPS1526388932.XML"|
name =="ANITA FERGUSON"|
name =="ED TWORUK"|
name =="ERIC RUPERT"|
name =="JOSE IBARRA"|
name =="MARY COBB"|
name =="SHIRLEY HUSTON"|
name =="SUSAN ROBBOY"|
name =="WILLIAM WILSON"|
xml_file_name =="06OSNU.XML"|
xml_file_name =="11AD34.XML"|
xml_file_name =="4GY9LD.XML"|
xml_file_name =="7RWKBB.XML"|
xml_file_name =="8R1J72.XML"|
xml_file_name =="8WZD1Z.XML"|
xml_file_name =="9IC5HT.XML"|
xml_file_name =="CDH5KM.XML"|
xml_file_name =="E3RCZ8.XML"|
xml_file_name =="FBDDJ3.XML"|
xml_file_name =="GRUZBH.XML"|
xml_file_name =="I0JZ8R.XML"|
xml_file_name =="NKP4ZU.XML"|
xml_file_name =="NP7PRY.XML"|
xml_file_name =="OVYM2X.XML"|
xml_file_name =="P9JRTP.XML"|
xml_file_name =="S812VL.XML"|
xml_file_name =="U6JFUA.XML"|
xml_file_name =="UP3Z7D.XML"|
xml_file_name =="UUVJY8.XML";
#delimit cr

count

save `combinedxmltemp', replace	

***********PG&E****************
**pge is the cannonical dataset
clear
insheet using `pgeData', comma 
tostring xml_file_name, replace force

*generate volume

des, varlist
tostring `r(varlist)', replace force

*merge in xml file
duplicates drop xml_file_name, force
replace xml_file_name = upper(xml_file_name)
cap drop _merge
merge  1:1 xml_file_name using `combinedxmltemp'
tab _merge 
keep if _merge==1 | _merge==3
drop _merge


gen iou = "PGE"
order iou

save `pge'


***********SDG&E****************
*sdgeData
clear 
insheet using `sdgeGasData', comma
 
save `sdgegas' 

clear 
insheet using `sdgeElecData', comma 

append using `sdgegas'
 
tostring xml_file_name, replace force
replace xml_file_name = xml_file_name + ".xml"


des, varlist
tostring `r(varlist)', replace force

*merge in xml file
duplicates drop xml_file_name, force
cap drop _merge
replace xml_file_name = upper(xml_file_name)
merge  1:1 xml_file_name using `combinedxmltemp'
tab _merge 
keep if _merge==1 | _merge==3
drop _merge

*rename  year_built
rename  cazone ca_climate_zone
rename  pre_area pre_conditioned_area



gen iou = "SDGE"
order iou

save  `sdge'

***********SCG****************
*scg
clear
insheet using `sceXML', comma
cap drop _merge
save `scgxmltemp'

clear
insheet using `scescgCombined', comma 

*merge in XML files
cap drop _merge
tostring xml_file_name, replace force
replace xml_file_name = siteid + ".xml"
replace xml_file_name = upper(xml_file_name)
duplicates drop xml_file_name, force
merge  1:1 xml_file_name using `scgxmltemp'
tab _merge 
keep if _merge==3


tostring contractor, replace force

des, varlist
tostring `r(varlist)', replace force

gen iou = "SCG"
order iou

save `scg'

***********SCE****************
*sce 
clear
insheet using `scgXML', comma
cap drop _merge
save `scexmltemp'

clear
insheet using `scescgCombined', comma


*merge in XML files
cap drop _merge
tostring xml_file_name, replace force
replace xml_file_name = siteid + ".xml"
replace xml_file_name = upper(xml_file_name)
duplicates drop xml_file_name, force
merge  1:1 xml_file_name using `scexmltemp'
tab _merge
keep if _merge==3

*rename variables
codebook water_heater_type_new	
destring year_built, replace force
replace water_heater_type_new = "1" if water_heater_type_new == "Yes"
replace water_heater_type_new = "0" if water_heater_type_new == "No"
destring water_heater_type_new, replace force



*turn everything to a string

des, varlist
tostring `r(varlist)', replace force

gen iou = "SCE"
order iou

save `sce'
append using `scg'

*change the combined SCE/SCG dataset
gen ca_climate_zone = climate


*merge stuff


******************************
*Append remaining two datasets

append using `sdge'
append using `pge'

duplicates drop xml_file_name, force
***order variables**

order iou xml_file_name year_built zipcode ca_climate_zone	pre_conditioned_area	volume	stories_above_grade	ceiling_height	bedrooms	front_orientation	foundation_type	duct_location	gas_furnace_efficiency_existing	central_ac_existing	cooling_efficiency_existing	duct_insulation_r_existing	duct_leakage_existing	water_heater_type_existing	gas_furnace_efficiency_new	central_ac_new	cooling_efficiency_new	duct_insulation_r_new	duct_leakage_new	water_heater_type_new	shell_leakage_cfm50_existing	foundation_floor_ins_existing	foundation_wall_ins_existing	attic_type_existing	attic_ceiling_area_existing	attic_insulation_existing	wall_construction_existing	wall_insulation_existing	window_type_existing	shell_leakage_cfm50_new	foundation_floor_ins_new	foundation_wall_ins_new	attic_type_new	attic_ceiling_area_new	attic_insulation_new	wall_construction_new	wall_insulation_new	window_type_new	retrofit_measures_other_new	retrofit_start_date	retrofit_end_date	weather_station

**output file
outsheet using `saveFile', comma replace


****

/*
*merge in xml data
clear 
insheet using 
**keep only the selected homes
#delimit;

keep if 
xml_file_name == 

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




