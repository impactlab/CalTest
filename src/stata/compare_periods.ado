program define compare_periods
version 11.1 

********************************************************
****takes weather normalized data and compares periods before and after

syntax [if] [in], idvar(str) datevar(str) usevar(str) util(str) [minlength(int 12)]

*gen month = month(`datevar')
*gen year = year(`datevar')
*gen monthinsample = ym(year,month)


sort `idvar' `datevar'
by `idvar': gen bill_period = _n

egen group=group(`idvar')

sort group bill_period
tset group bill_period

cap drop group

egen group=group(`idvar')
su group, meanonly
local groups = `r(max)'

gen testmonth = .
*replace panel =1 if phase == 0

foreach i of num 1/`groups' { 
		sort group bill_period
		replace testmonth = 1 if L12.phase==0 & group==`i'
		replace testmonth = F12.testmonth if F12.testmonth==1  & group==`i'
		}

*keep if testmonth==1
gen use_phase0 =.
gen use_phase1=.
gen total_use_phase0 = .
gen total_use_phase1 = .

replace use_phase0=use_norm if phase==0
replace use_phase1=use_norm if phase==1

if "`util'"=="gas" {

	replace total_use_phase0=tot_therms if phase==0
	replace total_use_phase0=tot_therms if phase==0
	replace total_use_phase1=tot_therms if phase==1
	}
else {

	replace total_use_phase0=tot_kwh if phase==0
	replace total_use_phase1=tot_kwh if phase==1	
	
	}
	


end
