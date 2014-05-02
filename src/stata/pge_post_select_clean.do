***add seer and clean selected homes***

local dataPath = "/Users/matthewgee/Projects/CalTest/data/pgedata/final/"

local savePath = "/Users/matthewgee/Projects/CalTest/data/final/"

local selectPath = "/Users/matthewgee/Projects/CalTest/data/selected/"

local pgeData = "/Users/matthewgee/Projects/CalTest/data/pgedata/essa_data1_withcz2010.dta"

local contractorList = " pge_preffered_contractor_list"

clear

****

insheet using "`savePath'pge_CalTest_data_prepped.csv", comma 

keep record gas_furnace_efficiency_existing cooling_efficiency_existing	gas_furnace_efficiency_new	cooling_efficiency_new shell_leakage_cfm50_new	
rename record idvar

tempfile efficiency

save `efficiency', replace

clear
insheet using "`dataPath'pge_final_selected.csv", comma
 duplicates drop idvar, force
merge 1:1 idvar using `efficiency'

tab _merge

keep if _merge==3

outsheet using "`selectPath'pge_selected_homes_combined.csv", comma replace
