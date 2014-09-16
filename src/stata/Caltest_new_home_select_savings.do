**Savings selection**

clear
set more off

cd "/Users/matthewgee/Projects/CalTest/src/stata"

local elec_results = "caltest_elec_savings_all"
local gas_results = "caltest_gas_savings_all"

*local elec_results = "caltest_elec_savings_final_0731"
*local gas_results = "caltest_gas_savings_final_0731"

local basetemp_elec = 65
local basetemp_gas = 60

***Elec Select***

use `elec_results', clear

*Keep the best fit*
bysort account_id: egen maxr2_pre = max(r2_pre)
bysort account_id: egen maxr2_post = max(r2_post)

keep if r2_pre==maxr2_pre|r2_post==maxr2_post|basetemp==`basetemp_elec'

**screen out negative savings

drop if savings < 0 |savings==.

*drop if base load change is more than 50% of change
gen base_change = base_pre - base_post

gen base_pct_save = base_change/savings

gen ci90_elec_original = sqrt(((senac_pre*senac_pre)+(senac_post*senac_post))/12)*1.717
gen ci90_elec = sqrt(((senac_pre*senac_pre)+(senac_post*senac_post))/12)*1.646

order account_id site_number basetemp nac_pre nac_post savings ci90_elec_original ci90_elec r2_pre r2_post nreads_pre nreads_post base_pre base_post

*drop if slop negative
drop if cpdd_pre<0
drop if cpdd_post<0

*drop low r2
drop if r2_pre<.2
drop if r2_post<.2

*drop if not enough reads
drop if nreads_pre<12
drop if nreads_post<12

*Total savings
gen pct_save = savings/nac_pre

*drop for low savings
drop if pct_save<.01

save caltest_elec_results_final, replace

***************************
***Get gas*****************

use `gas_results', clear

*Keep the best fit*
bysort account_id: egen maxr2_pre = max(r2_pre)
bysort account_id: egen maxr2_post = max(r2_post)

keep if r2_pre==maxr2_pre|r2_post==maxr2_post|basetemp==`basetemp_gas'

**screen out negative savings

drop if savings < 0 |savings==.

*drop if base load change is more than 50% of change
gen base_change = base_pre - base_post

gen base_pct_save = base_change/savings
*drop if base_pct_save>.5

**create confidence intervals

gen ci90_gas_original = sqrt(((senac_pre*senac_pre)+(senac_post*senac_post))/12)*1.717
gen ci90_gas = sqrt(((senac_pre*senac_pre)+(senac_post*senac_post))/12)*1.646


order account_id site_number basetemp nac_pre nac_post savings ci90_gas_original ci90_gas r2_pre r2_post nreads_pre nreads_post base_pre base_post

*drop if slop negative
drop if hpdd_pre<0
drop if hpdd_post<0

*drop low r2
drop if r2_pre<.2
drop if r2_post<.2

*drop if not enough reads
drop if nreads_pre<12
drop if nreads_post<12

*Total savings
gen pct_save = savings/nac_pre

*drop for low savings
drop if pct_save<.01

save caltest_gas_savings_final, replace
