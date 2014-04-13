*get_scg_11dec2013_1034.log 11dec2013 1034 
set more off

*define path
local dataPath = "/Users/matthewgee/Projects/CalTest/data/scgdata/"
local rawPath = "/Users/matthewgee/Projects/CalTest/data/scgdata/raw files/"
local savePath = "/Users/matthewgee/Projects/CalTest/data/scgdata/final/"

*define file
*local energyUse = 

*change directory

cd `dataPath'

 clear
 import excel using "`dataPath'Adv Path Energy Usage and Meter Read Dates 121013 mb.xlsx", firstrow
 unab vars: D - EM
 local cnt: word count `vars'

 forvalues i=1 (1) 70 {
   local useword=`i'*2-1
   local use : word `useword' of `vars'
   local dateword=`useword'+1
   local date: word `dateword' of `vars'
   rename `use' use`i'
   rename `date' date`i'
   }

 rename SumofBILLING_USAGE_QTY use0
 rename SumofMeterReadDate date0

 reshape long use date, i( VisionProjectNumber) j(period)
 drop if use==. & date==.
 gen yr=year(date)
 count if yr>2013 & yr<.

 *uniq Vision if yr>2013 & yr<.



 rename VisionProjectNumber visionnumber
 
 save Usage121013mb_long_new, replace

 
 
******************************************

 drop _all
 import excel using "`rawPath'scg billing data gas72_2013.xlsx",  firstrow
 rename *ThmQty *use
 rename *use use*

 local i=1
 foreach stub in F H J L N P R T V X Z AB {
   rename `stub' dt`i'
   local i=`i'+1
   }

 local i=1
 foreach stub in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
   rename use`stub' use`i'
   local i=`i'+1
   }

 format dt* %td
 reshape long use dt, i( ProjectID BilledCycle Year BAStatus) j(month)
 rename ProjectID visionnumber
 drop Year
 rename dt date
 
 save gas72_2013_new, replace
 
**************************************************

 drop _all
 import excel using "`rawPath'scg billing data gas72_20102012.xlsx",  firstrow
 rename *ThmQty *use
 rename *use use*
 local i=1
 foreach stub in G I K M O Q S U W Y AA {
   local i=`i'+1
   rename `stub' dt`i'
   }
 rename JanReadDate dt1
 local i=1
 foreach stub in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec {
   rename use`stub' use`i'
   local i=`i'+1
   }

 rename dt10 dts10
 gen int dt10=date(dts10,"MDY")
 format dt10 %td
 move dt10 dts10
 replace dt10=mdy(10,2,2010) if dt10==. & dts10=="10//2010"
 drop dts10
 reshape long use dt, i( ProjectID BilledCycle Year BAStatus) j(month)
 rename ProjectID visionnumber
 rename dt date
 drop Year
 
 save gas72_20102012_new, replace


 gen byte file=1
 append using  gas72_2013
 replace file=2 if file==.
 sort vision date
 save gas72_alluse_new, replace


**********************************************************************

 drop _all
 import excel using "`rawPath'SoCalGas EUC Software Project Data_2013_11_11_rev2 (2) gas72withdates.xlsx", firstrow
 foreach var of varlist Floors PreFloorRValue PreWallRValue PreDuctRValue PreWindowUValue PreWindowSHGC PreGasFurnaceAFUE PostCeilingRValue2 PreCeilingRValue1 PreCeilingRValue2 {
   replace `var'="EP only" if strpos(`var',"EP file Only")
   }
 compress

 order SiteID AuditStartDate RetrofitCompletionDateDateAp RetrofitCompletionDateDatefr LACountyReleaseSigned
 save SCGEUC2013_11_11_rev2_gas72withdates_new, replace

 replace RetrofitCompletionDateDatefr="" if RetrofitCompletionDateDatefr=="Not Available"
 rename RetrofitCompletionDateDateAp compdate_appsubmit
 gen int compdate_apponline=date( RetrofitCompletionDateDatefr,"MDY")
 format compdate_apponline %td
 move  compdate_apponline compdate_appsubmit
 replace compdate_apponline=date( RetrofitCompletionDateDatefr,"MDY",2010) if compdate_apponline==.
 replace compdate_apponline=date( RetrofitCompletionDateDatefr,"MDY",2020) if year(compdate_apponline)<1920
 drop RetrofitCompletionDateDatefr
 rename _all, lower
 save, replace

 rename weatherstation zip
 destring yearbuilt area, replace
 drop floors
 replace foundation="NA" if foundation=="Not Available in Database"
 rename waterheatingfuel dhw_fuel
 rename heatingfuel ht_fuel
 rename centralacyesno centralac
 *yesno centralac
 destring projectedgassavingsthermsyr projectedelectricsavingskwhy, replace
 rename projectedgassavingsthermsyr projsavegas
 rename projectedelectricsavingskwhy projsaveelec
 *killdbl
 destring preshellcfm50leakage, replace force
 rename preshellcfm50leakage cfm50_pre
 replace preductcfm25 ="EP only" if strpos( preductcfm25,"EP file Only")
 replace preductcfm25 ="Hazard" if strpos( preductcfm25,"Hazard")
 compress
 gen cfm25_pre=real( preductcfm25)
 move cfm25_pre  preductcfm25
 replace cfm25_pre=. if cfm25_pre==0
 compress


 *yesno retrofitacreplace- retrofitother
 label def yesno01 0"No" 1"Yes", modify
 rename retrofit* retro*
 rename  *insulation* *ins*
 rename  *ceiling* *ceil*
 rename retro* r_*
 rename r_windowreplace r_windrepl
 rename r_gashtrreplace r_gashtrrepl
 rename r_airsealing r_airseal
 rename *rvalue* *_r_*
 rename *r_ *r
 rename *window* *win*
 rename prewinuvalue prewin_u
 rename prewinshgc prewin_shgc
 rename pregasfurnaceafue pre_afue

 *drop prefloor_r prewall_r prewin_u
 *drop gasutility r_other prewin_shgc
 replace pre_afue="" if real(pre_afue)==0
 replace preacseer="EP only" if strpos( preacseer,"EP file Only")
 replace postductcfm25 ="EP only" if strpos( postductcfm25,"EP file Only")
 replace postceil_r_1="" if strpos(postceil_r_1,"Please refer")
 foreach var of varlist postfloor_r postduct_r postgasfurnaceafue postwinshgc {
   replace `var'="EP only" if strpos(`var',"EP file Only")
   }

 foreach var of varlist _all {
   cap replace `var'="" if `var'=="N/A"
   }

 foreach var of varlist _all {
   cap replace `var'="" if `var'=="EP only"
   }

 gen post_hspf=postgasfurnaceafue if strpos(postgasfurnaceafue,"HSPF")
 replace postgasfurnaceafue="" if strpos( postgasfurnaceafue,"HSPF")
 compress
 rename postgasfurnaceafue post_afue
 rename postwinshgc postwin_shgc
 rename postwinuvalue postwin_u
 destring postshellcfm50leakage , replace
 rename postshellcfm50leakage cfm50_post
 destring postductcfm25, replace
 rename postductcfm25 cfm25_post
 rename auditstartdate auditdate
 format auditdate compdate_apponline compdate_appsubmit %td

 ****
 
 
 save projectinfo_gas72_new, replace
 
 outsheet using "`savePath'SCG_cleaned_gas72_new.csv", comma replace
 
 
 ******************************************************************************
 **************Take use data and perform prism weather adjustment**************
 
 /* there are now 4 key SCG Datasets
 Usage121013mb_long_new : electricty use
 gas72_alluse_new : gas use for the 72 homes
 projectinfo_gas72_new : the project infromation data

 
 The data need the following done to them: 

 merge the retrofit completion date with the use data
 create phase times
 do weather adjustment
 calculate change in use 
 calculate realization rate
 
 add realization rate
 */
 
 **Get the project completion date
 
 
 
