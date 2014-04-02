********************************
**** SDGE Data Prep ************
********************************
clear
set more off

*******Directories and Files****

local saveDIR = "/Users/matthewgee/Projects/CalTest/data/sdge"
local dataDIR = "/Users/matthewgee/Projects/CalTest/data/sdge"
local xmlDIR = "/Users/matthewgee/Projects/CalTest/data/sdge/SDGE EPro files/XML/"


cd `dataDIR'

******************************************
******  Get Use Data from XML ************
******************************************
**Read XML
set more off
cap erase SDGExmlpreuse.dta
local xmlfiles: dir "`xmlDIR'" files "*.xml"
local i=1
*quietly 
foreach xml of local xmlfiles {
	drop _all
	infix str x 1-200 if strpos(x,"<Utility") & strpos(x,`"Month="0""') using "`xmlDIR'`xml'"
	if `c(N)'==0 {
		noi di `"no usage in `xml'"'
	}
	else {
		keep if inlist(_n,1,2,_N-1,_N)
		replace x=subinstr(x,char(34),"",.)
		gen byte elec= strpos(x,"ElecUse")>0
		gen byte post= 1-(_n<3)
		split x, gen(z)
		gen heat=real(substr(z3,strpos(z3,"=")+1,.))
		gen cool=real(substr(z4,strpos(z4,"=")+1,.))
		gen tot=real(substr(z5,strpos(z5,"=")+1,.))
		gen dhw=real(substr(z6,strpos(z6,"=")+1,.))
		gen file="`xml'"
		keep elec post heat cool tot dhw file
		reshape wide  heat cool tot dhw, i(file post) j(elec)
		rename *0 gas*
		rename *1 elec*
		reshape wide gasheat gascool gastot gasdhw elecheat eleccool electot elecdhw, i(file) j(post)
		if c(N)==1 {
			cap append using xmlpreuse
			save xmlpreuse, replace
		}
		if `i'==10*int(`i'/10) noi di "." _c
		local i=`i'+1
	}
}


cd `saveDIR'


