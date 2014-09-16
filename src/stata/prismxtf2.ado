cap program drop prismxtf2
program define prismxtf2
version 11.1
***************PRISMxtf2.ado****************************
**********Calculates realized savings based on 
*! v 1.4 24-April-2014 M Gee + M Blasnik -- fixed combined model output
* must have weather station variable "station"
* necessary variables
* 

syntax [if] [in] , saving(str) by(str) [ TH(int 60) TC(int 0) HEatonly ]

tempfile work idlist
tempname out

if `tc'>0 {
	local model "cool"
	local cdd "cdd`tc'pd"
	local cpost " trefc cpdd secpdd "
	bysort `by' (date): drop if `cdd'==. & _n>1
}
if `th'>0 {
	local model "heat"
	local hdd "hdd`th'pd"
	local hpost " trefh hpdd sehpdd "
	bysort `by' (date): drop if `hdd'==. & _n>1
}

quietly {


* clean up and collect some case level info
no count
sort `by' date
by `by': drop if (upd==. & _n>1) | upd<0
by `by': gen begdate=date[1]
by `by': gen enddate=date[_N]
drop if upd==.
by `by': gen nreads=_N
egen grpid=group(`by')
save `work', replace
no count
by `by': keep if _n==_N
keep  grpid `by' nreads begdate enddate station
save `idlist', replace

use `work' 
keep grpid `by' nreads upd days `hdd' `cdd'
postfile `out' grpid r2 base sebs `hpost' `cpost'  covar using `saving', replace

*** loop through each case (grpid)
local cntall=_N
local groups=grpid[_N]
noi di as text "Starting case-by-case analysis: `groups' cases"
local j=1
while `j'<=_N {
	local id=grpid[`j']
	local np=nreads[`j']
	local end=`j'+`np'-1
	if `np'>2 {
		local skip=0
		if "`heatonly'"!="" {
			cap reg upd `hdd' [aweight=1/`hdd'] in `j'/`end', nocons
					if _rc==0 {
									local base=0
									local sebs=0
									local covar=0
									local r2=e(r2)
								}
								else local skip=1
		}
		else {
			cap reg upd `hdd' `cdd' [aweight=days] in `j'/`end'
				if _rc==0 {
					local base=_b[_cons]
					local sebs=_se[_cons]
  				mat v=e(V)
					local covar=v[1,2]
					local r2=e(r2)
				}
		}
				if (`th'>0 & `tc'==0) {
					local htsl=_b[`hdd']
				  local seht=_se[`hdd']
				  post `out' (`id') (`r2') (`base') (`sebs') (`th') (`htsl') (`seht') (`covar') 
				}
				if `tc'>0 &`th'==0{
					local clsl=_b[`cdd']
				  local secl=_se[`cdd']
				  post `out' (`id') (`r2')  (`base') (`sebs') (`tc') (`clsl') (`secl') (`covar') 
				} 
				
				if `tc'>0 & `th'>0 {
				local htsl=_b[`hdd']
				  local seht=_se[`hdd']
				 local clsl=_b[`cdd']
				  local secl=_se[`cdd']
				   post `out' (`id') (`r2')  (`base') (`sebs') (`tc') (`th') (`clsl') (`htsl') (`secl') (`seht') (`covar')
				}
		}
	local j=`end'+1
	if int(`j'/10000)!=int((`j'-`np')/10000) noi di "* " _c
}
postclose `out'
noi di

use `saving', replace
merge m:1 grpid using `idlist'
drop _merge grpid

* get long term average degree days
if `th'>0 & `tc'==0{
	gen tref=`th'
	merge m:1 station tref using cz2010_alldds_longlt, keep(match master) keepusing(lthdd)
	gen senac=365.25*sqrt((lthdd^2*sehpdd^2+2*covar*lthdd+sebs^2))
	replace lthdd=lthdd*365.25
	replace sebs=sebs*365.25
	replace base=base*365.25
	gen nahc=hpdd*lthdd
	gen senahc=sehpdd*lthdd
	gen nac=base + nahc	
	drop tref
}
cap drop _merge
drop if mi(`id')

if `tc'>0 & `th'==0{
	gen tref=`tc'
	merge m:1 station tref using cz2010_alldds_longlt, keep(match master) keepusing(ltcdd)
	gen senac=365.25*sqrt((ltcdd^2*secpdd^2+2*covar*ltcdd+sebs^2))
	replace ltcdd=ltcdd*365.25
	replace sebs=sebs*365.25
	replace base=base*365.25
	gen nacc=cpdd*ltcdd
	gen senacc=secpdd*ltcdd
	gen nac=base + nacc
	drop tref
}
cap drop _merge
drop if mi(`id')

if `tc'>0 & `th'>0 {
	gen tref=`tc'
	merge m:1 station tref using cz2010_alldds_longlt, keep(match master) keepusing(ltcdd)
	drop tref _merge
	gen tref=`th'
	merge m:1 station tref using alldds_longlt2, keep(match master) keepusing(lthdd)
	gen senac=365.25*sqrt((ltcdd^2*secpdd^2+2*covar*ltcdd+sebs^2))
	replace ltcdd=ltcdd*365.25
	replace lthdd=lthdd*365.25
	replace sebs=sebs*365.25
	replace base=base*365.25
	gen nacc=cpdd*ltcdd
	gen senacc=secpdd*ltcdd
	gen nahc=hpdd*lthdd
	gen senahc=sehpdd*lthdd
	gen nac=base + nacc +nahc
	drop tref
}

cap drop _merge
drop if mi(`id')

gen cvnac=senac/nac 
qui compress
format base sebs nac senac na?c sena?c lt?dd %7.0f
format begdate enddate %td
format cvnac  r2  %5.3f
if `th'>0 order `by' station nac base nahc cvnac r2 nreads begdate enddate lthdd sebs sehpdd 
if `tc'>0 order `by' station nac base nacc cvnac r2 nreads begdate enddate ltcdd sebs secpdd 
drop covar 
label data "prismxtf2 `model' `th'`tc' run on $S_DATE $S_TIME"
cap drop _merge
}
save `saving', replace
end
