********************************
**** SDGE Data Prep ************
********************************
clear
set more off

*******Directories and Files****

local saveDIR = "/Users/matthewgee/Projects/CalTest/data/sdge"
local dataDIR = "/Users/matthewgee/Projects/CalTest/data/sdge"
local xmlDIR = "/Users/matthewgee/Projects/CalTest/data/sdge/SDGE EPro files/XML/"

***Define Datasets***

local xmlData = "xmlpreuse.dta"
local projectData = "sdge_track1.dta"
local measureData = "All_job_data_9-23-13.xlsx"
local gasData = "sdge wo46 elec bills.csv"
local elecData = "sdge wo46 elec bills.csv"

local sdgeData = "sdge_combined_data"

cd `dataDIR'

************************************************
******  Get Data from XML and Merge ************
************************************************
use `xmlData', clear


************************************************
****** Get Measure Data   **********************
************************************************
*Uniique identifier: iouprojectid
use `projectData', clear
collapse (first) iouprojectid iouinstallationdate ioucountractorname ioue3climatezone iouprojectdescription iousitezipcode iousiteid bldgtype 

save `sdgeData', replace

*gen contractor name field

*gen pre-retrofit air leakage

*gen energy intensity

*gen HVAC, gas furnace, gas dw vars

*gen total conditioned area var

*gen total elec & gas use

*gen total savings
use `projectData', clear

collapse (sum) grosssavkwh (sum) grosssavtherms, by(iouprojectid)
save `projSavings', replace

use `sdgeData',clear
merge 1:1 ioprojectid using `projSavings', sort

******************************************
****** Calculate Savings  ****************
******************************************

*Get project start date and completion date from project data

use `projectData', clear









cd `saveDIR'


************

