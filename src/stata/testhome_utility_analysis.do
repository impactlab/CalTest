**get savings data

clear
set more off

local combinedGas = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_gas_data.csv"
local combinedElec = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_elec_data.csv"

local selected_gas_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_selected_gas_data.csv"
local selected_elec_data = "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_selected_elec_data.csv"

local combinedHome = ""
***Gas****
insheet using "`combinedGas'", names comma
sort iou account_number

********
*Subset

#delimit;
keep if 
account_number	==	"9IC5HT"	|
account_number	==	"E3RCZ8"	|
account_number	==	"NKP4ZU"	|
account_number	==	"OVYM2X"	|
account_number	==	"4GY9LD"	|
account_number	==	"FBDDJ3"	|
account_number	==	"NP7PRY"	|
account_number	==	"S812VL"	|
account_number	==	"8WZD1Z"	|
account_number	==	"GRUZBH"	|
account_number	==	"SGHDPS1525988997"	|
account_number	==	"SGHDPS1526258331"	|
account_number	==	"SGHDPS1526331746"	|
account_number	==	"SGHDPS1526215611"	|
account_number	==	"SEHDPS1526388932"	|
account_number	==	"SEHDPS1526388512"	|
account_number	==	"9264652903"	|
account_number	==	"6033367454"	|
account_number	==	"6383593286"	|
account_number	==	"9608731398"	;
#delimit cr

count
tab iou

**Fix dates**
destring(date), generate(numdate) force
gen pgedate = numdate if iou=="PGE"
format pgedate %tdnn/dd/YY
*tostring pgedate, replace 

gen sdgedate = date if iou=="SDGE"
replace sdgedate = subinstr(sdgedate,"/9","/09",.)
gen  tempdate = date(sdgedate,"MD20Y")
drop sdgedate
gen sdgedate = tempdate
format sdgedate %tdnn/dd/YY
*tostring sdgedate, replace

gen scgdate = numdate if iou=="SCG"
format scgdate %tdnn/dd/YY
*tostring scgdate, replace

drop date
gen date= .

replace date = sdgedate if iou=="SDGE"
replace date = pgedate if iou == "PGE"
replace date = scgdate if iou=="SCG"

keep account_number date therms iou
order account_number date 
format date %tdnn/dd/YY


*****merge in retrofit data****

outsheet using `selected_gas_data', comma replace


*****Elec*******
clear
insheet using  "/Users/matthewgee/Projects/CalTest/data/combined/CalTest_combined_elec_data.csv"

************
*Get subset

#delimit;
keep if 
account_number	==	"9IC5HT"	|
account_number	==	"E3RCZ8"	|
account_number	==	"NKP4ZU"	|
account_number	==	"OVYM2X"	|
account_number	==	"4GY9LD"	|
account_number	==	"FBDDJ3"	|
account_number	==	"NP7PRY"	|
account_number	==	"S812VL"	|
account_number	==	"8WZD1Z"	|
account_number	==	"GRUZBH"	|
account_number	==	"SGHDPS1525988997"	|
account_number	==	"SGHDPS1526258331"	|
account_number	==	"SGHDPS1526331746"	|
account_number	==	"SGHDPS1526215611"	|
account_number	==	"SEHDPS1526388932"	|
account_number	==	"SEHDPS1526388512"	|
account_number	==	"92646529035"	|
account_number	==	"60333674547"	|
account_number	==	"63835932868"	|
account_number	==	"9608731398"	;
#delimit cr
 
 count
 tab iou
 
 
 **Fix dates**
destring(date), generate(numdate) force
gen pgedate = numdate if iou=="PGE"
format pgedate %tdnn/dd/YY
*tostring pgedate, replace 

gen sdgedate = date if iou=="SDGE"
replace sdgedate = subinstr(sdgedate,"/9","/09",.)
gen  tempdate = date(sdgedate,"MD20Y")
drop sdgedate
gen sdgedate = tempdate
drop tempdate
format sdgedate %tdnn/dd/YY
*tostring sdgedate, replace

gen scedate = date if iou=="SCE"
gen  tempdate = date(scedate,"MDY")
drop scedate
gen scedate = tempdate
format scedate %tdnn/dd/YY
*tostring scgdate, replace

drop date
gen date= .

replace date = sdgedate if iou=="SDGE"
replace date = pgedate if iou == "PGE"
replace date = scedate if iou=="SCE"

keep account_number date kwh iou
order account_number date 
format date %tdnn/dd/YY

 
 
 
outsheet using `selected_elec_data', comma replace
 

 ***merge in retrofit data****
 
 
 
 
 
