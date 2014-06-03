*fill in missing values for caltest homes
local selected = "/Users/matthewgee/Projects/CalTest/data/selected/CalTest_selected_homes_combined_clean.csv"
local weatherstation = "/Users/matthewgee/Projects/CalTest/data/weather/WeatherFileData.csv"
tempfile weather

set more off

clear 
insheet using `weatherstation', comma names 
duplicates drop zipcode, force
save `weather', replace

clear

insheet using `selected', comma
replace xml_file_name = upper(xml_file_name)

#delimit ;
keep if 

xml_file_name =="SGHDPS1525988997.XML"|
xml_file_name =="SGHDPS1526215611.XML"|
xml_file_name =="SGHDPS1526258331.XML"|
xml_file_name =="SGHDPS1526331746.XML"|
xml_file_name =="SEHDPS1526388512.XML"|
xml_file_name =="SEHDPS1526388932.XML"|
xml_file_name =="ED TWORUK.XML"|
xml_file_name =="ERIC RUPERT.XML"|
xml_file_name =="MARY COBB.XML"|
xml_file_name =="SHIRLEY HUSTON.XML"|
xml_file_name =="4GY9LD.XML"|
xml_file_name =="8WZD1Z.XML"|
xml_file_name =="9IC5HT.XML"|
xml_file_name =="E3RCZ8.XML"|
xml_file_name =="FBDDJ3.XML"|
xml_file_name =="GRUZBH.XML"|
xml_file_name =="NP7PRY.XML"|
xml_file_name =="OVYM2X.XML"|
xml_file_name =="NKP4ZU.XML"|
xml_file_name =="S812VL.XML";
#delimit cr

*merge in weather file data
tostring zipcode, replace
cap drop _merge

merge m:1 zipcode using `weather'

keep if _merge == 3

*turn everything to a string
des, varlist
tostring `r(varlist)', replace force


*replace scg/sce values

replace 	stories_above_grade	=	"1"	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	ceiling_height	=	ceilingheight	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	bedrooms	=	nbedrooms	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	front_orientation	=	frontorientation	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	duct_location	=	ductlocation	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	central_ac_existing	=	coolinghvactype	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	cooling_efficiency_existing	=	coolingefficiency	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	gas_furnace_efficiency_new	=	post_afue	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	cooling_efficiency_new	=	cooling_capacity_new	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	duct_leakage_new	=	cfm25_post	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	foundation_floor_ins_existing	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	foundation_wall_ins_existing	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	attic_type_existing	=	"Setback"	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	attic_ceiling_area_existing	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	wall_construction_existing	=	zone1room1ins1_frametype	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	wall_insulation_existing	=	zone1room1ins1_cavityinsulationr	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	window_type_existing	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	foundation_floor_ins_new	=	foundation_floor_insulation_new	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	foundation_wall_ins_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	attic_type_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	attic_ceiling_area_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	wall_construction_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	window_type_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	retrofit_measures_other_new	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	retrofit_start_date	=	""	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	retrofit_end_date	=	retrofit_complete_date	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	weather_station	=	wthrfile	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	duct_insulation_r_existing	=	ductrvalue	if	iou	==	"SCE"	|	iou	==	"SCG"
replace 	gas_furnace_efficiency_existing	=	heatingefficiency	if	iou	==	"SCE"	|	iou	==	"SCG"

destring ceiling_height, replace
destring pre_conditioned_area, replace
destring volume, replace
replace 	volume	=	ceiling_height*pre_conditioned_area	if	iou	==	"SCE"	|	iou	==	"SCG"


*replace sdge values



*replace pge values



