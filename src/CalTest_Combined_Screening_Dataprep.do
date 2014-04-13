/*
*weatherization File

**This stata file takes in regular data

Requirements of PRISM

- Dataset must have the following variables
-- station: for the weather station
-- date: for the date of the weather reading

Requirements for data cleaning
- id variables
- station variable
- start date
- date
- number of bill days
- use (kwh)

Re


*/


*******************************
**** Define Paths *************



*******Data Preparation ******

*Prepare contractor lists
cd `pgePath'
insheet using "PGEPreferredContractorLists.csv", clear
replace contractor = upper(contractor)
save pge_preffered_contractor_list, replace

cd `scgPath'
insheet using "SCGPreferredContractorLists.csv", clear
replace contractor = upper(contractor)
save pge_preffered_contractor_list, replace

cd `sdgePath'
insheet using "SDGEPreferredContractorLists.csv", clear
replace contractor = upper(contractor)
save pge_preffered_contractor_list, replace

*get date of stuff later


***format date variables (take dates and inputs)
 format dt* %td 
 format date %td
 
***keep relevant variables for adjustments***
*** 
 keep jobid pgewstn dt_start date bill_days kwh est

 rename kwh use

 rename pgewstn station

 
 replace use=. if bill_days<25

 
 replace use=. if bill_days>35

 
 bysort jobid (date): gen byte expand=1+(_n==1)

 
 expand expand

 
 sort jobid date

 
 bysort jobid (date): gen byte start=_n==1

 
 replace use=. if start==1

 
 replace date=dt_start if start==1

 
 drop dt_start

 
 bysort jobid (date): replace use=use+use[_n-1] if est[_n-1]==1


 
 drop if est==1

 keep jobid station date use

save elecuseclean1

