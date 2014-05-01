program define compare_periods
version 11.1 

********************************************************
****takes weather normalized data and compares periods before and after

syntax [if] [in], idvar(str) usevar(real) util(str) minlength(int 12)

sort `idvar' bill_start_date

egen group=group(idvar)
su group, meanonly
local groups = `r(max)'

gen panel = .
*replace panel =1 if phase == 0

foreach i of num 1/`groups' { 
		replace panel = L12.panel if L12.phase==1 & group==`i'
		replace panel = F12.panel if F12.panel==1  & group==`i'
		}

keep if panel==1

end
